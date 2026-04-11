import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Real-time TTS using Microsoft Edge's online speech synthesis API.
/// Dart port of the Python edge-tts library's WebSocket protocol.
class EdgeTtsService {
  static const _trustedClientToken = '6A5AA1D4EAFF4E9FB37E23D68491D6F4';
  static const _wssBase =
      'wss://speech.platform.bing.com/consumer/speech/synthesize/readaloud/edge/v1';
  static const _voiceListUrl =
      'https://speech.platform.bing.com/consumer/speech/synthesize/readaloud/voices/list'
      '?trustedclienttoken=$_trustedClientToken';
  static const _chromiumFullVersion = '143.0.3650.75';
  static const _chromiumMajor = '143';
  static const _secMsGecVersion = '1-$_chromiumFullVersion';
  static const _winEpoch = 11644473600;

  /// Clock skew in seconds between device and Microsoft server.
  static int _clockSkewSeconds = 0;
  static bool _clockSynced = false;

  final AudioPlayer _player = AudioPlayer();
  String voice;
  String rate;
  String pitch;
  String volume;

  EdgeTtsService({
    this.voice = 'zh-CN-XiaoxiaoNeural',
    this.rate = '+0%',
    this.pitch = '+0Hz',
    this.volume = '+0%',
  });

  /// Sync device clock against Microsoft server's Date header.
  /// This fixes 403 errors caused by clock skew (same as Python edge-tts).
  static Future<void> _syncClock() async {
    if (_clockSynced) return;
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 5);
    try {
      final request = await client.getUrl(Uri.parse(_voiceListUrl));
      request.headers.set('User-Agent',
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
          ' (KHTML, like Gecko) Chrome/$_chromiumMajor.0.0.0 Safari/537.36'
          ' Edg/$_chromiumMajor.0.0.0');
      final response = await request.close();
      final serverDateStr = response.headers.value('date');
      await response.drain<void>();
      if (serverDateStr != null) {
        final serverTime = HttpDate.parse(serverDateStr);
        final clientTime = DateTime.now().toUtc();
        _clockSkewSeconds =
            serverTime.difference(clientTime).inSeconds;
        // ignore: avoid_print
        print('[EdgeTTS] Clock skew: ${_clockSkewSeconds}s');
      }
      _clockSynced = true;
    } catch (e) {
      // ignore: avoid_print
      print('[EdgeTTS] Clock sync failed: $e');
    } finally {
      client.close(force: true);
    }
  }

  /// Generate the Sec-MS-GEC DRM token with clock skew correction.
  static String _generateSecMsGec() {
    final nowSec =
        (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000) +
            _clockSkewSeconds;
    final winSec = nowSec + _winEpoch;
    final rounded = winSec - (winSec % 300);
    final ticks = rounded * 10000000;
    final strToHash = '$ticks$_trustedClientToken';
    return sha256.convert(utf8.encode(strToHash)).toString().toUpperCase();
  }

  static String _connectId() => const Uuid().v4().replaceAll('-', '');

  static String _generateMuid() {
    final rng = Random.secure();
    return List.generate(
      32,
      (_) => rng.nextInt(16).toRadixString(16),
    ).join().toUpperCase();
  }

  static String _dateToString() {
    final now = DateTime.now().toUtc();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final dn = days[now.weekday - 1];
    final mn = months[now.month - 1];
    final d = now.day.toString().padLeft(2, '0');
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    return '$dn $mn $d ${now.year} $h:$m:$s GMT+0000 (Coordinated Universal Time)';
  }

  static String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  String _buildSsml(String text) {
    final escaped = _escapeXml(text);
    return "<speak version='1.0' xmlns='http://www.w3.org/2001/10/synthesis' xml:lang='en-US'>"
        "<voice name='$voice'>"
        "<prosody pitch='$pitch' rate='$rate' volume='$volume'>"
        '$escaped'
        '</prosody>'
        '</voice>'
        '</speak>';
  }

  /// Full headers matching Python edge-tts WSS_HEADERS + BASE_HEADERS.
  static Map<String, dynamic> _wsHeaders() => {
        'Pragma': 'no-cache',
        'Cache-Control': 'no-cache',
        'Origin': 'chrome-extension://jdiccldimpdaibmpdkjnbmckianbfold',
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
            ' (KHTML, like Gecko) Chrome/$_chromiumMajor.0.0.0 Safari/537.36'
            ' Edg/$_chromiumMajor.0.0.0',
        'Accept-Encoding': 'gzip, deflate, br',
        'Accept-Language': 'en-US,en;q=0.9',
        'Cookie': 'muid=${_generateMuid()};',
      };

  /// Synthesize [text] to MP3 bytes via Edge TTS WebSocket API.
  /// Retries once after syncing clock on 403.
  Future<Uint8List?> synthesize(String text) async {
    if (text.trim().isEmpty) return null;

    await _syncClock();

    // Try up to 2 times (initial + retry after clock re-sync)
    for (var attempt = 0; attempt < 2; attempt++) {
      final result = await _trySynthesize(text);
      if (result != null) return result;

      if (attempt == 0) {
        // Force re-sync clock and retry
        _clockSynced = false;
        await _syncClock();
      }
    }
    return null;
  }

  Future<Uint8List?> _trySynthesize(String text) async {
    final connId = _connectId();
    final gecToken = _generateSecMsGec();
    final url = '$_wssBase'
        '?TrustedClientToken=$_trustedClientToken'
        '&ConnectionId=$connId'
        '&Sec-MS-GEC=$gecToken'
        '&Sec-MS-GEC-Version=$_secMsGecVersion';

    // ignore: avoid_print
    print('[EdgeTTS] Connecting... GEC=$gecToken skew=${_clockSkewSeconds}s');

    WebSocket? ws;
    try {
      final client = HttpClient();
      client.userAgent = null; // Don't add default Dart User-Agent
      client.connectionTimeout = const Duration(seconds: 10);

      ws = await WebSocket.connect(
        url,
        headers: _wsHeaders(),
        customClient: client,
        compression: CompressionOptions.compressionDefault,
      ).timeout(const Duration(seconds: 10));

      // 1. Send speech.config
      ws.add(
        'X-Timestamp:${_dateToString()}\r\n'
        'Content-Type:application/json; charset=utf-8\r\n'
        'Path:speech.config\r\n\r\n'
        '{"context":{"synthesis":{"audio":{"metadataoptions":'
        '{"sentenceBoundaryEnabled":"true","wordBoundaryEnabled":"false"},'
        '"outputFormat":"audio-24khz-48kbitrate-mono-mp3"}}}}\r\n',
      );

      // 2. Send SSML request
      ws.add(
        'X-RequestId:${_connectId()}\r\n'
        'Content-Type:application/ssml+xml\r\n'
        'X-Timestamp:${_dateToString()}Z\r\n'
        'Path:ssml\r\n\r\n'
        '${_buildSsml(text)}',
      );

      // 3. Collect audio
      final audioBytes = BytesBuilder();
      bool gotTurnEnd = false;

      await for (final msg in ws) {
        if (msg is String) {
          if (msg.contains('Path:turn.end')) {
            gotTurnEnd = true;
            break;
          }
        } else if (msg is List<int>) {
          final data = Uint8List.fromList(msg);
          if (data.length < 2) continue;
          final headerLen = (data[0] << 8) | data[1];
          if (headerLen + 2 > data.length) continue;
          final headerStr = utf8.decode(
            data.sublist(2, headerLen + 2),
            allowMalformed: true,
          );
          if (headerStr.contains('Path:audio') &&
              headerStr.contains('audio/mpeg')) {
            audioBytes.add(data.sublist(headerLen + 2));
          }
        }
      }

      await ws.close().timeout(const Duration(seconds: 3),
          onTimeout: () {});

      if (!gotTurnEnd && audioBytes.isEmpty) return null;
      final result = audioBytes.toBytes();
      // ignore: avoid_print
      print('[EdgeTTS] Got ${result.length} bytes of audio');
      return result.isEmpty ? null : Uint8List.fromList(result);
    } catch (e) {
      // ignore: avoid_print
      print('[EdgeTTS] error: $e');
      try {
        await ws?.close();
      } catch (_) {}
      return null;
    }
  }

  /// Speak [text]: synthesize and play. Returns true on success.
  Future<bool> speak(String text) async {
    final audioData = await synthesize(text);
    if (audioData == null) return false;

    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/edge_tts_${text.hashCode}.mp3');
      await file.writeAsBytes(audioData);
      await _player.stop();
      await _player.play(DeviceFileSource(file.path));
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('[EdgeTTS] playback error: $e');
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}

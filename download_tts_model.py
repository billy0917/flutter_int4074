import urllib.request, tarfile, os

url = 'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-icefall-zh-aishell3.tar.bz2'
archive = 'vits-icefall-zh-aishell3.tar.bz2'
out_dir = 'assets/tts_zh_model'

os.makedirs(out_dir, exist_ok=True)

print('Downloading aishell3 TTS model (~30MB)...')
urllib.request.urlretrieve(url, archive)
print('Download complete. Extracting...')

needed = ('model.onnx', 'lexicon.txt', 'tokens.txt')
with tarfile.open(archive, 'r:bz2') as tar:
    for m in tar.getmembers():
        basename = os.path.basename(m.name)
        if basename in needed:
            m.name = basename
            tar.extract(m, out_dir)
            print(f'  Extracted {basename}')

os.remove(archive)
print('Done!')

for f in os.listdir(out_dir):
    fp = os.path.join(out_dir, f)
    sz = os.path.getsize(fp)
    print(f'  {f}: {sz/1024/1024:.1f} MB')

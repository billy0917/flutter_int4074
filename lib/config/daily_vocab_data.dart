/// Daily vocabulary data for the home screen carousel.
/// Contains the 64 words from phrase categories + 36 additional words.

class DailyVocab {
  final String chinese;
  final String pinyin;
  final String english;
  final String imagePath;
  final String exampleZh;
  final String examplePinyin;
  final String exampleEn;

  const DailyVocab({
    required this.chinese,
    required this.pinyin,
    required this.english,
    this.imagePath = '',
    required this.exampleZh,
    required this.examplePinyin,
    required this.exampleEn,
  });
}

const String _v = 'assets/images/vocab';

const List<DailyVocab> kDailyVocabList = [
  // ─── 打招呼 Greetings (8) ────────────────────────
  DailyVocab(
    chinese: '你好', pinyin: 'nǐ hǎo', english: 'Hello', imagePath: '$_v/hello.jpg',
    exampleZh: '你好，很高興認識你。', examplePinyin: 'Nǐ hǎo, hěn gāo xìng rèn shi nǐ.', exampleEn: 'Hello, nice to meet you.',
  ),
  DailyVocab(
    chinese: '早上好', pinyin: 'zǎo shang hǎo', english: 'Good morning', imagePath: '$_v/good_morning.jpg',
    exampleZh: '早上好，今天天氣真好。', examplePinyin: 'Zǎo shang hǎo, jīn tiān tiān qì zhēn hǎo.', exampleEn: 'Good morning, the weather is great today.',
  ),
  DailyVocab(
    chinese: '晚上好', pinyin: 'wǎn shang hǎo', english: 'Good evening', imagePath: '$_v/good_evening.jpg',
    exampleZh: '晚上好，你吃飯了嗎？', examplePinyin: 'Wǎn shang hǎo, nǐ chī fàn le ma?', exampleEn: 'Good evening, have you eaten?',
  ),
  DailyVocab(
    chinese: '再見', pinyin: 'zài jiàn', english: 'Goodbye', imagePath: '$_v/goodbye.jpg',
    exampleZh: '再見，明天見！', examplePinyin: 'Zài jiàn, míng tiān jiàn!', exampleEn: 'Goodbye, see you tomorrow!',
  ),
  DailyVocab(
    chinese: '謝謝', pinyin: 'xiè xie', english: 'Thank you', imagePath: '$_v/thank_you.jpg',
    exampleZh: '謝謝你幫我的忙。', examplePinyin: 'Xiè xie nǐ bāng wǒ de máng.', exampleEn: 'Thank you for your help.',
  ),
  DailyVocab(
    chinese: '不客氣', pinyin: 'bú kè qi', english: "You're welcome", imagePath: '$_v/welcome.jpg',
    exampleZh: '不客氣，這是我應該做的。', examplePinyin: 'Bú kè qi, zhè shì wǒ yīng gāi zuò de.', exampleEn: "You're welcome, it's what I should do.",
  ),
  DailyVocab(
    chinese: '對不起', pinyin: 'duì bu qǐ', english: 'Sorry', imagePath: '$_v/sorry.jpg',
    exampleZh: '對不起，我遲到了。', examplePinyin: 'Duì bu qǐ, wǒ chí dào le.', exampleEn: 'Sorry, I am late.',
  ),
  DailyVocab(
    chinese: '沒關係', pinyin: 'méi guān xi', english: "It's okay", imagePath: '$_v/its_okay.jpg',
    exampleZh: '沒關係，下次注意就好。', examplePinyin: 'Méi guān xi, xià cì zhù yì jiù hǎo.', exampleEn: "It's okay, just be careful next time.",
  ),

  // ─── 餐廳與美食 Restaurant (8) ────────────────────
  DailyVocab(
    chinese: '筷子', pinyin: 'kuài zi', english: 'Chopsticks', imagePath: '$_v/chopsticks.jpg',
    exampleZh: '請給我一雙筷子。', examplePinyin: 'Qǐng gěi wǒ yì shuāng kuài zi.', exampleEn: 'Please give me a pair of chopsticks.',
  ),
  DailyVocab(
    chinese: '點菜', pinyin: 'diǎn cài', english: 'Order food', imagePath: '$_v/order_food.jpg',
    exampleZh: '我想點菜，請給我菜單。', examplePinyin: 'Wǒ xiǎng diǎn cài, qǐng gěi wǒ cài dān.', exampleEn: 'I want to order, please give me the menu.',
  ),
  DailyVocab(
    chinese: '買單', pinyin: 'mǎi dān', english: 'Pay the bill', imagePath: '$_v/pay_bill.jpg',
    exampleZh: '服務員，我要買單。', examplePinyin: 'Fú wù yuán, wǒ yào mǎi dān.', exampleEn: "Waiter, I'd like to pay the bill.",
  ),
  DailyVocab(
    chinese: '服務員', pinyin: 'fú wù yuán', english: 'Waiter', imagePath: '$_v/waiter.jpg',
    exampleZh: '服務員，請過來一下。', examplePinyin: 'Fú wù yuán, qǐng guò lái yí xià.', exampleEn: 'Waiter, please come here.',
  ),
  DailyVocab(
    chinese: '菜單', pinyin: 'cài dān', english: 'Menu', imagePath: '$_v/menu.jpg',
    exampleZh: '請給我看一下菜單。', examplePinyin: 'Qǐng gěi wǒ kàn yí xià cài dān.', exampleEn: 'Please let me see the menu.',
  ),
  DailyVocab(
    chinese: '好吃', pinyin: 'hǎo chī', english: 'Delicious', imagePath: '$_v/delicious.jpg',
    exampleZh: '這道菜真好吃！', examplePinyin: 'Zhè dào cài zhēn hǎo chī!', exampleEn: 'This dish is really delicious!',
  ),
  DailyVocab(
    chinese: '米飯', pinyin: 'mǐ fàn', english: 'Rice', imagePath: '$_v/rice.jpg',
    exampleZh: '我想要一碗米飯。', examplePinyin: 'Wǒ xiǎng yào yì wǎn mǐ fàn.', exampleEn: "I'd like a bowl of rice.",
  ),
  DailyVocab(
    chinese: '飲料', pinyin: 'yǐn liào', english: 'Drink', imagePath: '$_v/drink.jpg',
    exampleZh: '你想喝什麼飲料？', examplePinyin: 'Nǐ xiǎng hē shén me yǐn liào?', exampleEn: 'What drink would you like?',
  ),

  // ─── 校園生活 School Life (8) ─────────────────────
  DailyVocab(
    chinese: '課本', pinyin: 'kè běn', english: 'Textbook', imagePath: '$_v/textbook.jpg',
    exampleZh: '請打開課本第五頁。', examplePinyin: 'Qǐng dǎ kāi kè běn dì wǔ yè.', exampleEn: 'Please open the textbook to page five.',
  ),
  DailyVocab(
    chinese: '操場', pinyin: 'cāo chǎng', english: 'Playground', imagePath: '$_v/playground.jpg',
    exampleZh: '同學們在操場上跑步。', examplePinyin: 'Tóng xué men zài cāo chǎng shàng pǎo bù.', exampleEn: 'Students are running on the playground.',
  ),
  DailyVocab(
    chinese: '考試', pinyin: 'kǎo shì', english: 'Exam', imagePath: '$_v/exam.jpg',
    exampleZh: '明天有一場考試。', examplePinyin: 'Míng tiān yǒu yì chǎng kǎo shì.', exampleEn: 'There is an exam tomorrow.',
  ),
  DailyVocab(
    chinese: '同學', pinyin: 'tóng xué', english: 'Classmate', imagePath: '$_v/classmate.jpg',
    exampleZh: '我的同學很友善。', examplePinyin: 'Wǒ de tóng xué hěn yǒu shàn.', exampleEn: 'My classmates are very friendly.',
  ),
  DailyVocab(
    chinese: '老師', pinyin: 'lǎo shī', english: 'Teacher', imagePath: '$_v/teacher.jpg',
    exampleZh: '老師在黑板上寫字。', examplePinyin: 'Lǎo shī zài hēi bǎn shàng xiě zì.', exampleEn: 'The teacher is writing on the blackboard.',
  ),
  DailyVocab(
    chinese: '作業', pinyin: 'zuò yè', english: 'Homework', imagePath: '$_v/homework.jpg',
    exampleZh: '我還沒做完作業。', examplePinyin: 'Wǒ hái méi zuò wán zuò yè.', exampleEn: "I haven't finished my homework yet.",
  ),
  DailyVocab(
    chinese: '教室', pinyin: 'jiào shì', english: 'Classroom', imagePath: '$_v/classroom.jpg',
    exampleZh: '教室裡有三十張桌子。', examplePinyin: 'Jiào shì lǐ yǒu sān shí zhāng zhuō zi.', exampleEn: 'There are thirty desks in the classroom.',
  ),
  DailyVocab(
    chinese: '圖書館', pinyin: 'tú shū guǎn', english: 'Library', imagePath: '$_v/library.jpg',
    exampleZh: '我喜歡去圖書館看書。', examplePinyin: 'Wǒ xǐ huān qù tú shū guǎn kàn shū.', exampleEn: 'I like going to the library to read.',
  ),

  // ─── 超市購物 Shopping (8) ────────────────────────
  DailyVocab(
    chinese: '收銀台', pinyin: 'shōu yín tái', english: 'Cashier', imagePath: '$_v/cashier.jpg',
    exampleZh: '請到收銀台付款。', examplePinyin: 'Qǐng dào shōu yín tái fù kuǎn.', exampleEn: 'Please go to the cashier to pay.',
  ),
  DailyVocab(
    chinese: '打折', pinyin: 'dǎ zhé', english: 'Discount', imagePath: '$_v/discount.jpg',
    exampleZh: '這件衣服打折了。', examplePinyin: 'Zhè jiàn yī fu dǎ zhé le.', exampleEn: 'This piece of clothing is on discount.',
  ),
  DailyVocab(
    chinese: '購物車', pinyin: 'gòu wù chē', english: 'Shopping cart', imagePath: '$_v/shopping_cart.jpg',
    exampleZh: '把東西放進購物車。', examplePinyin: 'Bǎ dōng xi fàng jìn gòu wù chē.', exampleEn: 'Put the things in the shopping cart.',
  ),
  DailyVocab(
    chinese: '零食', pinyin: 'líng shí', english: 'Snacks', imagePath: '$_v/snacks.jpg',
    exampleZh: '我買了一些零食。', examplePinyin: 'Wǒ mǎi le yì xiē líng shí.', exampleEn: 'I bought some snacks.',
  ),
  DailyVocab(
    chinese: '多少錢', pinyin: 'duō shao qián', english: 'How much?', imagePath: '$_v/how_much.jpg',
    exampleZh: '這個多少錢？', examplePinyin: 'Zhè ge duō shao qián?', exampleEn: 'How much is this?',
  ),
  DailyVocab(
    chinese: '太貴了', pinyin: 'tài guì le', english: 'Too expensive', imagePath: '$_v/expensive.jpg',
    exampleZh: '太貴了，能便宜一點嗎？', examplePinyin: 'Tài guì le, néng pián yi yì diǎn ma?', exampleEn: 'Too expensive, can it be cheaper?',
  ),
  DailyVocab(
    chinese: '便宜', pinyin: 'pián yi', english: 'Cheap', imagePath: '$_v/cheap.jpg',
    exampleZh: '這家店的東西很便宜。', examplePinyin: 'Zhè jiā diàn de dōng xi hěn pián yi.', exampleEn: 'Things in this store are very cheap.',
  ),
  DailyVocab(
    chinese: '找錢', pinyin: 'zhǎo qián', english: 'Change (money)', imagePath: '$_v/change_money.jpg',
    exampleZh: '請找錢給我。', examplePinyin: 'Qǐng zhǎo qián gěi wǒ.', exampleEn: 'Please give me the change.',
  ),

  // ─── 交通出行 Transport (8) ───────────────────────
  DailyVocab(
    chinese: '地鐵', pinyin: 'dì tiě', english: 'Subway', imagePath: '$_v/subway.jpg',
    exampleZh: '我坐地鐵去上班。', examplePinyin: 'Wǒ zuò dì tiě qù shàng bān.', exampleEn: 'I take the subway to work.',
  ),
  DailyVocab(
    chinese: '公交車', pinyin: 'gōng jiāo chē', english: 'Bus', imagePath: '$_v/bus_transport.jpg',
    exampleZh: '我每天早上都搭乘公交車去上班。', examplePinyin: 'Wǒ měi tiān zǎo shang dōu dā chéng gōng jiāo chē qù shàng bān.', exampleEn: 'I take the bus to work every morning.',
  ),
  DailyVocab(
    chinese: '紅綠燈', pinyin: 'hóng lǜ dēng', english: 'Traffic light', imagePath: '$_v/traffic_light.jpg',
    exampleZh: '紅綠燈變綠了，可以走了。', examplePinyin: 'Hóng lǜ dēng biàn lǜ le, kě yǐ zǒu le.', exampleEn: 'The traffic light turned green, we can go.',
  ),
  DailyVocab(
    chinese: '斑馬線', pinyin: 'bān mǎ xiàn', english: 'Crosswalk', imagePath: '$_v/crosswalk.jpg',
    exampleZh: '請走斑馬線過馬路。', examplePinyin: 'Qǐng zǒu bān mǎ xiàn guò mǎ lù.', exampleEn: 'Please use the crosswalk to cross the road.',
  ),
  DailyVocab(
    chinese: '出租車', pinyin: 'chū zū chē', english: 'Taxi', imagePath: '$_v/taxi.jpg',
    exampleZh: '我們叫一輛出租車吧。', examplePinyin: 'Wǒ men jiào yí liàng chū zū chē ba.', exampleEn: "Let's call a taxi.",
  ),
  DailyVocab(
    chinese: '火車站', pinyin: 'huǒ chē zhàn', english: 'Train station', imagePath: '$_v/train_station.jpg',
    exampleZh: '火車站在前面不遠。', examplePinyin: 'Huǒ chē zhàn zài qián miàn bù yuǎn.', exampleEn: 'The train station is not far ahead.',
  ),
  DailyVocab(
    chinese: '飛機場', pinyin: 'fēi jī chǎng', english: 'Airport', imagePath: '$_v/airport.jpg',
    exampleZh: '我要去飛機場接朋友。', examplePinyin: 'Wǒ yào qù fēi jī chǎng jiē péng you.', exampleEn: "I'm going to the airport to pick up a friend.",
  ),
  DailyVocab(
    chinese: '停車場', pinyin: 'tíng chē chǎng', english: 'Parking lot', imagePath: '$_v/parking.jpg',
    exampleZh: '停車場已經滿了。', examplePinyin: 'Tíng chē chǎng yǐ jīng mǎn le.', exampleEn: 'The parking lot is already full.',
  ),

  // ─── 看病就醫 Hospital (8) ────────────────────────
  DailyVocab(
    chinese: '掛號', pinyin: 'guà hào', english: 'Register', imagePath: '$_v/register_hospital.jpg',
    exampleZh: '我要去醫院掛號。', examplePinyin: 'Wǒ yào qù yī yuàn guà hào.', exampleEn: 'I need to register at the hospital.',
  ),
  DailyVocab(
    chinese: '體溫', pinyin: 'tǐ wēn', english: 'Temperature', imagePath: '$_v/body_temp.jpg',
    exampleZh: '護士幫我量體溫。', examplePinyin: 'Hù shi bāng wǒ liáng tǐ wēn.', exampleEn: 'The nurse took my temperature.',
  ),
  DailyVocab(
    chinese: '藥房', pinyin: 'yào fáng', english: 'Pharmacy', imagePath: '$_v/pharmacy.jpg',
    exampleZh: '藥房在醫院旁邊。', examplePinyin: 'Yào fáng zài yī yuàn páng biān.', exampleEn: 'The pharmacy is next to the hospital.',
  ),
  DailyVocab(
    chinese: '醫生', pinyin: 'yī shēng', english: 'Doctor', imagePath: '$_v/doctor.jpg',
    exampleZh: '醫生說我需要休息。', examplePinyin: 'Yī shēng shuō wǒ xū yào xiū xi.', exampleEn: 'The doctor said I need to rest.',
  ),
  DailyVocab(
    chinese: '感冒', pinyin: 'gǎn mào', english: 'Cold (illness)', imagePath: '$_v/cold_illness.jpg',
    exampleZh: '我感冒了，要多喝水。', examplePinyin: 'Wǒ gǎn mào le, yào duō hē shuǐ.', exampleEn: 'I have a cold, I need to drink more water.',
  ),
  DailyVocab(
    chinese: '頭疼', pinyin: 'tóu téng', english: 'Headache', imagePath: '$_v/headache.jpg',
    exampleZh: '我頭疼，想去看醫生。', examplePinyin: 'Wǒ tóu téng, xiǎng qù kàn yī shēng.', exampleEn: 'I have a headache, I want to see a doctor.',
  ),
  DailyVocab(
    chinese: '吃藥', pinyin: 'chī yào', english: 'Take medicine', imagePath: '$_v/take_medicine.jpg',
    exampleZh: '醫生讓我按時吃藥。', examplePinyin: 'Yī shēng ràng wǒ àn shí chī yào.', exampleEn: 'The doctor told me to take medicine on time.',
  ),
  DailyVocab(
    chinese: '護士', pinyin: 'hù shi', english: 'Nurse', imagePath: '$_v/nurse.jpg',
    exampleZh: '護士很細心地照顧病人。', examplePinyin: 'Hù shi hěn xì xīn de zhào gù bìng rén.', exampleEn: 'The nurse takes care of patients attentively.',
  ),

  // ─── 家庭日常 Home Life (8) ───────────────────────
  DailyVocab(
    chinese: '洗碗', pinyin: 'xǐ wǎn', english: 'Wash dishes', imagePath: '$_v/wash_dishes.jpg',
    exampleZh: '吃完飯後我要洗碗。', examplePinyin: 'Chī wán fàn hòu wǒ yào xǐ wǎn.', exampleEn: 'I need to wash dishes after eating.',
  ),
  DailyVocab(
    chinese: '吸塵器', pinyin: 'xī chén qì', english: 'Vacuum cleaner', imagePath: '$_v/vacuum.jpg',
    exampleZh: '用吸塵器打掃房間。', examplePinyin: 'Yòng xī chén qì dǎ sǎo fáng jiān.', exampleEn: 'Use the vacuum cleaner to clean the room.',
  ),
  DailyVocab(
    chinese: '遙控器', pinyin: 'yáo kòng qì', english: 'Remote control', imagePath: '$_v/remote.jpg',
    exampleZh: '遙控器在沙發上。', examplePinyin: 'Yáo kòng qì zài shā fā shàng.', exampleEn: 'The remote control is on the sofa.',
  ),
  DailyVocab(
    chinese: '衣櫃', pinyin: 'yī guì', english: 'Wardrobe', imagePath: '$_v/wardrobe.jpg',
    exampleZh: '把衣服放進衣櫃裡。', examplePinyin: 'Bǎ yī fu fàng jìn yī guì lǐ.', exampleEn: 'Put the clothes in the wardrobe.',
  ),
  DailyVocab(
    chinese: '洗衣機', pinyin: 'xǐ yī jī', english: 'Washing machine', imagePath: '$_v/washing_machine.jpg',
    exampleZh: '洗衣機壞了，需要修理。', examplePinyin: 'Xǐ yī jī huài le, xū yào xiū lǐ.', exampleEn: 'The washing machine is broken, it needs repair.',
  ),
  DailyVocab(
    chinese: '冰箱', pinyin: 'bīng xiāng', english: 'Fridge', imagePath: '$_v/fridge.jpg',
    exampleZh: '牛奶放在冰箱裡。', examplePinyin: 'Niú nǎi fàng zài bīng xiāng lǐ.', exampleEn: 'The milk is in the fridge.',
  ),
  DailyVocab(
    chinese: '沙發', pinyin: 'shā fā', english: 'Sofa', imagePath: '$_v/sofa.jpg',
    exampleZh: '我喜歡坐在沙發上看電視。', examplePinyin: 'Wǒ xǐ huān zuò zài shā fā shàng kàn diàn shì.', exampleEn: 'I like sitting on the sofa watching TV.',
  ),
  DailyVocab(
    chinese: '窗戶', pinyin: 'chuāng hu', english: 'Window', imagePath: '$_v/window.jpg',
    exampleZh: '請打開窗戶通風。', examplePinyin: 'Qǐng dǎ kāi chuāng hu tōng fēng.', exampleEn: 'Please open the window for ventilation.',
  ),

  // ─── 天氣與自然 Weather (8) ───────────────────────
  DailyVocab(
    chinese: '暴風雨', pinyin: 'bào fēng yǔ', english: 'Storm', imagePath: '$_v/storm.jpg',
    exampleZh: '今天有暴風雨，不要出門。', examplePinyin: 'Jīn tiān yǒu bào fēng yǔ, bú yào chū mén.', exampleEn: "There's a storm today, don't go out.",
  ),
  DailyVocab(
    chinese: '彩虹', pinyin: 'cǎi hóng', english: 'Rainbow', imagePath: '$_v/rainbow.jpg',
    exampleZh: '雨後天空出現了彩虹。', examplePinyin: 'Yǔ hòu tiān kōng chū xiàn le cǎi hóng.', exampleEn: 'A rainbow appeared after the rain.',
  ),
  DailyVocab(
    chinese: '溫度', pinyin: 'wēn dù', english: 'Temperature', imagePath: '$_v/thermometer.jpg',
    exampleZh: '今天的溫度很高。', examplePinyin: 'Jīn tiān de wēn dù hěn gāo.', exampleEn: 'The temperature is very high today.',
  ),
  DailyVocab(
    chinese: '霧霾', pinyin: 'wù mái', english: 'Smog', imagePath: '$_v/smog.jpg',
    exampleZh: '霧霾天要戴口罩。', examplePinyin: 'Wù mái tiān yào dài kǒu zhào.', exampleEn: 'Wear a mask on smoggy days.',
  ),
  DailyVocab(
    chinese: '下雨', pinyin: 'xià yǔ', english: 'Raining', imagePath: '$_v/raining.jpg',
    exampleZh: '外面在下雨，帶傘吧。', examplePinyin: 'Wài miàn zài xià yǔ, dài sǎn ba.', exampleEn: "It's raining outside, bring an umbrella.",
  ),
  DailyVocab(
    chinese: '颳風', pinyin: 'guā fēng', english: 'Windy', imagePath: '$_v/windy.jpg',
    exampleZh: '今天颳風很大。', examplePinyin: 'Jīn tiān guā fēng hěn dà.', exampleEn: "It's very windy today.",
  ),
  DailyVocab(
    chinese: '晴天', pinyin: 'qíng tiān', english: 'Sunny day', imagePath: '$_v/sunny.jpg',
    exampleZh: '今天是晴天，適合出去玩。', examplePinyin: 'Jīn tiān shì qíng tiān, shì hé chū qù wán.', exampleEn: "It's sunny today, great for going out.",
  ),
  DailyVocab(
    chinese: '下雪', pinyin: 'xià xuě', english: 'Snowing', imagePath: '$_v/snowing.jpg',
    exampleZh: '外面在下雪，好漂亮。', examplePinyin: 'Wài miàn zài xià xuě, hǎo piào liang.', exampleEn: "It's snowing outside, so pretty.",
  ),
];

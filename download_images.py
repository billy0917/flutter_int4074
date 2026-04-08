import urllib.request
import time
import os

OUT_DIR = "assets/images/vocab"

# 每個詞彙 → (檔名, 搜尋關鍵字)，各詞彙用不同關鍵字確保圖片不同
VOCAB = [
    # Greetings
    ("hello", "people,waving,hello"),
    ("good_morning", "sunrise,morning,sky"),
    ("good_evening", "evening,sunset,dusk"),
    ("goodbye", "farewell,waving,bye"),
    ("thank_you", "thank,you,gratitude"),
    ("welcome", "welcome,sign,hospitality"),
    ("sorry", "apology,bowing,sorry"),
    ("its_okay", "thumbs,up,okay"),
    # Restaurant
    ("chopsticks", "chopsticks,asian,food"),
    ("order_food", "ordering,restaurant,waiter"),
    ("pay_bill", "paying,bill,restaurant"),
    ("waiter", "waiter,serving,tray"),
    ("menu", "menu,restaurant,dining"),
    ("delicious", "delicious,food,yummy"),
    ("rice", "rice,bowl,steamed"),
    ("drink", "beverage,drink,glass"),
    # School
    ("textbook", "textbook,study,reading"),
    ("playground", "playground,children,school"),
    ("exam", "exam,test,paper"),
    ("classmate", "students,classmates,school"),
    ("teacher", "teacher,classroom,blackboard"),
    ("homework", "homework,writing,desk"),
    ("classroom", "classroom,desks,school"),
    ("library", "library,books,shelves"),
    # Shopping
    ("cashier", "cashier,checkout,counter"),
    ("discount", "sale,discount,shopping"),
    ("shopping_cart", "shopping,cart,supermarket"),
    ("snacks", "snacks,chips,candy"),
    ("how_much", "price,tag,label"),
    ("expensive", "luxury,expensive,jewelry"),
    ("cheap", "bargain,market,cheap"),
    ("change_money", "coins,money,change"),
    # Transport
    ("subway", "subway,metro,underground"),
    ("bus_transport", "bus,public,transport"),
    ("traffic_light", "traffic,light,signal"),
    ("crosswalk", "crosswalk,pedestrian,zebra"),
    ("taxi", "taxi,cab,yellow"),
    ("train_station", "train,station,railway"),
    ("airport", "airport,airplane,terminal"),
    ("parking", "parking,lot,cars"),
    # Hospital
    ("register_hospital", "hospital,reception,desk"),
    ("body_temp", "thermometer,temperature,fever"),
    ("pharmacy", "pharmacy,drugstore,medicine"),
    ("doctor", "doctor,stethoscope,physician"),
    ("cold_illness", "cold,flu,sneeze"),
    ("headache", "headache,pain,migraine"),
    ("take_medicine", "medicine,pills,tablet"),
    ("nurse", "nurse,hospital,care"),
    # Home Life
    ("wash_dishes", "washing,dishes,kitchen"),
    ("vacuum", "vacuum,cleaner,carpet"),
    ("remote", "remote,control,television"),
    ("wardrobe", "wardrobe,closet,clothes"),
    ("washing_machine", "washing,machine,laundry"),
    ("fridge", "refrigerator,fridge,kitchen"),
    ("sofa", "sofa,couch,living"),
    ("window", "window,curtain,house"),
    # Weather
    ("storm", "storm,lightning,thunder"),
    ("rainbow", "rainbow,sky,colorful"),
    ("thermometer", "weather,thermometer,gauge"),
    ("smog", "smog,pollution,haze"),
    ("raining", "rain,raining,umbrella"),
    ("windy", "windy,wind,blowing"),
    ("sunny", "sunny,sunshine,clear"),
    ("snowing", "snow,snowing,winter"),
]

os.makedirs(OUT_DIR, exist_ok=True)
success = 0
fail = 0
total = len(VOCAB)

for i, (name, keywords) in enumerate(VOCAB, 1):
    out_path = os.path.join(OUT_DIR, f"{name}.jpg")
    if os.path.exists(out_path) and os.path.getsize(out_path) > 500:
        print(f"[{i}/{total}] SKIP (exists): {name}.jpg")
        success += 1
        continue
    url = f"https://loremflickr.com/300/300/{keywords}"
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "PinPinGoApp/1.0"})
        with urllib.request.urlopen(req, timeout=15) as resp:
            data = resp.read()
            with open(out_path, "wb") as f:
                f.write(data)
        size = len(data)
        print(f"[{i}/{total}] OK: {name}.jpg ({size} bytes) <- {keywords}")
        success += 1
    except Exception as e:
        print(f"[{i}/{total}] FAIL: {name} - {e}")
        fail += 1
    # 每次下載間隔 1.5 秒，避免重複圖片
    time.sleep(1.5)

print(f"\nDone: {success} success, {fail} failed out of {total} total")

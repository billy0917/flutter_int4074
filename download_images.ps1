# 用 loremflickr.com 下載每個詞彙對應的真實圖片（每個用獨立關鍵字搜尋）
$outDir = "assets\images\vocab"

# 每個詞彙 → 獨立搜尋關鍵字（逗號分隔 = AND 搜尋，確保圖片相關且不同）
$mapping = [ordered]@{
    # Greetings
    "hello"           = "people,waving,hello"
    "good_morning"    = "sunrise,morning,sky"
    "good_evening"    = "evening,sunset,dusk"
    "goodbye"         = "farewell,waving,bye"
    "thank_you"       = "thank,you,gratitude"
    "welcome"         = "welcome,sign,hospitality"
    "sorry"           = "apology,bowing,sorry"
    "its_okay"        = "thumbs,up,okay"

    # Restaurant
    "chopsticks"      = "chopsticks,asian,food"
    "order_food"      = "ordering,restaurant,waiter"
    "pay_bill"        = "paying,bill,restaurant"
    "waiter"          = "waiter,serving,tray"
    "menu"            = "menu,restaurant,dining"
    "delicious"       = "delicious,food,yummy"
    "rice"            = "rice,bowl,steamed"
    "drink"           = "beverage,drink,glass"

    # School
    "textbook"        = "textbook,study,reading"
    "playground"      = "playground,children,school"
    "exam"            = "exam,test,paper"
    "classmate"       = "students,classmates,school"
    "teacher"         = "teacher,classroom,blackboard"
    "homework"        = "homework,writing,desk"
    "classroom"       = "classroom,desks,school"
    "library"         = "library,books,shelves"

    # Shopping
    "cashier"         = "cashier,checkout,counter"
    "discount"        = "sale,discount,shopping"
    "shopping_cart"   = "shopping,cart,supermarket"
    "snacks"          = "snacks,chips,candy"
    "how_much"        = "price,tag,label"
    "expensive"       = "luxury,expensive,jewelry"
    "cheap"           = "bargain,market,cheap"
    "change_money"    = "coins,money,change"

    # Transport
    "subway"          = "subway,metro,underground"
    "bus_transport"   = "bus,public,transport"
    "traffic_light"   = "traffic,light,signal"
    "crosswalk"       = "crosswalk,pedestrian,zebra"
    "taxi"            = "taxi,cab,yellow"
    "train_station"   = "train,station,railway"
    "airport"         = "airport,airplane,terminal"
    "parking"         = "parking,lot,cars"

    # Hospital
    "register_hospital" = "hospital,reception,desk"
    "body_temp"       = "thermometer,temperature,fever"
    "pharmacy"        = "pharmacy,drugstore,medicine"
    "doctor"          = "doctor,stethoscope,physician"
    "cold_illness"    = "cold,flu,sneeze"
    "headache"        = "headache,pain,migraine"
    "take_medicine"   = "medicine,pills,tablet"
    "nurse"           = "nurse,hospital,care"

    # Home Life
    "wash_dishes"     = "washing,dishes,kitchen"
    "vacuum"          = "vacuum,cleaner,carpet"
    "remote"          = "remote,control,television"
    "wardrobe"        = "wardrobe,closet,clothes"
    "washing_machine" = "washing,machine,laundry"
    "fridge"          = "refrigerator,fridge,kitchen"
    "sofa"            = "sofa,couch,living"
    "window"          = "window,curtain,house"

    # Weather
    "storm"           = "storm,lightning,thunder"
    "rainbow"         = "rainbow,sky,colorful"
    "thermometer"     = "weather,thermometer,gauge"
    "smog"            = "smog,pollution,haze"
    "raining"         = "rain,raining,umbrella"
    "windy"           = "windy,wind,blowing"
    "sunny"           = "sunny,sunshine,clear"
    "snowing"         = "snow,snowing,winter"
}

$success = 0
$fail = 0
$total = $mapping.Count
$i = 0

foreach ($entry in $mapping.GetEnumerator()) {
    $i++
    $fileName = $entry.Key
    $keywords = $entry.Value
    $outPath = Join-Path $outDir "$fileName.jpg"
    $url = "https://loremflickr.com/300/300/$keywords"

    try {
        Invoke-WebRequest -Uri $url -OutFile $outPath -TimeoutSec 15
        $size = (Get-Item $outPath).Length
        Write-Host "[$i/$total] OK: $fileName.jpg ($size bytes) <- $keywords"
        $success++
    } catch {
        Write-Host "[$i/$total] FAIL: $fileName - $($_.Exception.Message)"
        $fail++
    }

    # 每次下載間隔 1.5 秒，避免重複圖片和 rate limit
    Start-Sleep -Milliseconds 1500
}

Write-Host "`nDone: $success success, $fail failed out of $total total"

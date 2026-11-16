import json, os
HERE = os.path.dirname(os.path.abspath(__file__))
chars = json.load(open(os.path.join(HERE, "chars.json")))
RC = {"Common": "#aadc96", "Rare": "#50a0ff", "Super Rare": "#ff783c", "Epic": "#be5aff", "Legendary": "#ffcd28", "Mythic": "#ff3c78", "Secret": "#ffffff"}
def money(n):
    for s, d in (("B", 1e9), ("M", 1e6), ("K", 1e3)):
        if n >= d:
            v = n / d
            t = f"{v:.2f}".rstrip("0").rstrip(".") if v < 10 else (f"{v:.1f}".rstrip("0").rstrip(".") if v < 100 else str(int(v)))
            return "$" + t + s
    return f"${int(n)}"
I = [
 ("GrassAndFlowers","Grass and Flowers","Common",100,1,1,"הליכה חמודה וקופצנית, משאיר אחריו שביל נצנצים ורוד־ירוק שנעלם אחרי 3 שניות.","דשא בכל הכדור ו־5 פרחים שמתנדנדים."),
 ("MagicTree","Magic Tree","Rare",90,50,3,"הליכה חמודה, משאיר אחריו אדמה שנעלמת אחרי 5 שניות.","10 עצים מכל הסוגים (תפוחים, אורן, פריחה, ליבנה, עץ קסום...). לפעמים נושרים עלים והעץ מתחדש."),
 ("LavaStone","Lava Stone","Super Rare",80,400,12,"הליכה בריונית ומתנדנדת, כל 3 שניות יוצא ממנו עשן שנעלם אחרי 2 שניות.","3 הרי געש עם לבה זוהרת, שפולטים עשן כל דקה."),
 ("DrippoBloxino","Drippo Bloxino","Super Rare",80,2500,45,"הולך כמו בן אדם, כל הזמן מסתכל בטלפון.","בן אדם קטן שבונה 3 בניינים, קומה אחרי קומה."),
 ("BlueCrystal","Blue Crystal","Epic",70,12000,150,"הליכה של מיליונר, חזה קדימה, ומשאיר מלא שטרות כסף מאחוריו.","10 קריסטלים כחולים שמנצנצים בכל הכדור."),
 ("ZombinoRotolino","Zombino Rotolino","Epic",75,50000,450,"צולע, עם ידיים קדימה וזבובים מסביב לראש.","זומבי שהולך ונושך עצים, פרחים ובניינים. אחרי כמה שניות הכול מתחדש."),
 ("CosmicMeteor","Cosmic Meteor","Epic",45,200000,1400,"צעדים קטנים וחמודים, עם להבות סגולות־כתומות על הראש.","מטאור נופל כל 5 שניות, רק אפקט יפה."),
 ("Giraffe","Giraffe","Legendary",65,1000000,5000,"דילוג איטי, הגלימה עפה ברוח.","5 ג'ירפות. אם יש עצים הן אוכלות מהם קצת והעץ מתחדש, אחרת הן מסתובבות."),
 ("WitchinaMagichina","Witchina Magichina","Mythic",40,6000000,22000,"הולכת עם שיקוי זוהר ביד ומטה עם קריסטל.","עומדת ליד קדרה ומכינה שיקויים. לפעמים זורקת שיקוי, והעצים והפרחים לידו זוהרים בסגול וגדלים."),
 ("FrostyFangolini","Frosty Fangolini","Secret",20,40000000,110000,"הולך על 4, עם פתיתי שלג מסביב.","מסתובב ורץ. כשהוא עובר ליד הר געש יוצא ענן אדים."),
 ("SolarioLeonario","Solario Leonario","Secret",20,250000000,550000,"זוהר כמו שמש, הולך על 4, הרעמה מתנדנדת ברוח.","אריה שנח, הולך, וצד ג'ירפות (הן נעלמות בענן נצנצים וחוזרות)."),
 ("GalaxyDragon","Galaxy Dragon","Secret",10,1000000000,1800000,"הולך ונושף אש כל כמה שניות.","מרחף בכדור עם כנפיים, ושורף מטאורים שנופלים לזיקוקים."),
]
info = {}
order = {}
for k, (cid, name, rar, ch, price, inc, walk, sph) in enumerate(I):
    info[cid] = {"name": name, "rarity": rar, "rc": RC[rar], "chance": ch, "price": money(price), "income": money(inc), "walk": walk, "sphere": sph}
    order[cid] = k
ordered = {cid: chars[cid] for cid in sorted(chars, key=lambda c: order[c])}
def r(x): return round(x, 4) if isinstance(x, float) else x
def rnd(o):
    if isinstance(o, dict): return {k: rnd(v) for k, v in o.items()}
    if isinstance(o, list): return [rnd(v) for v in o]
    return r(o)
html = open(os.path.join(HERE, "template.html")).read()
html = html.replace("/*__CHARS__*/null", json.dumps(rnd(ordered), separators=(",", ":"))).replace("/*__INFO__*/null", json.dumps(info, ensure_ascii=False))
open(os.path.join(HERE, "..", "..", "..", "labs", "characters", "index.html"), "w").write(html)
print(len(html))

import json
import urllib.request
import sys

sys.stdout.reconfigure(encoding="utf-8")

url = "https://mp3quran.net/api/v3/reciters?language=ar"
with urllib.request.urlopen(url) as resp:
    data = json.load(resp)

keywords = [
    "عبد الباسط",
    "ياسر الدوسر",
    "الحصري",
    "المعيقل",
    "العفاس",
    "العجم",
    "السديس",
    "المنشاو",
    "إسماعيل",
    "صديق",
]

for r in data["reciters"]:
    if any(k in r["name"] for k in keywords):
        print(f"{r['id']} - {r['name']}")
        for m in r.get("moshaf", []):
            print(f"  moshaf {m['id']}: {m['name']} -> {m['server']}")

import os
import base64
import json
import zlib

def purge_crosshairs(input_file='valorant-settings.json', output_file='valorant-settings-crosshairs-purged.json'):
    if not os.path.exists(input_file):
        print(f"[!] Error: '{input_file}' not found in the current directory.")
        return

    print(f"[1/5] Unpacking '{input_file}'...")
    with open(input_file, 'r', encoding='utf-8') as f:
        wrapper = json.load(f)

    if 'data' not in wrapper:
        print(f"[!] Error: 'data' key missing from {input_file}. Invalid format.")
        return

    raw_data = zlib.decompress(base64.b64decode(wrapper['data']), -15).decode('utf-8')
    settings_dict = json.loads(raw_data)

    print("[2/5] Searching and purging crosshair settings...")
    categories = ['boolSettings', 'floatSettings', 'stringSettings', 'intSettings']
    purged_count = 0

    for cat in categories:
        if cat in settings_dict:
            original_length = len(settings_dict[cat])

            settings_dict[cat] = [
                s for s in settings_dict[cat]
                if 'crosshair' not in s.get('settingEnum', '').lower()
            ]

            purged_count += (original_length - len(settings_dict[cat]))

    print(f"[3/5] Successfully removed {purged_count} crosshair-related parameters.")

    print("[4/5] Compressing and repacking data...")
    clean_json_str = json.dumps(settings_dict, separators=(',', ':'))

    compressor = zlib.compressobj(level=-1, method=zlib.DEFLATED, wbits=-15)
    compressed = compressor.compress(clean_json_str.encode('utf-8'))
    compressed += compressor.flush()

    final_payload = {
        "type": "Ares.PlayerSettings",
        "data": base64.b64encode(compressed).decode('utf-8'),
        "productId": "KeystoneClient"
    }

    print(f"[5/5] Saving purged payload to '{output_file}'...")
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(final_payload, f, separators=(',', ':'))

    print(f"✅ SUCCESS! Saved purged payload to {output_file}")

if __name__ == "__main__":
    purge_crosshairs()

import base64
import json
import zlib
import os

def process_pack(input_file, output_file):
    if not os.path.exists(input_file):
        return False

    print(f"  [1/5] Reading {input_file}...")
    with open(input_file, 'r', encoding='utf-8') as f:
        try:
            settings_dict = json.load(f)
        except json.JSONDecodeError as e:
            print(f"  [!] CRITICAL: Invalid JSON in your unpacked file. Please check your edits.\n  Error: {e}")
            return True

    print("  [2/5] Minifying JSON to remove all whitespaces...")
    clean_json_str = json.dumps(settings_dict, separators=(',', ':'))

    print("  [3/5] Compressing into Zlib raw deflate...")
    compressor = zlib.compressobj(level=-1, method=zlib.DEFLATED, wbits=-15)
    compressed = compressor.compress(clean_json_str.encode('utf-8'))
    compressed += compressor.flush()

    print("  [4/5] Base64 encoding and wrapping into final payload...")
    final_payload = {
        "type": "Ares.PlayerSettings",
        "data": base64.b64encode(compressed).decode('utf-8'),
        "productId": "KeystoneClient"
    }

    print(f"  [5/5] Saving final push-ready file {output_file}")
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(final_payload, f, separators=(',', ':'))

    print(f"✅ SUCCESS! Saved packed payload to {output_file}")
    return True

def pack_for_push():
    files_to_process = [
        ('valorant-settings-unpacked.json', 'valorant-settings.json'),
        ('valorant-settings-crosshairs-purged-unpacked.json', 'valorant-settings-crosshairs-purged.json'),
        ('crosshair-injected-unpacked.json', 'crosshair-injected.json')
    ]

    processed_any = False
    for in_file, out_file in files_to_process:
        if process_pack(in_file, out_file):
            processed_any = True

    if not processed_any:
        print("[!] Error: No unpacked files found to pack.")

if __name__ == "__main__":
    pack_for_push()

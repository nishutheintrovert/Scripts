import base64
import json
import zlib
import os

def process_unpack(input_file, output_file):
    if not os.path.exists(input_file):
        return False

    print(f"  [1/3] Reading {input_file}...")
    with open(input_file, 'r', encoding='utf-8') as f:
        wrapper_payload = json.load(f)

    if 'data' not in wrapper_payload:
        print(f"  [!] Error: 'data' key not found in {input_file}. The file might be corrupted or empty.")
        return True

    print("  [2/3] Decoding Base64 and decompressing Zlib...")
    try:
        raw_zlib = base64.b64decode(wrapper_payload['data'])
        unpacked_str = zlib.decompress(raw_zlib, -15).decode('utf-8')

        settings_dict = json.loads(unpacked_str)
    except Exception as e:
        print(f"  [!] Extraction failed: {e}")
        return True

    print(f"  [3/3] Saving formatted file {output_file}")
    formatted_json = json.dumps(settings_dict, indent=4)

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(formatted_json)

    print(f"✅ SUCCESS! Saved unpacked payload to {output_file}")
    return True

def unpack_for_diff():
    files_to_process = [
        ('valorant-settings.json', 'valorant-settings-unpacked.json'),
        ('valorant-settings-crosshairs-purged.json', 'valorant-settings-crosshairs-purged-unpacked.json'),
        ('crosshair-injected.json', 'crosshair-injected-unpacked.json')
    ]

    processed_any = False
    for in_file, out_file in files_to_process:
        if process_unpack(in_file, out_file):
            processed_any = True

    if not processed_any:
        print("[!] Error: No payload files found to unpack.")

if __name__ == "__main__":
    unpack_for_diff()

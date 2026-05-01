import os
import base64
import json
import zlib
import sys
import requests

def get_lockfile_data():
    local_app_data = os.getenv('LOCALAPPDATA')
    lockfile_path = os.path.join(local_app_data, 'Riot Games/Riot Client/Config/lockfile')

    if not os.path.exists(lockfile_path):
        print("[!] Error: Valorant/Riot Client not running!")
        exit(1)

    with open(lockfile_path, 'r') as f:
        data = f.read().split(':')
        return {"port": data[2], "password": data[3]}

def get_headers(lock_data):
    auth = base64.b64encode(f"riot:{lock_data['password']}".encode()).decode()
    local_url = f"https://127.0.0.1:{lock_data['port']}/entitlements/v1/token"

    r = requests.get(local_url, headers={"Authorization": f"Basic {auth}"}, verify=False)
    tokens = r.json()

    try:
        version_data = requests.get("https://valorant-api.com/v1/version", timeout=5).json()
        client_version = version_data['data']['riotClientVersion']
    except Exception as e:
        print(f"[-] Warning: Failed to fetch client version from valorant-api.com ({e})")
        client_version = "release-08.07-shipping-11-2467144"
        print(f"[-] Using fallback version: {client_version}")

    v = sys.getwindowsversion()
    os_ver = f'{v.major}.{v.minor}.{v.build}.1.256.64bit'

    plat_dict = {
        "platformType": "PC",
        "platformOS": "Windows",
        "platformOSVersion": os_ver,
        "platformChipset": "Unknown"
    }

    platform_header = base64.b64encode(json.dumps(plat_dict, separators=(',', ':')).encode()).decode()

    return {
        "Authorization": f"Bearer {tokens['accessToken']}",
        "X-Riot-Entitlements-JWT": tokens['token'],
        "X-Riot-ClientVersion": client_version,
        "X-Riot-ClientPlatform": platform_header,
        "User-Agent": f"ShootingGame/13 Windows/{os_ver}",
        "Content-Type": "application/json"
    }

def inject_crosshairs(headers):
    base_file = 'valorant-settings-crosshairs-purged.json'
    output_file = 'crosshair-injected.json'

    if not os.path.exists(base_file):
        print(f"[!] Error: {base_file} not found. Run purge-crosshairs.py first.")
        return

    print(f"[1/6] Unpacking {base_file}...")
    with open(base_file, 'r', encoding='utf-8') as f:
        base_wrapper = json.load(f)

    if 'data' not in base_wrapper:
        print(f"[!] Error: 'data' key missing from {base_file}.")
        return

    base_raw = zlib.decompress(base64.b64decode(base_wrapper['data']), -15).decode('utf-8')
    base_dict = json.loads(base_raw)

    print(f"[2/6] Confirming {base_file} is clean...")
    categories = ['boolSettings', 'floatSettings', 'stringSettings', 'intSettings']
    for cat in categories:
        if cat in base_dict:
            for setting in base_dict[cat]:
                if 'crosshair' in setting.get('settingEnum', '').lower():
                    print(f"[!] Sanity Check Failed: Found existing crosshair settings in {base_file}.")
                    print(f"[!] Did you just rename main payload to {base_file}?")
                    print(f"[!] Please run purge-crosshairs.py on main payload")
                    return

    print("[3/6] Fetching Target Account settings from Cloud...")
    url = "https://valorant-settings-syncer.nishutheintrovert.workers.dev/settings/fetch"
    response = requests.get(url, headers=headers)

    if response.status_code != 200:
        print(f"-> GET Server Response Code: {response.status_code} [Failed]")
        return

    target_wrapper = response.json()

    if 'data' not in target_wrapper:
        print("[!] Error: 'data' key missing from target account response. Possibly a fresh account.")
        return

    target_raw = zlib.decompress(base64.b64decode(target_wrapper['data']), -15).decode('utf-8')
    target_dict = json.loads(target_raw)

    print("[4/6] Injecting targets Crosshairs...")
    categories = ['boolSettings', 'floatSettings', 'stringSettings', 'intSettings']

    for cat in categories:
        if cat in target_dict:
            target_crosshairs = [s for s in target_dict[cat] if 'Crosshair' in s.get('settingEnum', '').lower()]
            if target_crosshairs:
                if cat not in base_dict:
                    base_dict[cat] = []
                base_dict[cat].extend(target_crosshairs)

    print("[5/6] Minifying and compressing merged payload...")
    clean_json_str = json.dumps(base_dict, separators=(',', ':'))
    compressor = zlib.compressobj(level=-1, method=zlib.DEFLATED, wbits=-15)
    compressed = compressor.compress(clean_json_str.encode('utf-8'))
    compressed += compressor.flush()

    print(f"[6/6] Saving injected payload to {output_file}...")
    final_payload = {
        "type": "Ares.PlayerSettings",
        "data": base64.b64encode(compressed).decode('utf-8'),
        "productId": "KeystoneClient"
    }

    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(final_payload, f, separators=(',', ':'))

    print(f"✅ SUCCESS! Saved injected payload to {output_file}")

if __name__ == "__main__":
    requests.packages.urllib3.disable_warnings()

    try:
        lock = get_lockfile_data()
        head = get_headers(lock)
        inject_crosshairs(head)
    except Exception as e:
        print(f"\n⚠ ⚠ CRITICAL ERROR: {str(e)}")

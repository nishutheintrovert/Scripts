import os
import base64
import json
import requests
import sys

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

def push_settings(headers):
    url = "https://valorant-settings-syncer.nishutheintrovert.workers.dev/settings/push"

    target_file = None
    is_injected = False

    if os.path.exists('crosshair-injected.json'):
        target_file = 'crosshair-injected.json'
        is_injected = True
    elif os.path.exists('valorant-settings.json'):
        target_file = 'valorant-settings.json'
    else:
        print("[!] Error: Neither crosshair-injected.json nor valorant-settings.json found!")
        return

    print(f"[1/2] Reading payload from {target_file}...")
    with open(target_file, 'r', encoding='utf-8') as f:
        payload_data = json.load(f)

    print("[2/2] Pushing preferences to Riot Cloud...")
    clean_payload = json.dumps(payload_data, separators=(',', ':'))

    response = requests.put(url, headers=headers, data=clean_payload)

    if response.status_code in [200, 204]:
        print(f"-> PUT Server Response Code: {response.status_code} [Success]")

        if is_injected:
            os.remove(target_file)
            print(f"-> Cleaned up old residue: {target_file}")

        print(f"✅ SUCCESS! Preferences from {target_file} pushed to cloud.")
    else:
        print(f"❎ PUT Server Response Code: {response.status_code} [Failed]")
        print(f"-> Error Details: {response.text[:300]}")

if __name__ == "__main__":
    requests.packages.urllib3.disable_warnings()

    try:
        lock = get_lockfile_data()
        head = get_headers(lock)
        push_settings(head)
    except Exception as e:
        print(f"\nCRITICAL ERROR: {str(e)}")

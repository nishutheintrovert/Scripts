import os
import base64
import json
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

def process_settings(headers):
    url = "https://valorant-settings-syncer.nishutheintrovert.workers.dev/settings/fetch"
    output_file = 'valorant-settings.json'

    response = requests.get(url, headers=headers)

    if response.status_code == 200:
        print(f"✅ GET Server Response Code: {response.status_code} [Success]")
    else:
        print(f"❎ GET Server Response Code: {response.status_code} [Failed]")
        print(f"Error Details: {response.text[:300]}")
        return

    payload = response.json()

    if 'data' not in payload:
        print("[!] Error: 'data' key not found in payload. This might be a fresh account with no settings.")
        return

    final_payload = {
        "type": "Ares.PlayerSettings",
        "data": payload['data'],
        "productId": "KeystoneClient"
    }

    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(final_payload, f, separators=(',', ':'))

    print(f"✅ SUCCESS! Saved payload to {output_file}")

if __name__ == "__main__":
    requests.packages.urllib3.disable_warnings()

    try:
        lock = get_lockfile_data()
        head = get_headers(lock)
        process_settings(head)
    except Exception as e:
        print(f"\n⚠ ⚠ CRITICAL ERROR: {str(e)}")

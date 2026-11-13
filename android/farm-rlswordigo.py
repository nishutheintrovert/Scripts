'''
    Author	: Nishikant Kanunje
    Date	: 09/09/2026
    Purpose	: Macro for RLSwordigo on non-rooted android using scrcpy-server and python
'''

'''
- Install scrcpy (Tested with v2.4)
https://scrcpy.org/download/
https://github.com/Genymobile/scrcpy

- Install Python 3.10.11
winget install Python.Python.3.10

- Install video library
python -m pip install av

- Install ADB Utilities
python -m pip install adbutils

- Install scrcpy-client naked
python -m pip install scrcpy-client --no-deps

- Install OpenCV module
python -m pip install opencv-python

'''

import scrcpy
import time

# --- CONFIGURATION ---
LEFT_X, LEFT_Y = 300, 1000
RIGHT_X, RIGHT_Y = 500, 1000
SWORD_X, SWORD_Y = 1800, 1000
JUMP_X, JUMP_Y = 2000, 1000
MAGIC_X, MAGIC_Y = 2200, 700

# scrcpy protocol constants for touch events
ACTION_DOWN = 0
ACTION_UP = 1
ACTION_MOVE = 2

def setup_client():
    """Initializes the headless scrcpy server on the phone."""
    # We do not map a video frame callback because we only need input injection
    client = scrcpy.Client()
    
    # Start the server connection in a background thread
    client.start(threaded=True)
    
    # Safety delay to ensure the Java server is fully initialized on the phone
    time.sleep(2)
    return client

def main():
    print("Pushing scrcpy-server to device... please wait.")
    client = setup_client()
    
    if not client.alive:
        print("Error: Failed to connect to device.")
        return

    print("Automation loop started. Press Ctrl+C to stop.")
    counter = 0
    
    try:
        while True:
            '''switch map'''
            client.control.touch(LEFT_X, LEFT_Y, ACTION_DOWN, touch_id=0)
            time.sleep(2)
            client.control.touch(LEFT_X, LEFT_Y, ACTION_UP, touch_id=0)

            time.sleep(0.05)
            
            '''run to middle'''
            client.control.touch(LEFT_X, LEFT_Y, ACTION_DOWN, touch_id=0)
            time.sleep(1.3)
            client.control.touch(LEFT_X, LEFT_Y, ACTION_UP, touch_id=0)

            time.sleep(1.3)

            '''jump over beetle'''
            client.control.touch(JUMP_X, JUMP_Y, ACTION_DOWN, touch_id=1)
            client.control.touch(LEFT_X, LEFT_Y, ACTION_DOWN, touch_id=0)
            time.sleep(0.5)
            client.control.touch(JUMP_X, JUMP_Y, ACTION_UP, touch_id=1)
            time.sleep(0.1)
            client.control.touch(JUMP_X, JUMP_Y, ACTION_DOWN, touch_id=1)
            time.sleep(0.1)
            client.control.touch(JUMP_X, JUMP_Y, ACTION_UP, touch_id=1)
            time.sleep(1.2)
            client.control.touch(LEFT_X, LEFT_Y, ACTION_UP, touch_id=0)

            '''kill beetle'''
            client.control.touch(RIGHT_X, RIGHT_Y, ACTION_DOWN, touch_id=0)
            time.sleep(0.1)
            client.control.touch(RIGHT_X, RIGHT_Y, ACTION_UP, touch_id=0)
            time.sleep(0.6)
            client.control.touch(SWORD_X, SWORD_Y, ACTION_DOWN, touch_id=1)
            time.sleep(0.1)
            client.control.touch(SWORD_X, SWORD_Y, ACTION_UP, touch_id=1)

            '''go left'''
            client.control.touch(LEFT_X, LEFT_Y, ACTION_DOWN, touch_id=0)
            time.sleep(2.1)
            client.control.touch(LEFT_X, LEFT_Y, ACTION_UP, touch_id=0)
            time.sleep(0.1)
            client.control.touch(JUMP_X, JUMP_Y, ACTION_DOWN, touch_id=1)
            client.control.touch(LEFT_X, LEFT_Y, ACTION_DOWN, touch_id=0)
            time.sleep(0.3)
            client.control.touch(JUMP_X, JUMP_Y, ACTION_UP, touch_id=1)
            client.control.touch(LEFT_X, LEFT_Y, ACTION_UP, touch_id=0)

            '''kill beetle'''
            client.control.touch(RIGHT_X, RIGHT_Y, ACTION_DOWN, touch_id=0)
            time.sleep(0.1)
            client.control.touch(RIGHT_X, RIGHT_Y, ACTION_UP, touch_id=0)
            time.sleep(0.1)
            client.control.touch(SWORD_X, SWORD_Y, ACTION_DOWN, touch_id=1)
            time.sleep(0.1)
            client.control.touch(SWORD_X, SWORD_Y, ACTION_UP, touch_id=1)

            '''jump left top'''
            client.control.touch(JUMP_X, JUMP_Y, ACTION_DOWN, touch_id=1)
            client.control.touch(LEFT_X, LEFT_Y, ACTION_DOWN, touch_id=0)
            time.sleep(0.6)
            client.control.touch(JUMP_X, JUMP_Y, ACTION_UP, touch_id=1)
            client.control.touch(LEFT_X, LEFT_Y, ACTION_UP, touch_id=0)
            time.sleep(6.0)

            '''jump right top'''
            client.control.touch(JUMP_X, JUMP_Y, ACTION_DOWN, touch_id=1)
            client.control.touch( RIGHT_X,  RIGHT_Y, ACTION_DOWN, touch_id=0)
            time.sleep(0.9)
            client.control.touch(JUMP_X, JUMP_Y, ACTION_UP, touch_id=1)
            client.control.touch( RIGHT_X,  RIGHT_Y, ACTION_UP, touch_id=0)
            time.sleep(3.0)

            '''drop bomb'''
            client.control.touch(MAGIC_X, MAGIC_Y, ACTION_DOWN, touch_id=1)
            time.sleep(0.1)
            client.control.touch(MAGIC_X, MAGIC_Y, ACTION_UP, touch_id=1)
            time.sleep(1.0)
            client.control.touch(SWORD_X, SWORD_Y, ACTION_DOWN, touch_id=1)
            time.sleep(0.1)
            client.control.touch(SWORD_X, SWORD_Y, ACTION_UP, touch_id=1)
            time.sleep(1.0)
            
            '''jump up'''
            client.control.touch(JUMP_X, JUMP_Y, ACTION_DOWN, touch_id=1)
            time.sleep(0.8)
            client.control.touch(JUMP_X, JUMP_Y, ACTION_UP, touch_id=1)
            time.sleep(0.1)
            client.control.touch(JUMP_X, JUMP_Y, ACTION_DOWN, touch_id=1)
            time.sleep(0.1)
            client.control.touch(JUMP_X, JUMP_Y, ACTION_UP, touch_id=1)
            time.sleep(2)

            '''drop bomb'''
            client.control.touch(MAGIC_X, MAGIC_Y, ACTION_DOWN, touch_id=1)
            time.sleep(0.1)
            client.control.touch(MAGIC_X, MAGIC_Y, ACTION_UP, touch_id=1)
            time.sleep(1.0)
            client.control.touch(SWORD_X, SWORD_Y, ACTION_DOWN, touch_id=1)
            time.sleep(0.1)
            client.control.touch(SWORD_X, SWORD_Y, ACTION_UP, touch_id=1)
            time.sleep(1.0)
            
            '''jump up'''
            client.control.touch(JUMP_X, JUMP_Y, ACTION_DOWN, touch_id=1)
            time.sleep(0.8)
            client.control.touch(JUMP_X, JUMP_Y, ACTION_UP, touch_id=1)
            time.sleep(0.1)
            client.control.touch(JUMP_X, JUMP_Y, ACTION_DOWN, touch_id=1)
            time.sleep(0.1)
            client.control.touch(JUMP_X, JUMP_Y, ACTION_UP, touch_id=1)
            time.sleep(2)

            '''switch map'''
            client.control.touch( RIGHT_X,  RIGHT_Y, ACTION_DOWN, touch_id=0)
            client.control.touch( RIGHT_X,  RIGHT_Y, ACTION_UP, touch_id=0)
            client.control.touch( RIGHT_X,  RIGHT_Y, ACTION_DOWN, touch_id=0)
            time.sleep(10.0)
            client.control.touch( RIGHT_X,  RIGHT_Y, ACTION_UP, touch_id=0)

            counter += 1
            print(f"Loops completed: {counter}")
            print("-" * 30)
            
    except KeyboardInterrupt:
        print("\nCtrl+C detected. Stopping automation...")
    finally:
        # Clean up the background Java server on the phone
        client.stop()
        print("Server cleaned up successfully.")

if __name__ == "__main__":
    main()

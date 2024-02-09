import os
import signal
import random
import time

restart_countdown = random.randint(600, 3600)

# Sleep for randomly picked seconds
time.sleep(restart_countdown)

print("Sending signal to stop container")
os.kill(1, signal.SIGUSR1)

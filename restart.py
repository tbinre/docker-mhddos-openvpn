import os
import signal
import random
import time

SESSION_TIME_MIN = os.getenv('SESSION_TIME_MIN', 2700)
SESSION_TIME_MAX = os.getenv('SESSION_TIME_MAX', 10800)

restart_countdown = random.randint(SESSION_TIME_MIN, SESSION_TIME_MAX)

# Sleep for randomly picked seconds
time.sleep(restart_countdown)

print("Sending signal to stop container")
os.kill(1, signal.SIGUSR1)

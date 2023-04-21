import asyncdispatch
from random import randomize, rand
from ../utils/config import config

proc execute*(jitter: int, interval: int): Future[bool] {.async.} =
    # Uses genSleepTime proc logic from 
    # ../utils/config.nim  
    
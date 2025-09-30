### Massive efficiency and performance improvements
These are pretty much the same changes I made with netcaps 1.5.0 so I'm not going to elaborate a ton here. 

- Caches IOHIDManager instance for dramatically better memory usage. 
- Sleeps for a little bit when idle, shouldn't impact performance visibly, but will save some CPU cycles when the disk isn't being used (Probably never).
- Also, I didn't mention this in the netcaps changelog, so better late than never, but when running in silent mode, the priority is reduced, no clue what impact this will have so YOLO. 
---
title: Test Steam Cloud Sync
created: 2025-06-02T00:04:22Z
aliases:
- Test Steam Cloud Sync
tags:
- steam
---

# Test Steam Cloud Sync

To test Steam Cloud Sync:

1. Open the Steam Console by navigating to [steam://open/console](steam://open/console) in a web browser.
2. If you haven't entered Enter `testappcloudpaths <application id>` into the console.
3. Enter `set_spew_level 4 4` into the console.  
4. Launch your app from Steam.

When you exit the game, you should see logs that seem similar to this:

```
[2025-06-01 15:13:50] [AppID 2840590] Starting sync (up,AC Exit,)
[2025-06-01 15:13:50] [AppID 2840590] Running AutoCloud on exit. Looking for new and updated files
[2025-06-01 15:13:50] [AppID 2840590]     Evaluating rule 0 with root="GameInstall" path="" pattern="save_*.bin"
[2025-06-01 15:13:50] [AppID 2840590]         Found 4 files that match /home/exodrifter/.local/share/Steam/steamapps/compatdata/2840590/pfx/drive_c/users/steamuser/Application Data/exodrifter/no-signal/save_*.bin
[2025-06-01 15:13:50] [AppID 2840590]     Persisting file /home/exodrifter/.local/share/Steam/steamapps/compatdata/2840590/pfx/drive_c/users/steamuser/Application Data/exodrifter/no-signal/save_1748814084.bin to the cloud
[2025-06-01 15:13:50] [AppID 2840590]	Skipping un-modified file save_1748814084.bin
[2025-06-01 15:13:50] [AppID 2840590]     Persisting file /home/exodrifter/.local/share/Steam/steamapps/compatdata/2840590/pfx/drive_c/users/steamuser/Application Data/exodrifter/no-signal/save_1748459546.bin to the cloud
[2025-06-01 15:13:50] [AppID 2840590]	Skipping un-modified file save_1748459546.bin
[2025-06-01 15:13:50] [AppID 2840590]     Persisting file /home/exodrifter/.local/share/Steam/steamapps/compatdata/2840590/pfx/drive_c/users/steamuser/Application Data/exodrifter/no-signal/save_1748815036.bin to the cloud
[2025-06-01 15:13:50] [AppID 2840590]	Skipping un-modified file save_1748815036.bin
[2025-06-01 15:13:50] [AppID 2840590]     Persisting file /home/exodrifter/.local/share/Steam/steamapps/compatdata/2840590/pfx/drive_c/users/steamuser/Application Data/exodrifter/no-signal/save_1748815022.bin to the cloud
[2025-06-01 15:13:50] [AppID 2840590]	Skipping un-modified file save_1748815022.bin
[2025-06-01 15:13:50] [AppID 2840590] AutoCloud complete
```

Notes:
1. On Linux, you can use Proton to test whether or not cloud saves are syncing correctly between Windows and Linux, but be aware that since the save files are in two locations on the same computer, Steam will think that the deleted saves are new files that you added on your computer when you switch back to the other installation instead of deleting them. [^2]

[^1]: [20250601101123](../entries/20250601101123.md)
[^2]: [20250601101803](../entries/20250601101803.md)

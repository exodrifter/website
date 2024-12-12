---
title: Export entire FL Studio project as MIDI file
created: 2024-12-12T02:50:15Z
aliases:
- Export entire FL Studio project as MIDI file
tags:
- fl-studio
- midi
---

# Export entire FL Studio project as MIDI file

To export the entire FL Studio project as a MIDI file, follow these steps: [^1]

1. Save your project.
2. (Optional) If you save compulsively, it may be wise to select `File > Save new version` before proceeding, as the following step cannot be undone.
3. Select `Tools > Macros > Prepare for MIDI export`. Note that this will turn every instrument into a MIDI Out instrument and that **this operation cannot be undone**.
4. Select `File > Export > MIDI File...`.

If you do not take these steps and you have no MIDI Out instruments, the MIDI File export operation will succeed but it will produce an empty MIDI file. [^1]

[^1]: [20241212024745](../entries/20241212024745.md)

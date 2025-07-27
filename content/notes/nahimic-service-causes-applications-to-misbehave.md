---
title: Nahimic services causes other applications to misbehave
created: 2025-07-26T14:24:47-07:00
modified: 2025-07-26T14:41:26-07:00
tags:
  - psychic-damage
---

# Nahimic services causes other applications to misbehave

The Nahimic service, which is sometimes included in "gaming" hardware by the manufacturer, can cause other applications like Prusa Slicer and Godot Engine to misbehave if it is installed and running. It also tries to inject itself into every application, for some reason, causing many issues in the software ecosystem. [^1] [^2]

To fix the issue as a user, find the Nahimic service and disable it. Unfortunately, vendors like MSi and Alienware package the Nahimic service along with their drivers, so it tends to get reinstalled on user's systems even after being disabled. [^1]

As a developer, you can fix this issue by adding the `NoHotFix` symbol to your application, which Nahimic will make sure doesn't exist before injecting itself. [^2]

[^1]: [20250726211819](../entries/20250726211819.md)
[^2]: [20250726213149](../entries/20250726213149.md)

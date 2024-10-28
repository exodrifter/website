---
title: Arbitrary Code Execution in Godot serialization
created: 2024-06-19T00:12:54Z
modified: 2024-10-28T04:35:27Z
alias:
- Arbitrary Code Execution in Godot serialization
tags:
- godot
---

# Arbitrary Code Execution in Godot serialization

Many Godot functions allow for arbitrary code execution when a file is deserialized due to the fact that [Godot always runs scripts in deserialized resources](godot-runs-scripts-in-resources.md). To avoid this vulnerability, you can use `get_var` and `store_var` from `FileAccess`. [^1]

# History

[^1]: [20240620003315](../entries/20240620003315.md)

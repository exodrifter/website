---
title: Arbitrary Code Execution in Godot serialization
alias:
- Arbitrary Code Execution in Godot serialization
tags:
- godot
---

# Arbitrary Code Execution in Godot serialization

Many Godot functions allow for arbitrary code execution when a file is loaded. To avoid this vulnerability, you can use `get_var` and `store_var` from `FileAccess`.

# History

- [20240620003315](../entries/20240620003315.md)

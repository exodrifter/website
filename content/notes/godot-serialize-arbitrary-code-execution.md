---
alias:
- Arbitrary Code Execution in Godot serialization
---

# Arbitrary Code Execution in Godot serialization

Many Godot functions allow for arbitrary code execution when a file is loaded. To avoid this vulnerability, you can use `get_var` and `store_var` from `FileAccess`.

## History

![20240619_243315](../entries/20240619_243315.md)

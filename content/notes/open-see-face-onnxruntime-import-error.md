---
title: OpenSeeFace onnxruntime ImportError
created: 2025-02-21T03:01:10Z
aliases:
- OpenSeeFace onnxruntime ImportError
---

# OpenSeeFace onnxruntime ImportError

When trying to run OpenSeeFace, you might run into the following error: [^1]

```
Traceback (most recent call last):
  File "/home/exodrifter/bin/vsf/OpenSeeFace/facetracker.py", line 132, in <module>
    from tracker import Tracker, get_model_base_path
  File "/home/exodrifter/bin/vsf/OpenSeeFace/tracker.py", line 5, in <module>
    import onnxruntime
  File "/home/exodrifter/bin/vsf/venv/lib/python3.9/site-packages/onnxruntime/__init__.p
y", line 35, in <module>
    raise import_capi_exception
  File "/home/exodrifter/bin/vsf/venv/lib/python3.9/site-packages/onnxruntime/__init__.p
y", line 23, in <module>
    from onnxruntime.capi._pybind_state import get_all_providers, get_available_provider
s, get_device, set_seed, \
  File "/home/exodrifter/bin/vsf/venv/lib/python3.9/site-packages/onnxruntime/capi/_pybi
nd_state.py", line 32, in <module>
    from .onnxruntime_pybind11_state import *  # noqa
ImportError: /home/exodrifter/bin/vsf/venv/lib/python3.9/site-packages/onnxruntime/capi/
onnxruntime_pybind11_state.cpython-39-x86_64-linux-gnu.so: cannot enable executable stac
k as shared object requires: Invalid argument
```

In this case, the likely issue is that the dependencies are out of date. Try updating the dependencies: [^1]

```sh
pip3.9 install --upgrade onnxruntime opencv-python pillow numpy
```

And update OpenSeeFace: [^1]

```
cd path/to/OpenSeeFace
git pull
```

[^1]: [20250220191611](../entries/20250220191611.md)

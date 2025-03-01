"""
load library for lowlevel FUSE implementation
"""

import os

BORK_FUSE_IMPL = os.environ.get("BORK_FUSE_IMPL", "pyfuse3,llfuse")

for FUSE_IMPL in BORK_FUSE_IMPL.split(","):
    FUSE_IMPL = FUSE_IMPL.strip()
    if FUSE_IMPL == "pyfuse3":
        try:
            import pyfuse3 as llfuse
        except ImportError:
            pass
        else:
            has_llfuse = False
            has_pyfuse3 = True
            break
    elif FUSE_IMPL == "llfuse":
        try:
            import llfuse
        except ImportError:
            pass
        else:
            has_llfuse = True
            has_pyfuse3 = False
            break
    elif FUSE_IMPL == "none":
        pass
    else:
        raise RuntimeError("unknown fuse implementation in BORK_FUSE_IMPL: '%s'" % BORK_FUSE_IMPL)
else:
    llfuse = None  # noqa
    has_llfuse = False
    has_pyfuse3 = False

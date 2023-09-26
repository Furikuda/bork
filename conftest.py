import os
from typing import Optional

import pytest

from bork.testsuite.archiver import BORK_EXES

if hasattr(pytest, "register_assert_rewrite"):
    pytest.register_assert_rewrite("bork.testsuite")


import bork.cache  # noqa: E402
from bork.archiver import Archiver
from bork.logger import setup_logging  # noqa: E402

# Ensure that the loggers exist for all tests
setup_logging()

from bork.testsuite import has_lchflags, has_llfuse, has_pyfuse3  # noqa: E402
from bork.testsuite import are_symlinks_supported, are_hardlinks_supported, is_utime_fully_supported  # noqa: E402
from bork.testsuite.platform import fakeroot_detected  # noqa: E402


@pytest.fixture(autouse=True)
def clean_env(tmpdir_factory, monkeypatch):
    # also avoid to use anything from the outside environment:
    keys = [key for key in os.environ if key.startswith("BORK_") and key not in ("BORK_FUSE_IMPL",)]
    for key in keys:
        monkeypatch.delenv(key, raising=False)
    # avoid that we access / modify the user's normal .config / .cache directory:
    monkeypatch.setenv("BORK_BASE_DIR", str(tmpdir_factory.mktemp("bork-base-dir")))
    # Speed up tests
    monkeypatch.setenv("BORK_TESTONLY_WEAKEN_KDF", "1")


def pytest_report_header(config, startdir):
    tests = {
        "BSD flags": has_lchflags,
        "fuse2": has_llfuse,
        "fuse3": has_pyfuse3,
        "root": not fakeroot_detected(),
        "symlinks": are_symlinks_supported(),
        "hardlinks": are_hardlinks_supported(),
        "atime/mtime": is_utime_fully_supported(),
        "modes": "BORK_TESTS_IGNORE_MODES" not in os.environ,
    }
    enabled = []
    disabled = []
    for test in tests:
        if tests[test]:
            enabled.append(test)
        else:
            disabled.append(test)
    output = "Tests enabled: " + ", ".join(enabled) + "\n"
    output += "Tests disabled: " + ", ".join(disabled)
    return output


class DefaultPatches:
    def __init__(self, request):
        self.org_cache_wipe_cache = bork.cache.LocalCache.wipe_cache

        def wipe_should_not_be_called(*a, **kw):
            raise AssertionError(
                "Cache wipe was triggered, if this is part of the test add " "@pytest.mark.allow_cache_wipe"
            )

        if "allow_cache_wipe" not in request.keywords:
            bork.cache.LocalCache.wipe_cache = wipe_should_not_be_called
        request.addfinalizer(self.undo)

    def undo(self):
        bork.cache.LocalCache.wipe_cache = self.org_cache_wipe_cache


@pytest.fixture(autouse=True)
def default_patches(request):
    return DefaultPatches(request)


@pytest.fixture()
def set_env_variables():
    os.environ["BORK_CHECK_I_KNOW_WHAT_I_AM_DOING"] = "YES"
    os.environ["BORK_DELETE_I_KNOW_WHAT_I_AM_DOING"] = "YES"
    os.environ["BORK_PASSPHRASE"] = "waytooeasyonlyfortests"
    os.environ["BORK_SELFTEST"] = "disabled"


class ArchiverSetup:
    EXE: str = None  # python source based
    FORK_DEFAULT = False
    BORK_EXES = []

    def __init__(self):
        self.archiver = None
        self.tmpdir: Optional[str] = None
        self.repository_path: Optional[str] = None
        self.repository_location: Optional[str] = None
        self.input_path: Optional[str] = None
        self.output_path: Optional[str] = None
        self.keys_path: Optional[str] = None
        self.cache_path: Optional[str] = None
        self.exclude_file_path: Optional[str] = None
        self.patterns_file_path: Optional[str] = None

    def get_kind(self) -> str:
        if self.repository_location.startswith("ssh://__testsuite__"):
            return "remote"
        elif self.EXE == "bork.exe":
            return "binary"
        else:
            return "local"


@pytest.fixture()
def archiver(tmp_path, set_env_variables):
    archiver = ArchiverSetup()
    archiver.archiver = not archiver.FORK_DEFAULT and Archiver() or None
    archiver.tmpdir = tmp_path
    archiver.repository_path = os.fspath(tmp_path / "repository")
    archiver.repository_location = archiver.repository_path
    archiver.input_path = os.fspath(tmp_path / "input")
    archiver.output_path = os.fspath(tmp_path / "output")
    archiver.keys_path = os.fspath(tmp_path / "keys")
    archiver.cache_path = os.fspath(tmp_path / "cache")
    archiver.exclude_file_path = os.fspath(tmp_path / "excludes")
    archiver.patterns_file_path = os.fspath(tmp_path / "patterns")
    os.environ["BORK_KEYS_DIR"] = archiver.keys_path
    os.environ["BORK_CACHE_DIR"] = archiver.cache_path
    os.mkdir(archiver.input_path)
    os.chmod(archiver.input_path, 0o777)  # avoid troubles with fakeroot / FUSE
    os.mkdir(archiver.output_path)
    os.mkdir(archiver.keys_path)
    os.mkdir(archiver.cache_path)
    with open(archiver.exclude_file_path, "wb") as fd:
        fd.write(b"input/file2\n# A comment line, then a blank line\n\n")
    with open(archiver.patterns_file_path, "wb") as fd:
        fd.write(b"+input/file_important\n- input/file*\n# A comment line, then a blank line\n\n")
    old_wd = os.getcwd()
    os.chdir(archiver.tmpdir)
    yield archiver
    os.chdir(old_wd)


@pytest.fixture()
def remote_archiver(archiver):
    archiver.repository_location = "ssh://__testsuite__" + str(archiver.repository_path)
    yield archiver


@pytest.fixture()
def binary_archiver(archiver):
    if "binary" not in BORK_EXES:
        pytest.skip("No bork.exe binary available")
    archiver.EXE = "bork.exe"
    archiver.FORK_DEFAULT = True
    yield archiver

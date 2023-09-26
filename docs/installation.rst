.. include:: global.rst.inc
.. highlight:: bash
.. _installation:

Installation
============

There are different ways to install Bork:

- :ref:`distribution-package` - easy and fast if a package is
  available from your distribution.
- :ref:`pyinstaller-binary` - easy and fast, we provide a ready-to-use binary file
  that comes bundled with all dependencies.
- :ref:`source-install`, either:

  - :ref:`windows-binary` - builds a binary file for Windows using MSYS2.
  - :ref:`pip-installation` - installing a source package with pip needs
    more installation steps and requires all dependencies with
    development headers and a compiler.
  - :ref:`git-installation`  - for developers and power users who want to
    have the latest code or use revision control (each release is
    tagged).

.. _distribution-package:

Distribution Package
--------------------

Some distributions might offer a ready-to-use ``borkbackup``
package which can be installed with the package manager.

.. important:: Those packages may not be up to date with the latest
               Bork releases. Before submitting a bug
               report, check the package version and compare that to
               our latest release then review :doc:`changes` to see if
               the bug has been fixed. Report bugs to the package
               maintainer rather than directly to Bork if the
               package is out of date in the distribution.

.. keep this list in alphabetical order

============ ============================================= =======
Distribution Source                                        Command
============ ============================================= =======
Alpine Linux `Alpine repository`_                          ``apk add borkbackup``
Arch Linux   `[community]`_                                ``pacman -S bork``
Debian       `Debian packages`_                            ``apt install borkbackup``
Gentoo       `ebuild`_                                     ``emerge borkbackup``
GNU Guix     `GNU Guix`_                                   ``guix package --install bork``
Fedora/RHEL  `Fedora official repository`_                 ``dnf install borkbackup``
FreeBSD      `FreeBSD ports`_                              ``cd /usr/ports/archivers/py-borkbackup && make install clean``
macOS        `Homebrew`_                                   | ``brew install borkbackup`` (official formula, **no** FUSE support)
                                                           | **or**
                                                           | ``brew install --cask macfuse`` (`private Tap`_, FUSE support)
                                                           | ``brew install borkbackup/tap/borkbackup-fuse``
Mageia       `cauldron`_                                   ``urpmi borkbackup``
NetBSD       `pkgsrc`_                                     ``pkg_add py-borkbackup``
NixOS        `.nix file`_                                  ``nix-env -i borkbackup``
OpenBSD      `OpenBSD ports`_                              ``pkg_add borkbackup``
OpenIndiana  `OpenIndiana hipster repository`_             ``pkg install bork``
openSUSE     `openSUSE official repository`_               ``zypper in borkbackup``
Raspbian     `Raspbian testing`_                           ``apt install borkbackup``
Ubuntu       `Ubuntu packages`_, `Ubuntu PPA`_             ``apt install borkbackup``
============ ============================================= =======

.. _Alpine repository: https://pkgs.alpinelinux.org/packages?name=borkbackup
.. _[community]: https://www.archlinux.org/packages/?name=bork
.. _Debian packages: https://packages.debian.org/search?keywords=borkbackup&searchon=names&exact=1&suite=all&section=all
.. _Fedora official repository: https://packages.fedoraproject.org/pkgs/borkbackup/borkbackup/
.. _FreeBSD ports: https://www.freshports.org/archivers/py-borkbackup/
.. _ebuild: https://packages.gentoo.org/packages/app-backup/borkbackup
.. _GNU Guix: https://www.gnu.org/software/guix/package-list.html#bork
.. _pkgsrc: http://pkgsrc.se/sysutils/py-borkbackup
.. _cauldron: http://madb.mageia.org/package/show/application/0/release/cauldron/name/borkbackup
.. _.nix file: https://github.com/NixOS/nixpkgs/blob/master/pkgs/tools/backup/borkbackup/default.nix
.. _OpenBSD ports: https://cvsweb.openbsd.org/cgi-bin/cvsweb/ports/sysutils/borkbackup/
.. _OpenIndiana hipster repository: https://pkg.openindiana.org/hipster/en/search.shtml?token=bork&action=Search
.. _openSUSE official repository: https://software.opensuse.org/package/borkbackup
.. _Homebrew: https://formulae.brew.sh/formula/borkbackup
.. _private Tap: https://github.com/borkbackup/homebrew-tap
.. _Raspbian testing: https://archive.raspbian.org/raspbian/pool/main/b/borkbackup/
.. _Ubuntu packages: https://launchpad.net/ubuntu/+source/borkbackup
.. _Ubuntu PPA: https://launchpad.net/~costamagnagianfranco/+archive/ubuntu/borkbackup

Please ask package maintainers to build a package or, if you can package /
submit it yourself, please help us with that! See :issue:`105` on
github to followup on packaging efforts.

**Current status of package in the repositories**

.. start-badges

|Packaging status|

.. |Packaging status| image:: https://repology.org/badge/vertical-allrepos/borkbackup.svg
        :alt: Packaging status
        :target: https://repology.org/project/borkbackup/versions

.. end-badges

.. _pyinstaller-binary:

Standalone Binary
-----------------

.. note:: Releases are signed with an OpenPGP key, see
          :ref:`security-contact` for more instructions.

Bork x86/x64 amd/intel compatible binaries (generated with `pyinstaller`_)
are available on the releases_ page for the following platforms:

* **Linux**: glibc >= 2.28 (ok for most supported Linux releases).
  Older glibc releases are untested and may not work.
* **MacOS**: 10.12 or newer (To avoid signing issues download the file via
  command line **or** remove the ``quarantine`` attribute after downloading:
  ``$ xattr -dr com.apple.quarantine bork-macosx64.tgz``)
* **FreeBSD**: 12.1 (unknown whether it works for older releases)

ARM binaries are built by Johann Bauer, see: https://bork.bauerj.eu/

To install such a binary, just drop it into a directory in your ``PATH``,
make bork readable and executable for its users and then you can run ``bork``::

    sudo cp bork-linux64 /usr/local/bin/bork
    sudo chown root:root /usr/local/bin/bork
    sudo chmod 755 /usr/local/bin/bork

Optionally you can create a symlink to have ``borkfs`` available, which is an
alias for ``bork mount``::

    ln -s /usr/local/bin/bork /usr/local/bin/borkfs

Note that the binary uses /tmp to unpack Bork with all dependencies. It will
fail if /tmp has not enough free space or is mounted with the ``noexec``
option. You can change the temporary directory by setting the ``TEMP``
environment variable before running Bork.

If a new version is released, you will have to download it manually and replace
the old version using the same steps as shown above.

.. _pyinstaller: http://www.pyinstaller.org
.. _releases: https://github.com/furikuda/bork/releases

.. _source-install:

From Source
-----------

.. note::

  Some older Linux systems (like RHEL/CentOS 5) and Python interpreter binaries
  compiled to be able to run on such systems (like Python installed via Anaconda)
  might miss functions required by Bork.

  This issue will be detected early and Bork will abort with a fatal error.

Dependencies
~~~~~~~~~~~~

To install Bork from a source package (including pip), you have to install the
following dependencies first:

* `Python 3`_ >= 3.9.0, plus development headers.
* Libraries (library plus development headers):

  - OpenSSL_ >= 1.1.1 (LibreSSL will not work)
  - libacl_ (which depends on libattr_)
  - liblz4_ >= 1.7.0 (r129)
  - libzstd_ >= 1.3.0
  - libxxhash >= 0.8.1 (0.8.0 might work also)
* pkg-config (cli tool) and pkgconfig python package (bork uses these to
  discover header and library location - if it can't import pkgconfig and
  is not pointed to header/library locations via env vars [see setup.py],
  it will raise a fatal error).
  **These must be present before invoking setup.py!**
* some other Python dependencies, pip will automatically install them for you.
* optionally, if you wish to mount an archive as a FUSE filesystem, you need
  a FUSE implementation for Python:

  - Either pyfuse3_ (preferably, newer) or llfuse_ (older).
    See also the BORK_FUSE_IMPL env variable.
  - See setup.py about the version requirements.

If you have troubles finding the right package names, have a look at the
distribution specific sections below or the Vagrantfile in the git repository,
which contains installation scripts for a number of operating systems.

In the following, the steps needed to install the dependencies are listed for a
selection of platforms. If your distribution is not covered by these
instructions, try to use your package manager to install the dependencies.  On
FreeBSD, you may need to get a recent enough OpenSSL version from FreeBSD
ports.

After you have installed the dependencies, you can proceed with steps outlined
under :ref:`pip-installation`.

Debian / Ubuntu
+++++++++++++++

Install the dependencies with development headers::

    sudo apt-get install python3 python3-dev python3-pip python3-virtualenv \
    libacl1-dev libacl1 \
    libssl-dev \
    liblz4-dev libzstd-dev libxxhash-dev \
    build-essential \
    pkg-config python3-pkgconfig
    sudo apt-get install libfuse-dev fuse    # needed for llfuse
    sudo apt-get install libfuse3-dev fuse3  # needed for pyfuse3

In case you get complaints about permission denied on ``/etc/fuse.conf``: on
Ubuntu this means your user is not in the ``fuse`` group. Add yourself to that
group, log out and log in again.

Fedora
++++++

Install the dependencies with development headers::

    sudo dnf install python3 python3-devel python3-pip python3-virtualenv \
    libacl-devel libacl \
    openssl-devel \
    lz4-devel libzstd-devel xxhash-devel \
    pkgconf python3-pkgconfig
    sudo dnf install gcc gcc-c++ redhat-rpm-config
    sudo dnf install fuse-devel fuse         # needed for llfuse
    sudo dnf install fuse3-devel fuse3       # needed for pyfuse3

openSUSE Tumbleweed / Leap
++++++++++++++++++++++++++

Install the dependencies automatically using zypper::

    sudo zypper source-install --build-deps-only borkbackup

Alternatively, you can enumerate all build dependencies in the command line::

    sudo zypper install python3 python3-devel \
    libacl-devel openssl-devel libxxhash-devel \
    python3-Cython python3-Sphinx python3-msgpack-python python3-pkgconfig pkgconf \
    python3-pytest python3-setuptools python3-setuptools_scm \
    python3-sphinx_rtd_theme gcc gcc-c++
    sudo zypper install python3-llfuse  # llfuse

macOS
+++++

When installing via Homebrew_, dependencies are installed automatically. To install
dependencies manually::

    brew install python3 openssl zstd lz4 xxhash
    brew install pkg-config
    pip3 install virtualenv pkgconfig

For FUSE support to mount the backup archives, you need at least version 3.0 of
macFUSE, which is available via `github
<https://github.com/osxfuse/osxfuse/releases/latest>`__, or Homebrew::

    brew install --cask macfuse

When installing Bork via ``pip``, be sure to install the ``llfuse`` extra,
since macFUSE only supports FUSE API v2. Also, since Homebrew won't link
the installed ``openssl`` formula, point pkg-config to the correct path::

    PKG_CONFIG_PATH="/usr/local/opt/openssl@1.1/lib/pkgconfig" pip install borkbackup[llfuse]

Be aware that for all recent macOS releases you must authorize full disk access.
It is no longer sufficient to run bork backups as root. If you have not yet
granted full disk access, and you run Bork backup from cron, you will see
messages such as::

    /Users/you/Pictures/Photos Library.photoslibrary: scandir: [Errno 1] Operation not permitted:

To fix this problem, you should grant full disk access to cron, and to your
Terminal application. More information `can be found here
<https://osxdaily.com/2020/04/27/fix-cron-permissions-macos-full-disk-access/>`__.

FreeBSD
++++++++

Listed below are packages you will need to install Bork, its dependencies,
and commands to make FUSE work for using the mount command.

::

     pkg install -y python3 pkgconf
     pkg install openssl
     pkg install liblz4 zstd xxhash
     pkg install fusefs-libs  # needed for llfuse
     pkg install -y git
     python3 -m ensurepip # to install pip for Python3
     To use the mount command:
     echo 'fuse_load="YES"' >> /boot/loader.conf
     echo 'vfs.usermount=1' >> /etc/sysctl.conf
     kldload fuse
     sysctl vfs.usermount=1

.. _windows_deps:

Windows
+++++++

.. note::
    Running under Windows is experimental.

.. warning::
    This script needs to be run in the UCRT64 environment in MSYS2.

Install the dependencies with the provided script::

    ./scripts/msys2-install-deps

Windows 10's Linux Subsystem
++++++++++++++++++++++++++++

.. note::
    Running under Windows 10's Linux Subsystem is experimental and has not been tested much yet.

Just follow the Ubuntu Linux installation steps. You can omit the FUSE stuff, it won't work anyway.


Cygwin
++++++

.. note::
    Running under Cygwin is experimental and has not been tested much yet.

Use the Cygwin installer to install the dependencies::

    python39 python39-devel python39-pkgconfig
    python39-setuptools python39-pip python39-wheel python39-virtualenv
    libssl-devel libxxhash-devel liblz4-devel libzstd-devel
    binutils gcc-g++ git make openssh


.. _windows-binary:

Building a binary on Windows
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. note::
    This is experimental.

.. warning::
    This needs to be run in the UCRT64 environment in MSYS2.

Ensure to install the dependencies as described within :ref:`Dependencies: Windows <windows_deps>`.

::

    export SETUPTOOLS_USE_DISTUTILS=stdlib # Needed for pip to work - https://www.msys2.org/docs/python/#known-issues
    pip install -e .
    pyinstaller -y scripts/bork.exe.spec

A standalone executable will be created in ``dist/bork.exe``.

.. _pip-installation:

Using pip
~~~~~~~~~

Virtualenv_ can be used to build and install Bork without affecting
the system Python or requiring root access.  Using a virtual environment is
optional, but recommended except for the most simple use cases.

Ensure to install the dependencies as described within :ref:`source-install`.

.. note::
    If you install into a virtual environment, you need to **activate** it
    first (``source bork-env/bin/activate``), before running ``bork``.
    Alternatively, symlink ``bork-env/bin/bork`` into some directory that is in
    your ``PATH`` so you can run ``bork``.

This will use ``pip`` to install the latest release from PyPi::

    virtualenv --python=python3 bork-env
    source bork-env/bin/activate

    # might be required if your tools are outdated
    pip install -U pip setuptools wheel

    # pkgconfig MUST be available before bork is installed!
    pip install pkgconfig

    # install Bork + Python dependencies into virtualenv
    pip install borkbackup
    # or alternatively (if you want FUSE support):
    pip install borkbackup[llfuse]  # to use llfuse
    pip install borkbackup[pyfuse3]  # to use pyfuse3

To upgrade Bork to a new version later, run the following after
activating your virtual environment::

    pip install -U borkbackup  # or ... borkbackup[llfuse/pyfuse3]

When doing manual pip installation, man pages are not automatically
installed.  You can run these commands to install the man pages
locally::

    # get bork from github
    git clone https://github.com/furikuda/bork.git bork

    # Install the files with proper permissions
    install -D -m 0644 bork/docs/man/bork*.1* $HOME/.local/share/man/man1/bork.1

    # Update the man page cache
    mandb

.. _git-installation:

Using git
~~~~~~~~~

This uses latest, unreleased development code from git.
While we try not to break master, there are no guarantees on anything.

Ensure to install the dependencies as described within :ref:`source-install`.

::

    # get bork from github
    git clone https://github.com/furikuda/bork.git

    # create a virtual environment
    virtualenv --python=$(which python3) bork-env
    source bork-env/bin/activate   # always before using!

    # install bork + dependencies into virtualenv
    cd bork
    pip install -r requirements.d/development.txt
    pip install -r requirements.d/docs.txt  # optional, to build the docs

    pip install -e .           # in-place editable mode
    or
    pip install -e .[pyfuse3]  # in-place editable mode, use pyfuse3
    or
    pip install -e .[llfuse]   # in-place editable mode, use llfuse

    # optional: run all the tests, on all installed Python versions
    # requires fakeroot, available through your package manager
    fakeroot -u tox --skip-missing-interpreters

By default the system installation of python will be used.
If you need to use a different version of Python you can install this using ``pyenv``:

::

    ...
    # create a virtual environment
    pyenv install 3.9.0  # minimum, preferably use something more recent!
    pyenv global 3.9.0
    pyenv local 3.9.0
    virtualenv --python=${pyenv which python} bork-env
    source bork-env/bin/activate   # always before using!
    ...

.. note:: As a developer or power user, you should always use a virtual environment.

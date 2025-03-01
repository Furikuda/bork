This is bork2!
--------------

Please note that this is the README for bork2 / master branch.

bork2 is currently in beta testing.

For the stable version's docs, please see there:

https://borkbackup.readthedocs.io/en/stable/

TODO: the screencasts need a remake using bork2, see there:

https://github.com/furikuda/bork/issues/6303


What is BorkBackup?
-------------------

BorkBackup (short: Bork) is a deduplicating backup program.
Optionally, it supports compression and authenticated encryption.

The main goal of Bork is to provide an efficient and secure way to back up data.
The data deduplication technique used makes Bork suitable for daily backups
since only changes are stored.
The authenticated encryption technique makes it suitable for backups to targets not
fully trusted.

See the `installation manual`_ or, if you have already
downloaded Bork, ``docs/installation.rst`` to get started with Bork.
There is also an `offline documentation`_ available, in multiple formats.

.. _installation manual: https://borkbackup.readthedocs.org/en/stable/installation.html
.. _offline documentation: https://readthedocs.org/projects/borkbackup/downloads

Main features
~~~~~~~~~~~~~

**Space efficient storage**
  Deduplication based on content-defined chunking is used to reduce the number
  of bytes stored: each file is split into a number of variable length chunks
  and only chunks that have never been seen before are added to the repository.

  A chunk is considered duplicate if its id_hash value is identical.
  A cryptographically strong hash or MAC function is used as id_hash, e.g.
  (hmac-)sha256.

  To deduplicate, all the chunks in the same repository are considered, no
  matter whether they come from different machines, from previous backups,
  from the same backup or even from the same single file.

  Compared to other deduplication approaches, this method does NOT depend on:

  * file/directory names staying the same: So you can move your stuff around
    without killing the deduplication, even between machines sharing a repo.

  * complete files or time stamps staying the same: If a big file changes a
    little, only a few new chunks need to be stored - this is great for VMs or
    raw disks.

  * The absolute position of a data chunk inside a file: Stuff may get shifted
    and will still be found by the deduplication algorithm.

**Speed**
  * performance-critical code (chunking, compression, encryption) is
    implemented in C/Cython
  * local caching of files/chunks index data
  * quick detection of unmodified files

**Data encryption**
    All data can be protected client-side using 256-bit authenticated encryption
    (AES-OCB or chacha20-poly1305), ensuring data confidentiality, integrity and
    authenticity.

**Obfuscation**
    Optionally, bork can actively obfuscate e.g. the size of files / chunks to
    make fingerprinting attacks more difficult.

**Compression**
    All data can be optionally compressed:

    * lz4 (super fast, low compression)
    * zstd (wide range from high speed and low compression to high compression
      and lower speed)
    * zlib (medium speed and compression)
    * lzma (low speed, high compression)

**Off-site backups**
    Bork can store data on any remote host accessible over SSH.  If Bork is
    installed on the remote host, big performance gains can be achieved
    compared to using a network filesystem (sshfs, nfs, ...).

**Backups mountable as filesystems**
    Backup archives are mountable as userspace filesystems for easy interactive
    backup examination and restores (e.g. by using a regular file manager).

**Easy installation on multiple platforms**
    We offer single-file binaries that do not require installing anything -
    you can just run them on these platforms:

    * Linux
    * macOS
    * FreeBSD
    * OpenBSD and NetBSD (no xattrs/ACLs support or binaries yet)
    * Cygwin (experimental, no binaries yet)
    * Linux Subsystem of Windows 10 (experimental)

**Free and Open Source Software**
  * security and functionality can be audited independently
  * licensed under the BSD (3-clause) license, see `License`_ for the
    complete license

Easy to use
~~~~~~~~~~~

For ease of use, set the BORK_REPO environment variable::

    $ export BORK_REPO=/path/to/repo

Create a new backup repository (see ``bork rcreate --help`` for encryption options)::

    $ bork rcreate -e repokey-aes-ocb

Create a new backup archive::

    $ bork create Monday1 ~/Documents

Now doing another backup, just to show off the great deduplication::

    $ bork create -v --stats Monday2 ~/Documents
    Repository: /path/to/repo
    Archive name: Monday2
    Archive fingerprint: 7714aef97c1a24539cc3dc73f79b060f14af04e2541da33d54c7ee8e81a00089
    Time (start): Mon, 2022-10-03 19:57:35 +0200
    Time (end):   Mon, 2022-10-03 19:57:35 +0200
    Duration: 0.01 seconds
    Number of files: 24
    Original size: 29.73 MB
    Deduplicated size: 520 B


Helping, Donations and Bounties, becoming a Patron
--------------------------------------------------

Your help is always welcome!

Spread the word, give feedback, help with documentation, testing or development.

You can also give monetary support to the project, see there for details:

https://www.borkbackup.org/support/fund.html

Links
-----

* `Main Web Site <https://borkbackup.readthedocs.org/>`_
* `Releases <https://github.com/furikuda/bork/releases>`_,
  `PyPI packages <https://pypi.python.org/pypi/borkbackup>`_ and
  `ChangeLog <https://github.com/furikuda/bork/blob/master/docs/changes.rst>`_
* `Offline Documentation <https://readthedocs.org/projects/borkbackup/downloads>`_
* `GitHub <https://github.com/furikuda/bork>`_ and
  `Issue Tracker <https://github.com/furikuda/bork/issues>`_.
* `Web-Chat (IRC) <https://web.libera.chat/#borkbackup>`_ and
  `Mailing List <https://mail.python.org/mailman/listinfo/borkbackup>`_
* `License <https://borkbackup.readthedocs.org/en/stable/authors.html#license>`_
* `Security contact <https://borkbackup.readthedocs.io/en/latest/support.html#security-contact>`_

Compatibility notes
-------------------

EXPECT THAT WE WILL BREAK COMPATIBILITY REPEATEDLY WHEN MAJOR RELEASE NUMBER
CHANGES (like when going from 0.x.y to 1.0.0 or from 1.x.y to 2.0.0).

NOT RELEASED DEVELOPMENT VERSIONS HAVE UNKNOWN COMPATIBILITY PROPERTIES.

THIS IS SOFTWARE IN DEVELOPMENT, DECIDE YOURSELF WHETHER IT FITS YOUR NEEDS.

Security issues should be reported to the `Security contact`_ (or
see ``docs/support.rst`` in the source distribution).

.. start-badges

|doc| |build| |coverage| |bestpractices| |bounties|

.. |bounties| image:: https://api.bountysource.com/badge/team?team_id=78284&style=bounties_posted
        :alt: Bounty Source
        :target: https://www.bountysource.com/teams/borkbackup

.. |doc| image:: https://readthedocs.org/projects/borkbackup/badge/?version=stable
        :alt: Documentation
        :target: https://borkbackup.readthedocs.org/en/stable/

.. |build| image:: https://github.com/furikuda/bork/workflows/CI/badge.svg?branch=master
        :alt: Build Status (master)
        :target: https://github.com/furikuda/bork/actions

.. |coverage| image:: https://codecov.io/github/furikuda/bork/coverage.svg?branch=master
        :alt: Test Coverage
        :target: https://codecov.io/github/furikuda/bork?branch=master

.. |screencast_basic| image:: https://asciinema.org/a/133292.png
        :alt: BorkBackup Basic Usage
        :target: https://asciinema.org/a/133292?autoplay=1&speed=1
        :width: 100%

.. _installation: https://asciinema.org/a/133291?autoplay=1&speed=1

.. _advanced usage: https://asciinema.org/a/133293?autoplay=1&speed=1

.. |bestpractices| image:: https://bestpractices.coreinfrastructure.org/projects/271/badge
        :alt: Best Practices Score
        :target: https://bestpractices.coreinfrastructure.org/projects/271

.. end-badges

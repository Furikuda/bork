.. include:: mount.rst.inc

.. include:: umount.rst.inc

Examples
~~~~~~~~

::

    # Mounting the repository shows all archives.
    # Archives are loaded lazily, expect some delay when navigating to an archive
    # for the first time.
    $ bork mount /tmp/mymountpoint
    $ ls /tmp/mymountpoint
    root-2016-02-14 root-2016-02-15
    $ bork umount /tmp/mymountpoint

    # The "versions view" merges all archives in the repository
    # and provides a versioned view on files.
    $ bork mount -o versions /tmp/mymountpoint
    $ ls -l /tmp/mymountpoint/home/user/doc.txt/
    total 24
    -rw-rw-r-- 1 user group 12357 Aug 26 21:19 doc.cda00bc9.txt
    -rw-rw-r-- 1 user group 12204 Aug 26 21:04 doc.fa760f28.txt
    $ bork umount /tmp/mymountpoint

    # Archive filters are supported.
    # These are especially handy for the "versions view",
    # which does not support lazy processing of archives.
    $ bork mount -o versions --glob-archives '*-my-home' --last 10 /tmp/mymountpoint

    # Exclusion options are supported.
    # These can speed up mounting and lower memory needs significantly.
    $ bork mount /path/to/repo /tmp/mymountpoint only/that/path
    $ bork mount --exclude '...' /tmp/mymountpoint


borkfs
++++++

::

    $ echo '/mnt/backup /tmp/myrepo fuse.borkfs defaults,noauto 0 0' >> /etc/fstab
    $ mount /tmp/myrepo
    $ ls /tmp/myrepo
    root-2016-02-01 root-2016-02-2015

.. Note::

    ``borkfs`` will be automatically provided if you used a distribution
    package, ``pip`` or ``setup.py`` to install Bork. Users of the
    standalone binary will have to manually create a symlink (see
    :ref:`pyinstaller-binary`).

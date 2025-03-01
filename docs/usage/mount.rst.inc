.. IMPORTANT: this file is auto-generated from bork's built-in help, do not edit!

.. _bork_mount:

bork mount
----------
.. code-block:: none

    bork [common options] mount [options] MOUNTPOINT [PATH...]

.. only:: html

    .. class:: bork-options-table

    +-----------------------------------------------------------------------------+----------------------------------------------+-----------------------------------------------------------------------------------------------------------+
    | **positional arguments**                                                                                                                                                                                                               |
    +-----------------------------------------------------------------------------+----------------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                                             | ``MOUNTPOINT``                               | where to mount filesystem                                                                                 |
    +-----------------------------------------------------------------------------+----------------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                                             | ``PATH``                                     | paths to extract; patterns are supported                                                                  |
    +-----------------------------------------------------------------------------+----------------------------------------------+-----------------------------------------------------------------------------------------------------------+
    | **options**                                                                                                                                                                                                                            |
    +-----------------------------------------------------------------------------+----------------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--consider-checkpoints``                   | Show checkpoint archives in the repository contents list (default: hidden).                               |
    +-----------------------------------------------------------------------------+----------------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                                             | ``-f``, ``--foreground``                     | stay in foreground, do not daemonize                                                                      |
    +-----------------------------------------------------------------------------+----------------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                                             | ``-o``                                       | Extra mount options                                                                                       |
    +-----------------------------------------------------------------------------+----------------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--numeric-ids``                            | use numeric user and group identifiers from archive(s)                                                    |
    +-----------------------------------------------------------------------------+----------------------------------------------+-----------------------------------------------------------------------------------------------------------+
    | .. class:: bork-common-opt-ref                                                                                                                                                                                                         |
    |                                                                                                                                                                                                                                        |
    | :ref:`common_options`                                                                                                                                                                                                                  |
    +-----------------------------------------------------------------------------+----------------------------------------------+-----------------------------------------------------------------------------------------------------------+
    | **Archive filters** — Archive filters can be applied to repository targets.                                                                                                                                                            |
    +-----------------------------------------------------------------------------+----------------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                                             | ``-a PATTERN``, ``--match-archives PATTERN`` | only consider archive names matching the pattern. see "bork help match-archives".                         |
    +-----------------------------------------------------------------------------+----------------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--sort-by KEYS``                           | Comma-separated list of sorting keys; valid keys are: timestamp, name, id; default is: timestamp          |
    +-----------------------------------------------------------------------------+----------------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--first N``                                | consider first N archives after other filters were applied                                                |
    +-----------------------------------------------------------------------------+----------------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--last N``                                 | consider last N archives after other filters were applied                                                 |
    +-----------------------------------------------------------------------------+----------------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--oldest TIMESPAN``                        | consider archives between the oldest archive's timestamp and (oldest + TIMESPAN), e.g. 7d or 12m.         |
    +-----------------------------------------------------------------------------+----------------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--newest TIMESPAN``                        | consider archives between the newest archive's timestamp and (newest - TIMESPAN), e.g. 7d or 12m.         |
    +-----------------------------------------------------------------------------+----------------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--older TIMESPAN``                         | consider archives older than (now - TIMESPAN), e.g. 7d oder 12m.                                          |
    +-----------------------------------------------------------------------------+----------------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--newer TIMESPAN``                         | consider archives newer than (now - TIMESPAN), e.g. 7d or 12m.                                            |
    +-----------------------------------------------------------------------------+----------------------------------------------+-----------------------------------------------------------------------------------------------------------+
    | **Include/Exclude options**                                                                                                                                                                                                            |
    +-----------------------------------------------------------------------------+----------------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                                             | ``-e PATTERN``, ``--exclude PATTERN``        | exclude paths matching PATTERN                                                                            |
    +-----------------------------------------------------------------------------+----------------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--exclude-from EXCLUDEFILE``               | read exclude patterns from EXCLUDEFILE, one per line                                                      |
    +-----------------------------------------------------------------------------+----------------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--pattern PATTERN``                        | include/exclude paths matching PATTERN                                                                    |
    +-----------------------------------------------------------------------------+----------------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--patterns-from PATTERNFILE``              | read include/exclude patterns from PATTERNFILE, one per line                                              |
    +-----------------------------------------------------------------------------+----------------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--strip-components NUMBER``                | Remove the specified number of leading path elements. Paths with fewer elements will be silently skipped. |
    +-----------------------------------------------------------------------------+----------------------------------------------+-----------------------------------------------------------------------------------------------------------+

    .. raw:: html

        <script type='text/javascript'>
        $(document).ready(function () {
            $('.bork-options-table colgroup').remove();
        })
        </script>

.. only:: latex

    MOUNTPOINT
        where to mount filesystem
    PATH
        paths to extract; patterns are supported


    options
        --consider-checkpoints    Show checkpoint archives in the repository contents list (default: hidden).
        -f, --foreground    stay in foreground, do not daemonize
        -o     Extra mount options
        --numeric-ids    use numeric user and group identifiers from archive(s)


    :ref:`common_options`
        |

    Archive filters
        -a PATTERN, --match-archives PATTERN     only consider archive names matching the pattern. see "bork help match-archives".
        --sort-by KEYS                           Comma-separated list of sorting keys; valid keys are: timestamp, name, id; default is: timestamp
        --first N                                consider first N archives after other filters were applied
        --last N                                 consider last N archives after other filters were applied
        --oldest TIMESPAN                        consider archives between the oldest archive's timestamp and (oldest + TIMESPAN), e.g. 7d or 12m.
        --newest TIMESPAN                        consider archives between the newest archive's timestamp and (newest - TIMESPAN), e.g. 7d or 12m.
        --older TIMESPAN                         consider archives older than (now - TIMESPAN), e.g. 7d oder 12m.
        --newer TIMESPAN                         consider archives newer than (now - TIMESPAN), e.g. 7d or 12m.


    Include/Exclude options
        -e PATTERN, --exclude PATTERN     exclude paths matching PATTERN
        --exclude-from EXCLUDEFILE        read exclude patterns from EXCLUDEFILE, one per line
        --pattern PATTERN                 include/exclude paths matching PATTERN
        --patterns-from PATTERNFILE       read include/exclude patterns from PATTERNFILE, one per line
        --strip-components NUMBER         Remove the specified number of leading path elements. Paths with fewer elements will be silently skipped.


Description
~~~~~~~~~~~

This command mounts an archive as a FUSE filesystem. This can be useful
for browsing an archive or restoring individual files. When restoring,
take into account that the current FUSE implementation does not support
special fs flags and ACLs.

Unless the ``--foreground`` option is given the command will run in the
background until the filesystem is ``umounted``.

The command ``borkfs`` provides a wrapper for ``bork mount``. This can also be
used in fstab entries:
``/path/to/repo /mnt/point fuse.borkfs defaults,noauto 0 0``

To allow a regular user to use fstab entries, add the ``user`` option:
``/path/to/repo /mnt/point fuse.borkfs defaults,noauto,user 0 0``

For FUSE configuration and mount options, see the mount.fuse(8) manual page.

Bork's default behavior is to use the archived user and group names of each
file and map them to the system's respective user and group ids.
Alternatively, using ``numeric-ids`` will instead use the archived user and
group ids without any mapping.

The ``uid`` and ``gid`` mount options (implemented by Bork) can be used to
override the user and group ids of all files (i.e., ``bork mount -o
uid=1000,gid=1000``).

The man page references ``user_id`` and ``group_id`` mount options
(implemented by fuse) which specify the user and group id of the mount owner
(aka, the user who does the mounting). It is set automatically by libfuse (or
the filesystem if libfuse is not used). However, you should not specify these
manually. Unlike the ``uid`` and ``gid`` mount options which affect all files,
``user_id`` and ``group_id`` affect the user and group id of the mounted
(base) directory.

Additional mount options supported by bork:

- ``versions``: when used with a repository mount, this gives a merged, versioned
  view of the files in the archives. EXPERIMENTAL, layout may change in future.
- ``allow_damaged_files``: by default damaged files (where missing chunks were
  replaced with runs of zeros by ``bork check --repair``) are not readable and
  return EIO (I/O error). Set this option to read such files.
- ``ignore_permissions``: for security reasons the ``default_permissions`` mount
  option is internally enforced by bork. ``ignore_permissions`` can be given to
  not enforce ``default_permissions``.

The BORK_MOUNT_DATA_CACHE_ENTRIES environment variable is meant for advanced users
to tweak the performance. It sets the number of cached data chunks; additional
memory usage can be up to ~8 MiB times this number. The default is the number
of CPU cores.

When the daemonized process receives a signal or crashes, it does not unmount.
Unmounting in these cases could cause an active rsync or similar process
to delete data unintentionally.

When running in the foreground ^C/SIGINT unmounts cleanly, but other
signals or crashes do not.
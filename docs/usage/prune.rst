.. include:: prune.rst.inc

Examples
~~~~~~~~

Be careful, prune is a potentially dangerous command, it will remove backup
archives.

The default of prune is to apply to **all archives in the repository** unless
you restrict its operation to a subset of the archives using ``-a`` / ``--match-archives``.
When using ``-a``, be careful to choose a good pattern - e.g. do not use a
prefix "foo" if you do not also want to match "foobar".

It is strongly recommended to always run ``prune -v --list --dry-run ...``
first so you will see what it would do without it actually doing anything.

::

    # Keep 7 end of day and 4 additional end of week archives.
    # Do a dry-run without actually deleting anything.
    $ bork prune -v --list --dry-run --keep-daily=7 --keep-weekly=4

    # Same as above but only apply to archive names starting with the hostname
    # of the machine followed by a "-" character:
    $ bork prune -v --list --keep-daily=7 --keep-weekly=4 -a 'sh:{hostname}-*'
    # actually free disk space:
    $ bork compact

    # Keep 7 end of day, 4 additional end of week archives,
    # and an end of month archive for every month:
    $ bork prune -v --list --keep-daily=7 --keep-weekly=4 --keep-monthly=-1

    # Keep all backups in the last 10 days, 4 additional end of week archives,
    # and an end of month archive for every month:
    $ bork prune -v --list --keep-within=10d --keep-weekly=4 --keep-monthly=-1

There is also a visualized prune example in ``docs/misc/prune-example.txt``:

.. highlight:: none
.. include:: ../misc/prune-example.txt
    :literal:

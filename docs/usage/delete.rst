.. include:: delete.rst.inc

Examples
~~~~~~~~
::

    # delete a single backup archive:
    $ bork delete -a Monday
    # actually free disk space:
    $ bork compact

    # delete all archives whose names begin with the machine's hostname followed by "-"
    $ bork delete -a 'sh:{hostname}-*'

    # delete all archives whose names contain "-2012-"
    $ bork delete -a 'sh:*-2012-*'

    # see what would be deleted if delete was run without --dry-run
    $ bork delete --list --dry-run -a 'sh:*-May-*'


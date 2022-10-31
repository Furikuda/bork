.. include:: config.rst.inc

.. note::

   The repository & cache config files are some of the only directly manipulable
   parts of a repository that aren't versioned or backed up, so be careful when
   making changes\!

Examples
~~~~~~~~
::

    # find cache directory
    $ cd ~/.cache/bork/$(bork config id)

    # reserve some space
    $ bork config additional_free_space 2G

    # make a repo append-only
    $ bork config append_only 1



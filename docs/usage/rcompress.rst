.. include:: rcompress.rst.inc

Examples
~~~~~~~~

::

    # recompress repo contents
    $ bork rcompress --progress --compression=zstd,3

    # recompress and obfuscate repo contents
    $ bork rcompress --progress --compression=obfuscate,1,zstd,3

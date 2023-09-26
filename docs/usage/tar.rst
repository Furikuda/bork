.. include:: export-tar.rst.inc

.. include:: import-tar.rst.inc

Examples
~~~~~~~~
::

    # export as uncompressed tar
    $ bork export-tar Monday Monday.tar

    # import an uncompressed tar
    $ bork import-tar Monday Monday.tar

    # exclude some file types, compress using gzip
    $ bork export-tar Monday Monday.tar.gz --exclude '*.so'

    # use higher compression level with gzip
    $ bork export-tar --tar-filter="gzip -9" Monday Monday.tar.gz

    # copy an archive from repoA to repoB
    $ bork -r repoA export-tar --tar-format=BORG archive - | bork -r repoB import-tar archive -

    # export a tar, but instead of storing it on disk, upload it to remote site using curl
    $ bork export-tar Monday - | curl --data-binary @- https://somewhere/to/POST

    # remote extraction via "tarpipe"
    $ bork export-tar Monday - | ssh somewhere "cd extracted; tar x"

Archives transfer script
~~~~~~~~~~~~~~~~~~~~~~~~

Outputs a script that copies all archives from repo1 to repo2:

::

    for A T in `borg list --format='{archive} {time:%Y-%m-%dT%H:%M:%S}{NL}'`
    do
      echo "bork -r repo1 export-tar --tar-format=BORG $A - | bork -r repo2 import-tar --timestamp=$T $A -"
    done

Kept:

- archive name, archive timestamp
- archive contents (all items with metadata and data)

Lost:

- some archive metadata (like the original commandline, execution time, etc.)

Please note:

- all data goes over that pipe, again and again for every archive
- the pipe is dumb, there is no data or transfer time reduction there due to deduplication
- maybe add compression
- pipe over ssh for remote transfer
- no special sparse file support

.. include:: recreate.rst.inc

Examples
~~~~~~~~
::

    # Create a backup with little but fast compression
    $ bork create archive /some/files --compression lz4
    # Then compress it - this might take longer, but the backup has already completed,
    # so no inconsistencies from a long-running backup job.
    $ bork recreate -a archive --recompress --compression zlib,9

    # Remove unwanted files from all archives in a repository.
    # Note the relative path for the --exclude option - archives only contain relative paths.
    $ bork recreate --exclude home/icke/Pictures/drunk_photos

    # Change archive comment
    $ bork create --comment "This is a comment" archivename ~
    $ bork info -a archivename
    Name: archivename
    Fingerprint: ...
    Comment: This is a comment
    ...
    $ bork recreate --comment "This is a better comment" -a archivename
    $ bork info -a archivename
    Name: archivename
    Fingerprint: ...
    Comment: This is a better comment
    ...


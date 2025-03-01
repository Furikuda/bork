.. IMPORTANT: this file is auto-generated from bork's built-in help, do not edit!

.. _bork_import-tar:

bork import-tar
---------------
.. code-block:: none

    bork [common options] import-tar [options] NAME TARFILE

.. only:: html

    .. class:: bork-options-table

    +-------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | **positional arguments**                                                                                                                                                                                                                                                                                      |
    +-------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                       | ``NAME``                                          | specify the archive name                                                                                                                                                                          |
    +-------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                       | ``TARFILE``                                       | input tar file. "-" to read from stdin instead.                                                                                                                                                   |
    +-------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | **options**                                                                                                                                                                                                                                                                                                   |
    +-------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                       | ``--tar-filter``                                  | filter program to pipe data through                                                                                                                                                               |
    +-------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                       | ``-s``, ``--stats``                               | print statistics for the created archive                                                                                                                                                          |
    +-------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                       | ``--list``                                        | output verbose list of items (files, dirs, ...)                                                                                                                                                   |
    +-------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                       | ``--filter STATUSCHARS``                          | only display items with the given status characters                                                                                                                                               |
    +-------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                       | ``--json``                                        | output stats as JSON (implies --stats)                                                                                                                                                            |
    +-------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                       | ``--ignore-zeros``                                | ignore zero-filled blocks in the input tarball                                                                                                                                                    |
    +-------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | .. class:: bork-common-opt-ref                                                                                                                                                                                                                                                                                |
    |                                                                                                                                                                                                                                                                                                               |
    | :ref:`common_options`                                                                                                                                                                                                                                                                                         |
    +-------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | **Archive options**                                                                                                                                                                                                                                                                                           |
    +-------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                       | ``--comment COMMENT``                             | add a comment text to the archive                                                                                                                                                                 |
    +-------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                       | ``--timestamp TIMESTAMP``                         | manually specify the archive creation date/time (yyyy-mm-ddThh:mm:ss[(+|-)HH:MM] format, (+|-)HH:MM is the UTC offset, default: local time zone). Alternatively, give a reference file/directory. |
    +-------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                       | ``-c SECONDS``, ``--checkpoint-interval SECONDS`` | write checkpoint every SECONDS seconds (Default: 1800)                                                                                                                                            |
    +-------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                       | ``--checkpoint-volume BYTES``                     | write checkpoint every BYTES bytes (Default: 0, meaning no volume based checkpointing)                                                                                                            |
    +-------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                       | ``--chunker-params PARAMS``                       | specify the chunker parameters (ALGO, CHUNK_MIN_EXP, CHUNK_MAX_EXP, HASH_MASK_BITS, HASH_WINDOW_SIZE). default: buzhash,19,23,21,4095                                                             |
    +-------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                       | ``-C COMPRESSION``, ``--compression COMPRESSION`` | select compression algorithm, see the output of the "bork help compression" command for details.                                                                                                  |
    +-------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

    .. raw:: html

        <script type='text/javascript'>
        $(document).ready(function () {
            $('.bork-options-table colgroup').remove();
        })
        </script>

.. only:: latex

    NAME
        specify the archive name
    TARFILE
        input tar file. "-" to read from stdin instead.


    options
        --tar-filter    filter program to pipe data through
        -s, --stats     print statistics for the created archive
        --list          output verbose list of items (files, dirs, ...)
        --filter STATUSCHARS    only display items with the given status characters
        --json          output stats as JSON (implies --stats)
        --ignore-zeros    ignore zero-filled blocks in the input tarball


    :ref:`common_options`
        |

    Archive options
        --comment COMMENT                             add a comment text to the archive
        --timestamp TIMESTAMP                         manually specify the archive creation date/time (yyyy-mm-ddThh:mm:ss[(+|-)HH:MM] format, (+|-)HH:MM is the UTC offset, default: local time zone). Alternatively, give a reference file/directory.
        -c SECONDS, --checkpoint-interval SECONDS     write checkpoint every SECONDS seconds (Default: 1800)
        --checkpoint-volume BYTES                     write checkpoint every BYTES bytes (Default: 0, meaning no volume based checkpointing)
        --chunker-params PARAMS                       specify the chunker parameters (ALGO, CHUNK_MIN_EXP, CHUNK_MAX_EXP, HASH_MASK_BITS, HASH_WINDOW_SIZE). default: buzhash,19,23,21,4095
        -C COMPRESSION, --compression COMPRESSION     select compression algorithm, see the output of the "bork help compression" command for details.


Description
~~~~~~~~~~~

This command creates a backup archive from a tarball.

When giving '-' as path, Bork will read a tar stream from standard input.

By default (--tar-filter=auto) Bork will detect whether the file is compressed
based on its file extension and pipe the file through an appropriate filter:

- .tar.gz or .tgz: gzip -d
- .tar.bz2 or .tbz: bzip2 -d
- .tar.xz or .txz: xz -d
- .tar.zstd or .tar.zst: zstd -d
- .tar.lz4: lz4 -d

Alternatively, a --tar-filter program may be explicitly specified. It should
read compressed data from stdin and output an uncompressed tar stream on
stdout.

Most documentation of bork create applies. Note that this command does not
support excluding files.

A ``--sparse`` option (as found in bork create) is not supported.

About tar formats and metadata conservation or loss, please see ``bork export-tar``.

import-tar reads these tar formats:

- BORK: bork specific (PAX-based)
- PAX: POSIX.1-2001
- GNU: GNU tar
- POSIX.1-1988 (ustar)
- UNIX V7 tar
- SunOS tar with extended attributes

To import multiple tarballs into a single archive, they can be simply
concatenated (e.g. using "cat") into a single file, and imported with an
``--ignore-zeros`` option to skip through the stop markers between them.
.. IMPORTANT: this file is auto-generated from bork's built-in help, do not edit!

.. _bork_extract:

bork extract
------------
.. code-block:: none

    bork [common options] extract [options] NAME [PATH...]

.. only:: html

    .. class:: bork-options-table

    +-------------------------------------------------------+---------------------------------------+-----------------------------------------------------------------------------------------------------------+
    | **positional arguments**                                                                                                                                                                                  |
    +-------------------------------------------------------+---------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                       | ``NAME``                              | specify the archive name                                                                                  |
    +-------------------------------------------------------+---------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                       | ``PATH``                              | paths to extract; patterns are supported                                                                  |
    +-------------------------------------------------------+---------------------------------------+-----------------------------------------------------------------------------------------------------------+
    | **options**                                                                                                                                                                                               |
    +-------------------------------------------------------+---------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                       | ``--list``                            | output verbose list of items (files, dirs, ...)                                                           |
    +-------------------------------------------------------+---------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                       | ``-n``, ``--dry-run``                 | do not actually change any files                                                                          |
    +-------------------------------------------------------+---------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                       | ``--numeric-ids``                     | only obey numeric user and group identifiers                                                              |
    +-------------------------------------------------------+---------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                       | ``--noflags``                         | do not extract/set flags (e.g. NODUMP, IMMUTABLE)                                                         |
    +-------------------------------------------------------+---------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                       | ``--noacls``                          | do not extract/set ACLs                                                                                   |
    +-------------------------------------------------------+---------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                       | ``--noxattrs``                        | do not extract/set xattrs                                                                                 |
    +-------------------------------------------------------+---------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                       | ``--stdout``                          | write all extracted data to stdout                                                                        |
    +-------------------------------------------------------+---------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                       | ``--sparse``                          | create holes in output sparse file from all-zero chunks                                                   |
    +-------------------------------------------------------+---------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                       | ``--continue``                        | continue a previously interrupted extraction of same archive                                              |
    +-------------------------------------------------------+---------------------------------------+-----------------------------------------------------------------------------------------------------------+
    | .. class:: bork-common-opt-ref                                                                                                                                                                            |
    |                                                                                                                                                                                                           |
    | :ref:`common_options`                                                                                                                                                                                     |
    +-------------------------------------------------------+---------------------------------------+-----------------------------------------------------------------------------------------------------------+
    | **Include/Exclude options**                                                                                                                                                                               |
    +-------------------------------------------------------+---------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                       | ``-e PATTERN``, ``--exclude PATTERN`` | exclude paths matching PATTERN                                                                            |
    +-------------------------------------------------------+---------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                       | ``--exclude-from EXCLUDEFILE``        | read exclude patterns from EXCLUDEFILE, one per line                                                      |
    +-------------------------------------------------------+---------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                       | ``--pattern PATTERN``                 | include/exclude paths matching PATTERN                                                                    |
    +-------------------------------------------------------+---------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                       | ``--patterns-from PATTERNFILE``       | read include/exclude patterns from PATTERNFILE, one per line                                              |
    +-------------------------------------------------------+---------------------------------------+-----------------------------------------------------------------------------------------------------------+
    |                                                       | ``--strip-components NUMBER``         | Remove the specified number of leading path elements. Paths with fewer elements will be silently skipped. |
    +-------------------------------------------------------+---------------------------------------+-----------------------------------------------------------------------------------------------------------+

    .. raw:: html

        <script type='text/javascript'>
        $(document).ready(function () {
            $('.bork-options-table colgroup').remove();
        })
        </script>

.. only:: latex

    NAME
        specify the archive name
    PATH
        paths to extract; patterns are supported


    options
        --list            output verbose list of items (files, dirs, ...)
        -n, --dry-run     do not actually change any files
        --numeric-ids     only obey numeric user and group identifiers
        --noflags         do not extract/set flags (e.g. NODUMP, IMMUTABLE)
        --noacls          do not extract/set ACLs
        --noxattrs        do not extract/set xattrs
        --stdout          write all extracted data to stdout
        --sparse          create holes in output sparse file from all-zero chunks
        --continue        continue a previously interrupted extraction of same archive


    :ref:`common_options`
        |

    Include/Exclude options
        -e PATTERN, --exclude PATTERN     exclude paths matching PATTERN
        --exclude-from EXCLUDEFILE        read exclude patterns from EXCLUDEFILE, one per line
        --pattern PATTERN                 include/exclude paths matching PATTERN
        --patterns-from PATTERNFILE       read include/exclude patterns from PATTERNFILE, one per line
        --strip-components NUMBER         Remove the specified number of leading path elements. Paths with fewer elements will be silently skipped.


Description
~~~~~~~~~~~

This command extracts the contents of an archive. By default the entire
archive is extracted but a subset of files and directories can be selected
by passing a list of ``PATHs`` as arguments. The file selection can further
be restricted by using the ``--exclude`` option.

For more help on include/exclude patterns, see the :ref:`bork_patterns` command output.

By using ``--dry-run``, you can do all extraction steps except actually writing the
output data: reading metadata and data chunks from the repo, checking the hash/hmac,
decrypting, decompressing.

``--progress`` can be slower than no progress display, since it makes one additional
pass over the archive metadata.

.. note::

    Currently, extract always writes into the current working directory ("."),
    so make sure you ``cd`` to the right place before calling ``bork extract``.

    When parent directories are not extracted (because of using file/directory selection
    or any other reason), bork can not restore parent directories' metadata, e.g. owner,
    group, permission, etc.
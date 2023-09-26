.. IMPORTANT: this file is auto-generated from bork's built-in help, do not edit!

.. _bork_transfer:

bork transfer
-------------
.. code-block:: none

    bork [common options] transfer [options]

.. only:: html

    .. class:: bork-options-table

    +-----------------------------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | **options**                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
    +-----------------------------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                                             | ``-n``, ``--dry-run``                             | do not change repository, just check                                                                                                                                                                                                                                                                                      |
    +-----------------------------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--other-repo SRC_REPOSITORY``                   | transfer archives from the other repository                                                                                                                                                                                                                                                                               |
    +-----------------------------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--upgrader UPGRADER``                           | use the upgrader to convert transferred data (default: no conversion)                                                                                                                                                                                                                                                     |
    +-----------------------------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                                             | ``-C COMPRESSION``, ``--compression COMPRESSION`` | select compression algorithm, see the output of the "bork help compression" command for details.                                                                                                                                                                                                                          |
    +-----------------------------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--recompress MODE``                             | recompress data chunks according to `MODE` and ``--compression``. Possible modes are `always`: recompress unconditionally; and `never`: do not recompress (faster: re-uses compressed data chunks w/o change).If no MODE is given, `always` will be used. Not passing --recompress is equivalent to "--recompress never". |
    +-----------------------------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | .. class:: bork-common-opt-ref                                                                                                                                                                                                                                                                                                                                                                                                                              |
    |                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
    | :ref:`common_options`                                                                                                                                                                                                                                                                                                                                                                                                                                       |
    +-----------------------------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | **Archive filters** — Archive filters can be applied to repository targets.                                                                                                                                                                                                                                                                                                                                                                                 |
    +-----------------------------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                                             | ``-a PATTERN``, ``--match-archives PATTERN``      | only consider archive names matching the pattern. see "bork help match-archives".                                                                                                                                                                                                                                         |
    +-----------------------------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--sort-by KEYS``                                | Comma-separated list of sorting keys; valid keys are: timestamp, name, id; default is: timestamp                                                                                                                                                                                                                          |
    +-----------------------------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--first N``                                     | consider first N archives after other filters were applied                                                                                                                                                                                                                                                                |
    +-----------------------------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--last N``                                      | consider last N archives after other filters were applied                                                                                                                                                                                                                                                                 |
    +-----------------------------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--oldest TIMESPAN``                             | consider archives between the oldest archive's timestamp and (oldest + TIMESPAN), e.g. 7d or 12m.                                                                                                                                                                                                                         |
    +-----------------------------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--newest TIMESPAN``                             | consider archives between the newest archive's timestamp and (newest - TIMESPAN), e.g. 7d or 12m.                                                                                                                                                                                                                         |
    +-----------------------------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--older TIMESPAN``                              | consider archives older than (now - TIMESPAN), e.g. 7d oder 12m.                                                                                                                                                                                                                                                          |
    +-----------------------------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--newer TIMESPAN``                              | consider archives newer than (now - TIMESPAN), e.g. 7d or 12m.                                                                                                                                                                                                                                                            |
    +-----------------------------------------------------------------------------+---------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

    .. raw:: html

        <script type='text/javascript'>
        $(document).ready(function () {
            $('.bork-options-table colgroup').remove();
        })
        </script>

.. only:: latex



    options
        -n, --dry-run     do not change repository, just check
        --other-repo SRC_REPOSITORY    transfer archives from the other repository
        --upgrader UPGRADER    use the upgrader to convert transferred data (default: no conversion)
        -C COMPRESSION, --compression COMPRESSION    select compression algorithm, see the output of the "bork help compression" command for details.
        --recompress MODE    recompress data chunks according to `MODE` and ``--compression``. Possible modes are `always`: recompress unconditionally; and `never`: do not recompress (faster: re-uses compressed data chunks w/o change).If no MODE is given, `always` will be used. Not passing --recompress is equivalent to "--recompress never".


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


Description
~~~~~~~~~~~

This command transfers archives from one repository to another repository.
Optionally, it can also upgrade the transferred data.
Optionally, it can also recompress the transferred data.

It is easiest (and fastest) to give ``--compression=COMPRESSION --recompress=never`` using
the same COMPRESSION mode as in the SRC_REPO - bork will use that COMPRESSION for metadata (in
any case) and keep data compressed "as is" (saves time as no data compression is needed).

If you want to globally change compression while transferring archives to the DST_REPO,
give ``--compress=WANTED_COMPRESSION --recompress=always``.

Suggested use for general purpose archive transfer (not repo upgrades)::

    # create a related DST_REPO (reusing key material from SRC_REPO), so that
    # chunking and chunk id generation will work in the same way as before.
    bork --repo=DST_REPO rcreate --other-repo=SRC_REPO --encryption=DST_ENC

    # transfer archives from SRC_REPO to DST_REPO
    bork --repo=DST_REPO transfer --other-repo=SRC_REPO --dry-run  # check what it would do
    bork --repo=DST_REPO transfer --other-repo=SRC_REPO            # do it!
    bork --repo=DST_REPO transfer --other-repo=SRC_REPO --dry-run  # check! anything left?

The default is to transfer all archives, including checkpoint archives.

You could use the misc. archive filter options to limit which archives it will
transfer, e.g. using the ``-a`` option. This is recommended for big
repositories with multiple data sets to keep the runtime per invocation lower.

For repository upgrades (e.g. from a bork 1.2 repo to a related bork 2.0 repo), usage is
quite similar to the above::

    # fast: compress metadata with zstd,3, but keep data chunks compressed as they are:
    bork --repo=DST_REPO transfer --other-repo=SRC_REPO --upgrader=From12To20 \
         --compress=zstd,3 --recompress=never

    # compress metadata and recompress data with zstd,3
    bork --repo=DST_REPO transfer --other-repo=SRC_REPO --upgrader=From12To20 \
         --compress=zstd,3 --recompress=always


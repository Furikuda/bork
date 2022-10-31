.. IMPORTANT: this file is auto-generated from bork's built-in help, do not edit!

.. _bork_transfer:

bork transfer
-------------
.. code-block:: none

    bork [common options] transfer [options]

.. only:: html

    .. class:: bork-options-table

    +-----------------------------------------------------------------------------+----------------------------------------------+--------------------------------------------------------------------------------------------------+
    | **optional arguments**                                                                                                                                                                                                        |
    +-----------------------------------------------------------------------------+----------------------------------------------+--------------------------------------------------------------------------------------------------+
    |                                                                             | ``-n``, ``--dry-run``                        | do not change repository, just check                                                             |
    +-----------------------------------------------------------------------------+----------------------------------------------+--------------------------------------------------------------------------------------------------+
    |                                                                             | ``--other-repo SRC_REPOSITORY``              | transfer archives from the other repository                                                      |
    +-----------------------------------------------------------------------------+----------------------------------------------+--------------------------------------------------------------------------------------------------+
    |                                                                             | ``--upgrader UPGRADER``                      | use the upgrader to convert transferred data (default: no conversion)                            |
    +-----------------------------------------------------------------------------+----------------------------------------------+--------------------------------------------------------------------------------------------------+
    | .. class:: bork-common-opt-ref                                                                                                                                                                                                |
    |                                                                                                                                                                                                                               |
    | :ref:`common_options`                                                                                                                                                                                                         |
    +-----------------------------------------------------------------------------+----------------------------------------------+--------------------------------------------------------------------------------------------------+
    | **Archive filters** — Archive filters can be applied to repository targets.                                                                                                                                                   |
    +-----------------------------------------------------------------------------+----------------------------------------------+--------------------------------------------------------------------------------------------------+
    |                                                                             | ``-a PATTERN``, ``--match-archives PATTERN`` | only consider archive names matching the pattern. see "bork help match-archives".                |
    +-----------------------------------------------------------------------------+----------------------------------------------+--------------------------------------------------------------------------------------------------+
    |                                                                             | ``--sort-by KEYS``                           | Comma-separated list of sorting keys; valid keys are: timestamp, name, id; default is: timestamp |
    +-----------------------------------------------------------------------------+----------------------------------------------+--------------------------------------------------------------------------------------------------+
    |                                                                             | ``--first N``                                | consider first N archives after other filters were applied                                       |
    +-----------------------------------------------------------------------------+----------------------------------------------+--------------------------------------------------------------------------------------------------+
    |                                                                             | ``--last N``                                 | consider last N archives after other filters were applied                                        |
    +-----------------------------------------------------------------------------+----------------------------------------------+--------------------------------------------------------------------------------------------------+

    .. raw:: html

        <script type='text/javascript'>
        $(document).ready(function () {
            $('.bork-options-table colgroup').remove();
        })
        </script>

.. only:: latex



    optional arguments
        -n, --dry-run     do not change repository, just check
        --other-repo SRC_REPOSITORY    transfer archives from the other repository
        --upgrader UPGRADER    use the upgrader to convert transferred data (default: no conversion)


    :ref:`common_options`
        |

    Archive filters
        -a PATTERN, --match-archives PATTERN     only consider archive names matching the pattern. see "bork help match-archives".
        --sort-by KEYS                           Comma-separated list of sorting keys; valid keys are: timestamp, name, id; default is: timestamp
        --first N                                consider first N archives after other filters were applied
        --last N                                 consider last N archives after other filters were applied


Description
~~~~~~~~~~~

This command transfers archives from one repository to another repository.
Optionally, it can also upgrade the transferred data.

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
transfer, e.g. using the -a option. This is recommended for big
repositories with multiple data sets to keep the runtime per invocation lower.

For repository upgrades (e.g. from a bork 1.2 repo to a related bork 2.0 repo), usage is
quite similar to the above::

    bork --repo=DST_REPO transfer --other-repo=SRC_REPO --upgrader=From12To20


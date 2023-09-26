.. IMPORTANT: this file is auto-generated from bork's built-in help, do not edit!

.. _bork_rinfo:

bork rinfo
----------
.. code-block:: none

    bork [common options] rinfo [options]

.. only:: html

    .. class:: bork-options-table

    +-------------------------------------------------------+------------+-----------------------+
    | **options**                                                                                |
    +-------------------------------------------------------+------------+-----------------------+
    |                                                       | ``--json`` | format output as JSON |
    +-------------------------------------------------------+------------+-----------------------+
    | .. class:: bork-common-opt-ref                                                             |
    |                                                                                            |
    | :ref:`common_options`                                                                      |
    +-------------------------------------------------------+------------+-----------------------+

    .. raw:: html

        <script type='text/javascript'>
        $(document).ready(function () {
            $('.bork-options-table colgroup').remove();
        })
        </script>

.. only:: latex



    options
        --json     format output as JSON


    :ref:`common_options`
        |

Description
~~~~~~~~~~~

This command displays detailed information about the repository.

Please note that the deduplicated sizes of the individual archives do not add
up to the deduplicated size of the repository ("all archives"), because the two
are meaning different things:

This archive / deduplicated size = amount of data stored ONLY for this archive
= unique chunks of this archive.
All archives / deduplicated size = amount of data stored in the repo
= all chunks in the repository.
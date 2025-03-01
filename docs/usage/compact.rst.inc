.. IMPORTANT: this file is auto-generated from bork's built-in help, do not edit!

.. _bork_compact:

bork compact
------------
.. code-block:: none

    bork [common options] compact [options]

.. only:: html

    .. class:: bork-options-table

    +-------------------------------------------------------+-------------------------+----------------------------------------------------------------+
    | **options**                                                                                                                                      |
    +-------------------------------------------------------+-------------------------+----------------------------------------------------------------+
    |                                                       | ``--threshold PERCENT`` | set minimum threshold for saved space in PERCENT (Default: 10) |
    +-------------------------------------------------------+-------------------------+----------------------------------------------------------------+
    | .. class:: bork-common-opt-ref                                                                                                                   |
    |                                                                                                                                                  |
    | :ref:`common_options`                                                                                                                            |
    +-------------------------------------------------------+-------------------------+----------------------------------------------------------------+

    .. raw:: html

        <script type='text/javascript'>
        $(document).ready(function () {
            $('.bork-options-table colgroup').remove();
        })
        </script>

.. only:: latex



    options
        --threshold PERCENT     set minimum threshold for saved space in PERCENT (Default: 10)


    :ref:`common_options`
        |

Description
~~~~~~~~~~~

This command frees repository space by compacting segments.

Use this regularly to avoid running out of space - you do not need to use this
after each bork command though. It is especially useful after deleting archives,
because only compaction will really free repository space.

bork compact does not need a key, so it is possible to invoke it from the
client or also from the server.

Depending on the amount of segments that need compaction, it may take a while,
so consider using the ``--progress`` option.

A segment is compacted if the amount of saved space is above the percentage value
given by the ``--threshold`` option. If omitted, a threshold of 10% is used.
When using ``--verbose``, bork will output an estimate of the freed space.

See :ref:`separate_compaction` in Additional Notes for more details.
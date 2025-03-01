.. IMPORTANT: this file is auto-generated from bork's built-in help, do not edit!

.. _bork_benchmark_cpu:

bork benchmark cpu
------------------
.. code-block:: none

    bork [common options] benchmark cpu [options]

.. only:: html

    .. class:: bork-options-table

    +-------------------------------------------------------+
    | .. class:: bork-common-opt-ref                        |
    |                                                       |
    | :ref:`common_options`                                 |
    +-------------------------------------------------------+

    .. raw:: html

        <script type='text/javascript'>
        $(document).ready(function () {
            $('.bork-options-table colgroup').remove();
        })
        </script>

.. only:: latex



    :ref:`common_options`
        |

Description
~~~~~~~~~~~

This command benchmarks misc. CPU bound bork operations.

It creates input data in memory, runs the operation and then displays throughput.
To reduce outside influence on the timings, please make sure to run this with:

- an otherwise as idle as possible machine
- enough free memory so there will be no slow down due to paging activity
.. IMPORTANT: this file is auto-generated from bork's built-in help, do not edit!

.. _bork_break-lock:

bork break-lock
---------------
.. code-block:: none

    bork [common options] break-lock [options]

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

This command breaks the repository and cache locks.
Please use carefully and only while no bork process (on any machine) is
trying to access the Cache or the Repository.
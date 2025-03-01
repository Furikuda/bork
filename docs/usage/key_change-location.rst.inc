.. IMPORTANT: this file is auto-generated from bork's built-in help, do not edit!

.. _bork_key_change-location:

bork key change-location
------------------------
.. code-block:: none

    bork [common options] key change-location [options] KEY_LOCATION

.. only:: html

    .. class:: bork-options-table

    +-------------------------------------------------------+------------------+----------------------------------------------------------------+
    | **positional arguments**                                                                                                                  |
    +-------------------------------------------------------+------------------+----------------------------------------------------------------+
    |                                                       | ``KEY_LOCATION`` | select key location                                            |
    +-------------------------------------------------------+------------------+----------------------------------------------------------------+
    | **options**                                                                                                                               |
    +-------------------------------------------------------+------------------+----------------------------------------------------------------+
    |                                                       | ``--keep``       | keep the key also at the current location (default: remove it) |
    +-------------------------------------------------------+------------------+----------------------------------------------------------------+
    | .. class:: bork-common-opt-ref                                                                                                            |
    |                                                                                                                                           |
    | :ref:`common_options`                                                                                                                     |
    +-------------------------------------------------------+------------------+----------------------------------------------------------------+

    .. raw:: html

        <script type='text/javascript'>
        $(document).ready(function () {
            $('.bork-options-table colgroup').remove();
        })
        </script>

.. only:: latex

    KEY_LOCATION
        select key location


    options
        --keep     keep the key also at the current location (default: remove it)


    :ref:`common_options`
        |

Description
~~~~~~~~~~~

Change the location of a bork key. The key can be stored at different locations:

- keyfile: locally, usually in the home directory
- repokey: inside the repo (in the repo config)

Please note:

This command does NOT change the crypto algorithms, just the key location,
thus you must ONLY give the key location (keyfile or repokey).
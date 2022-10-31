.. IMPORTANT: this file is auto-generated from bork's built-in help, do not edit!

.. _bork_change-passphrase:

bork change-passphrase
----------------------
.. code-block:: none

    bork [common options] change-passphrase [options] [REPOSITORY]

.. only:: html

    .. class:: bork-options-table

    +-------------------------------------------------------+----------------+--+
    | **positional arguments**                                                  |
    +-------------------------------------------------------+----------------+--+
    |                                                       | ``REPOSITORY`` |  |
    +-------------------------------------------------------+----------------+--+
    | .. class:: bork-common-opt-ref                                            |
    |                                                                           |
    | :ref:`common_options`                                                     |
    +-------------------------------------------------------+----------------+--+

    .. raw:: html

        <script type='text/javascript'>
        $(document).ready(function () {
            $('.bork-options-table colgroup').remove();
        })
        </script>

.. only:: latex

    REPOSITORY



    :ref:`common_options`
        |

Description
~~~~~~~~~~~

The key files used for repository encryption are optionally passphrase
protected. This command can be used to change this passphrase.

Please note that this command only changes the passphrase, but not any
secret protected by it (like e.g. encryption/MAC keys or chunker seed).
Thus, changing the passphrase after passphrase and bork key got compromised
does not protect future (nor past) backups to the same repository.
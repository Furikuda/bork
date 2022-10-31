.. IMPORTANT: this file is auto-generated from bork's built-in help, do not edit!

.. _bork_umount:

bork umount
-----------
.. code-block:: none

    bork [common options] umount [options] MOUNTPOINT

.. only:: html

    .. class:: bork-options-table

    +-------------------------------------------------------+----------------+----------------------------------------+
    | **positional arguments**                                                                                        |
    +-------------------------------------------------------+----------------+----------------------------------------+
    |                                                       | ``MOUNTPOINT`` | mountpoint of the filesystem to umount |
    +-------------------------------------------------------+----------------+----------------------------------------+
    | .. class:: bork-common-opt-ref                                                                                  |
    |                                                                                                                 |
    | :ref:`common_options`                                                                                           |
    +-------------------------------------------------------+----------------+----------------------------------------+

    .. raw:: html

        <script type='text/javascript'>
        $(document).ready(function () {
            $('.bork-options-table colgroup').remove();
        })
        </script>

.. only:: latex

    MOUNTPOINT
        mountpoint of the filesystem to umount


    :ref:`common_options`
        |

Description
~~~~~~~~~~~

This command un-mounts a FUSE filesystem that was mounted with ``bork mount``.

This is a convenience wrapper that just calls the platform-specific shell
command - usually this is either umount or fusermount -u.
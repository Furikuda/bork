.. IMPORTANT: this file is auto-generated from bork's built-in help, do not edit!

.. _bork_with-lock:

bork with-lock
--------------
.. code-block:: none

    bork [common options] with-lock [options] COMMAND [ARGS...]

.. only:: html

    .. class:: bork-options-table

    +-------------------------------------------------------+-------------+-------------------+
    | **positional arguments**                                                                |
    +-------------------------------------------------------+-------------+-------------------+
    |                                                       | ``COMMAND`` | command to run    |
    +-------------------------------------------------------+-------------+-------------------+
    |                                                       | ``ARGS``    | command arguments |
    +-------------------------------------------------------+-------------+-------------------+
    | .. class:: bork-common-opt-ref                                                          |
    |                                                                                         |
    | :ref:`common_options`                                                                   |
    +-------------------------------------------------------+-------------+-------------------+

    .. raw:: html

        <script type='text/javascript'>
        $(document).ready(function () {
            $('.bork-options-table colgroup').remove();
        })
        </script>

.. only:: latex

    COMMAND
        command to run
    ARGS
        command arguments


    :ref:`common_options`
        |

Description
~~~~~~~~~~~

This command runs a user-specified command while the repository lock is held.

It will first try to acquire the lock (make sure that no other operation is
running in the repo), then execute the given command as a subprocess and wait
for its termination, release the lock and return the user command's return
code as bork's return code.

.. note::

    If you copy a repository with the lock held, the lock will be present in
    the copy. Thus, before using bork on the copy from a different host,
    you need to use "bork break-lock" on the copied repository, because
    Bork is cautious and does not automatically remove stale locks made by a different host.
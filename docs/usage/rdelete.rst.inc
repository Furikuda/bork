.. IMPORTANT: this file is auto-generated from bork's built-in help, do not edit!

.. _bork_rdelete:

bork rdelete
------------
.. code-block:: none

    bork [common options] rdelete [options]

.. only:: html

    .. class:: bork-options-table

    +-------------------------------------------------------+--------------------------+--------------------------------------------------------------------------------------------------+
    | **options**                                                                                                                                                                         |
    +-------------------------------------------------------+--------------------------+--------------------------------------------------------------------------------------------------+
    |                                                       | ``-n``, ``--dry-run``    | do not change repository                                                                         |
    +-------------------------------------------------------+--------------------------+--------------------------------------------------------------------------------------------------+
    |                                                       | ``--list``               | output verbose list of archives                                                                  |
    +-------------------------------------------------------+--------------------------+--------------------------------------------------------------------------------------------------+
    |                                                       | ``--force``              | force deletion of corrupted archives, use ``--force --force`` in case ``--force`` does not work. |
    +-------------------------------------------------------+--------------------------+--------------------------------------------------------------------------------------------------+
    |                                                       | ``--cache-only``         | delete only the local cache for the given repository                                             |
    +-------------------------------------------------------+--------------------------+--------------------------------------------------------------------------------------------------+
    |                                                       | ``--keep-security-info`` | keep the local security info when deleting a repository                                          |
    +-------------------------------------------------------+--------------------------+--------------------------------------------------------------------------------------------------+
    | .. class:: bork-common-opt-ref                                                                                                                                                      |
    |                                                                                                                                                                                     |
    | :ref:`common_options`                                                                                                                                                               |
    +-------------------------------------------------------+--------------------------+--------------------------------------------------------------------------------------------------+

    .. raw:: html

        <script type='text/javascript'>
        $(document).ready(function () {
            $('.bork-options-table colgroup').remove();
        })
        </script>

.. only:: latex



    options
        -n, --dry-run     do not change repository
        --list            output verbose list of archives
        --force           force deletion of corrupted archives, use ``--force --force`` in case ``--force`` does not work.
        --cache-only      delete only the local cache for the given repository
        --keep-security-info    keep the local security info when deleting a repository


    :ref:`common_options`
        |

Description
~~~~~~~~~~~

This command deletes the complete repository.

When you delete a complete repository, the security info and local cache for it
(if any) are also deleted. Alternatively, you can delete just the local cache
with the ``--cache-only`` option, or keep the security info with the
``--keep-security-info`` option.

Always first use ``--dry-run --list`` to see what would be deleted.
.. IMPORTANT: this file is auto-generated from bork's built-in help, do not edit!

.. _bork_serve:

bork serve
----------
.. code-block:: none

    bork [common options] serve [options]

.. only:: html

    .. class:: bork-options-table

    +-------------------------------------------------------+-----------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | **options**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
    +-------------------------------------------------------+-----------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                       | ``--restrict-to-path PATH``       | restrict repository access to PATH. Can be specified multiple times to allow the client access to several directories. Access to all sub-directories is granted implicitly; PATH doesn't need to point directly to a repository.                                                                                                                                                                                                                                      |
    +-------------------------------------------------------+-----------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                       | ``--restrict-to-repository PATH`` | restrict repository access. Only the repository located at PATH (no sub-directories are considered) is accessible. Can be specified multiple times to allow the client access to several repositories. Unlike ``--restrict-to-path`` sub-directories are not accessible; PATH needs to point directly at a repository location. PATH may be an empty directory or the last element of PATH may not exist, in which case the client may initialize a repository there. |
    +-------------------------------------------------------+-----------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                       | ``--append-only``                 | only allow appending to repository segment files. Note that this only affects the low level structure of the repository, and running `delete` or `prune` will still be allowed. See :ref:`append_only_mode` in Additional Notes for more details.                                                                                                                                                                                                                     |
    +-------------------------------------------------------+-----------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                       | ``--storage-quota QUOTA``         | Override storage quota of the repository (e.g. 5G, 1.5T). When a new repository is initialized, sets the storage quota on the new repository as well. Default: no quota.                                                                                                                                                                                                                                                                                              |
    +-------------------------------------------------------+-----------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | .. class:: bork-common-opt-ref                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
    |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
    | :ref:`common_options`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
    +-------------------------------------------------------+-----------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

    .. raw:: html

        <script type='text/javascript'>
        $(document).ready(function () {
            $('.bork-options-table colgroup').remove();
        })
        </script>

.. only:: latex



    options
        --restrict-to-path PATH    restrict repository access to PATH. Can be specified multiple times to allow the client access to several directories. Access to all sub-directories is granted implicitly; PATH doesn't need to point directly to a repository.
        --restrict-to-repository PATH    restrict repository access. Only the repository located at PATH (no sub-directories are considered) is accessible. Can be specified multiple times to allow the client access to several repositories. Unlike ``--restrict-to-path`` sub-directories are not accessible; PATH needs to point directly at a repository location. PATH may be an empty directory or the last element of PATH may not exist, in which case the client may initialize a repository there.
        --append-only             only allow appending to repository segment files. Note that this only affects the low level structure of the repository, and running `delete` or `prune` will still be allowed. See :ref:`append_only_mode` in Additional Notes for more details.
        --storage-quota QUOTA     Override storage quota of the repository (e.g. 5G, 1.5T). When a new repository is initialized, sets the storage quota on the new repository as well. Default: no quota.


    :ref:`common_options`
        |

Description
~~~~~~~~~~~

This command starts a repository server process.

bork serve can currently support:

- Getting automatically started via ssh when the bork client uses a ssh://...
  remote repository. In this mode, `bork serve` will live until that ssh connection
  gets terminated.

- Getting started by some other means (not by the bork client) as a long-running socket
  server to be used for bork clients using a socket://... repository (see the `--socket`
  option if you do not want to use the default path for the socket and pid file).
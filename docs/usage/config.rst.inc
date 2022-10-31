.. IMPORTANT: this file is auto-generated from bork's built-in help, do not edit!

.. _bork_config:

bork config
-----------
.. code-block:: none

    bork [common options] config [options] [NAME] [VALUE]

.. only:: html

    .. class:: bork-options-table

    +-------------------------------------------------------+----------------------+----------------------------------------+
    | **positional arguments**                                                                                              |
    +-------------------------------------------------------+----------------------+----------------------------------------+
    |                                                       | ``NAME``             | name of config key                     |
    +-------------------------------------------------------+----------------------+----------------------------------------+
    |                                                       | ``VALUE``            | new value for key                      |
    +-------------------------------------------------------+----------------------+----------------------------------------+
    | **optional arguments**                                                                                                |
    +-------------------------------------------------------+----------------------+----------------------------------------+
    |                                                       | ``-c``, ``--cache``  | get and set values from the repo cache |
    +-------------------------------------------------------+----------------------+----------------------------------------+
    |                                                       | ``-d``, ``--delete`` | delete the key from the config file    |
    +-------------------------------------------------------+----------------------+----------------------------------------+
    |                                                       | ``-l``, ``--list``   | list the configuration of the repo     |
    +-------------------------------------------------------+----------------------+----------------------------------------+
    | .. class:: bork-common-opt-ref                                                                                        |
    |                                                                                                                       |
    | :ref:`common_options`                                                                                                 |
    +-------------------------------------------------------+----------------------+----------------------------------------+

    .. raw:: html

        <script type='text/javascript'>
        $(document).ready(function () {
            $('.bork-options-table colgroup').remove();
        })
        </script>

.. only:: latex

    NAME
        name of config key
    VALUE
        new value for key


    optional arguments
        -c, --cache    get and set values from the repo cache
        -d, --delete    delete the key from the config file
        -l, --list     list the configuration of the repo


    :ref:`common_options`
        |

Description
~~~~~~~~~~~

This command gets and sets options in a local repository or cache config file.
For security reasons, this command only works on local repositories.

To delete a config value entirely, use ``--delete``. To list the values
of the configuration file or the default values, use ``--list``.  To get and existing
key, pass only the key name. To set a key, pass both the key name and
the new value. Keys can be specified in the format "section.name" or
simply "name"; the section will default to "repository" and "cache" for
the repo and cache configs, respectively.


By default, bork config manipulates the repository config file. Using ``--cache``
edits the repository cache's config file instead.
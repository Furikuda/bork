.. IMPORTANT: this file is auto-generated from bork's built-in help, do not edit!

.. _bork_rlist:

bork rlist
----------
.. code-block:: none

    bork [common options] rlist [options]

.. only:: html

    .. class:: bork-options-table

    +-----------------------------------------------------------------------------+----------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | **options**                                                                                                                                                                                                                                                                                                  |
    +-----------------------------------------------------------------------------+----------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--consider-checkpoints``                   | Show checkpoint archives in the repository contents list (default: hidden).                                                                                                     |
    +-----------------------------------------------------------------------------+----------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--short``                                  | only print the archive names, nothing else                                                                                                                                      |
    +-----------------------------------------------------------------------------+----------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--format FORMAT``                          | specify format for archive listing (default: "{archive:<36} {time} [{id}]{NL}")                                                                                                 |
    +-----------------------------------------------------------------------------+----------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--json``                                   | Format output as JSON. The form of ``--format`` is ignored, but keys used in it are added to the JSON output. Some keys are always present. Note: JSON can only represent text. |
    +-----------------------------------------------------------------------------+----------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | .. class:: bork-common-opt-ref                                                                                                                                                                                                                                                                               |
    |                                                                                                                                                                                                                                                                                                              |
    | :ref:`common_options`                                                                                                                                                                                                                                                                                        |
    +-----------------------------------------------------------------------------+----------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | **Archive filters** — Archive filters can be applied to repository targets.                                                                                                                                                                                                                                  |
    +-----------------------------------------------------------------------------+----------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                                             | ``-a PATTERN``, ``--match-archives PATTERN`` | only consider archive names matching the pattern. see "bork help match-archives".                                                                                               |
    +-----------------------------------------------------------------------------+----------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--sort-by KEYS``                           | Comma-separated list of sorting keys; valid keys are: timestamp, name, id; default is: timestamp                                                                                |
    +-----------------------------------------------------------------------------+----------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--first N``                                | consider first N archives after other filters were applied                                                                                                                      |
    +-----------------------------------------------------------------------------+----------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--last N``                                 | consider last N archives after other filters were applied                                                                                                                       |
    +-----------------------------------------------------------------------------+----------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--oldest TIMESPAN``                        | consider archives between the oldest archive's timestamp and (oldest + TIMESPAN), e.g. 7d or 12m.                                                                               |
    +-----------------------------------------------------------------------------+----------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--newest TIMESPAN``                        | consider archives between the newest archive's timestamp and (newest - TIMESPAN), e.g. 7d or 12m.                                                                               |
    +-----------------------------------------------------------------------------+----------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--older TIMESPAN``                         | consider archives older than (now - TIMESPAN), e.g. 7d oder 12m.                                                                                                                |
    +-----------------------------------------------------------------------------+----------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                                             | ``--newer TIMESPAN``                         | consider archives newer than (now - TIMESPAN), e.g. 7d or 12m.                                                                                                                  |
    +-----------------------------------------------------------------------------+----------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

    .. raw:: html

        <script type='text/javascript'>
        $(document).ready(function () {
            $('.bork-options-table colgroup').remove();
        })
        </script>

.. only:: latex



    options
        --consider-checkpoints    Show checkpoint archives in the repository contents list (default: hidden).
        --short     only print the archive names, nothing else
        --format FORMAT    specify format for archive listing (default: "{archive:<36} {time} [{id}]{NL}")
        --json      Format output as JSON. The form of ``--format`` is ignored, but keys used in it are added to the JSON output. Some keys are always present. Note: JSON can only represent text.


    :ref:`common_options`
        |

    Archive filters
        -a PATTERN, --match-archives PATTERN     only consider archive names matching the pattern. see "bork help match-archives".
        --sort-by KEYS                           Comma-separated list of sorting keys; valid keys are: timestamp, name, id; default is: timestamp
        --first N                                consider first N archives after other filters were applied
        --last N                                 consider last N archives after other filters were applied
        --oldest TIMESPAN                        consider archives between the oldest archive's timestamp and (oldest + TIMESPAN), e.g. 7d or 12m.
        --newest TIMESPAN                        consider archives between the newest archive's timestamp and (newest - TIMESPAN), e.g. 7d or 12m.
        --older TIMESPAN                         consider archives older than (now - TIMESPAN), e.g. 7d oder 12m.
        --newer TIMESPAN                         consider archives newer than (now - TIMESPAN), e.g. 7d or 12m.


Description
~~~~~~~~~~~

This command lists the archives contained in a repository.

.. man NOTES

The FORMAT specifier syntax
+++++++++++++++++++++++++++

The ``--format`` option uses python's `format string syntax
<https://docs.python.org/3.9/library/string.html#formatstrings>`_.

Examples:
::

    $ bork rlist --format '{archive}{NL}'
    ArchiveFoo
    ArchiveBar
    ...

    # {VAR:NUMBER} - pad to NUMBER columns.
    # Strings are left-aligned, numbers are right-aligned.
    # Note: time columns except ``isomtime``, ``isoctime`` and ``isoatime`` cannot be padded.
    $ bork rlist --format '{archive:36} {time} [{id}]{NL}' /path/to/repo
    ArchiveFoo                           Thu, 2021-12-09 10:22:28 [0b8e9...3b274]
    ...

The following keys are always available:

- NEWLINE: OS dependent line separator
- NL: alias of NEWLINE
- NUL: NUL character for creating print0 / xargs -0 like output
- SPACE: space character
- TAB: tab character
- CR: carriage return character
- LF: line feed character


Keys available only when listing archives in a repository:

- archive: archive name
- name: alias of "archive"
- comment: archive comment
- id: internal ID of the archive
- tam: TAM authentication state of this archive

- start: time (start) of creation of the archive
- time: alias of "start"
- end: time (end) of creation of the archive
- command_line: command line which was used to create the archive

- hostname: hostname of host on which this archive was created
- username: username of user who created this archive

- size: size of this archive (data plus metadata, not considering compression and deduplication)
- nfiles: count of files in this archive

:orphan:

SYNOPSIS
--------

bork [common options] <command> [options] [arguments]

DESCRIPTION
-----------

.. we don't include the README.rst here since we want to keep this terse.

BorkBackup (short: Bork) is a deduplicating backup program.
Optionally, it supports compression and authenticated encryption.

The main goal of Bork is to provide an efficient and secure way to back data up.
The data deduplication technique used makes Bork suitable for daily backups
since only changes are stored.
The authenticated encryption technique makes it suitable for backups to targets not
fully trusted.

Bork stores a set of files in an *archive*. A *repository* is a collection
of *archives*. The format of repositories is Bork-specific. Bork does not
distinguish archives from each other in any way other than their name,
it does not matter when or where archives were created (e.g. different hosts).

EXAMPLES
--------

A step-by-step example
~~~~~~~~~~~~~~~~~~~~~~

.. include:: quickstart_example.rst.inc

NOTES
-----

.. include:: usage_general.rst.inc

SEE ALSO
--------

`bork-common(1)` for common command line options

`bork-rcreate(1)`, `bork-rdelete(1)`, `bork-rlist(1)`, `bork-rinfo(1)`,
`bork-create(1)`, `bork-mount(1)`, `bork-extract(1)`,
`bork-list(1)`, `bork-info(1)`,
`bork-delete(1)`, `bork-prune(1)`, `bork-compact(1)`,
`bork-recreate(1)`

`bork-compression(1)`, `bork-patterns(1)`, `bork-placeholders(1)`

* Main web site https://www.borkbackup.org/
* Releases https://github.com/furikuda/bork/releases
* Changelog https://github.com/furikuda/bork/blob/master/docs/changes.rst
* GitHub https://github.com/furikuda/bork
* Security contact https://borkbackup.readthedocs.io/en/latest/support.html#security-contact

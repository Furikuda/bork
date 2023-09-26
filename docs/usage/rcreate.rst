.. _bork-rcreate:

.. include:: rcreate.rst.inc

Examples
~~~~~~~~
::

    # Local repository
    $ export BORK_REPO=/path/to/repo
    # recommended repokey AEAD crypto modes
    $ bork rcreate --encryption=repokey-aes-ocb
    $ bork rcreate --encryption=repokey-chacha20-poly1305
    $ bork rcreate --encryption=repokey-blake2-aes-ocb
    $ bork rcreate --encryption=repokey-blake2-chacha20-poly1305
    # no encryption, not recommended
    $ bork rcreate --encryption=authenticated
    $ bork rcreate --encryption=authenticated-blake2
    $ bork rcreate --encryption=none

    # Remote repository (accesses a remote bork via ssh)
    $ export BORK_REPO=ssh://user@hostname/~/backup
    # repokey: stores the (encrypted) key into <REPO_DIR>/config
    $ bork rcreate --encryption=repokey-aes-ocb
    # keyfile: stores the (encrypted) key into ~/.config/bork/keys/
    $ bork rcreate --encryption=keyfile-aes-ocb


.. include:: key_change-location.rst.inc

.. _bork-change-passphrase:

.. include:: key_change-passphrase.rst.inc

Examples
~~~~~~~~
::

    # Create a key file protected repository
    $ bork rcreate --encryption=keyfile-aes-ocb -v
    Initializing repository at "/path/to/repo"
    Enter new passphrase:
    Enter same passphrase again:
    Remember your passphrase. Your data will be inaccessible without it.
    Key in "/root/.config/bork/keys/mnt_backup" created.
    Keep this key safe. Your data will be inaccessible without it.
    Synchronizing chunks cache...
    Archives: 0, w/ cached Idx: 0, w/ outdated Idx: 0, w/o cached Idx: 0.
    Done.

    # Change key file passphrase
    $ bork key change-passphrase -v
    Enter passphrase for key /root/.config/bork/keys/mnt_backup:
    Enter new passphrase:
    Enter same passphrase again:
    Remember your passphrase. Your data will be inaccessible without it.
    Key updated

    # Import a previously-exported key into the specified
    # key file (creating or overwriting the output key)
    # (keyfile repositories only)
    $ BORK_KEY_FILE=/path/to/output-key bork key import /path/to/exported

Fully automated using environment variables:

::

    $ BORK_NEW_PASSPHRASE=old bork rcreate --encryption=repokey-aes-ocb
    # now "old" is the current passphrase.
    $ BORK_PASSPHRASE=old BORK_NEW_PASSPHRASE=new bork key change-passphrase
    # now "new" is the current passphrase.


.. include:: key_export.rst.inc

.. include:: key_import.rst.inc

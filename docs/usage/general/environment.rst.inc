Environment Variables
~~~~~~~~~~~~~~~~~~~~~

Bork uses some environment variables for automation:

General:
    BORK_REPO
        When set, use the value to give the default repository location.
        Use this so you do not need to type ``--repo /path/to/my/repo`` all the time.
    BORK_OTHER_REPO
        Similar to BORK_REPO, but gives the default for ``--other-repo``.
    BORK_PASSPHRASE
        When set, use the value to answer the passphrase question for encrypted repositories.
        It is used when a passphrase is needed to access an encrypted repo as well as when a new
        passphrase should be initially set when initializing an encrypted repo.
        See also BORK_NEW_PASSPHRASE.
    BORK_PASSCOMMAND
        When set, use the standard output of the command (trailing newlines are stripped) to answer the
        passphrase question for encrypted repositories.
        It is used when a passphrase is needed to access an encrypted repo as well as when a new
        passphrase should be initially set when initializing an encrypted repo. Note that the command
        is executed without a shell. So variables, like ``$HOME`` will work, but ``~`` won't.
        If BORK_PASSPHRASE is also set, it takes precedence.
        See also BORK_NEW_PASSPHRASE.
    BORK_PASSPHRASE_FD
        When set, specifies a file descriptor to read a passphrase
        from. Programs starting bork may choose to open an anonymous pipe
        and use it to pass a passphrase. This is safer than passing via
        BORK_PASSPHRASE, because on some systems (e.g. Linux) environment
        can be examined by other processes.
        If BORK_PASSPHRASE or BORK_PASSCOMMAND are also set, they take precedence.
    BORK_NEW_PASSPHRASE
        When set, use the value to answer the passphrase question when a **new** passphrase is asked for.
        This variable is checked first. If it is not set, BORK_PASSPHRASE and BORK_PASSCOMMAND will also
        be checked.
        Main usecase for this is to automate fully ``bork change-passphrase``.
    BORK_DISPLAY_PASSPHRASE
        When set, use the value to answer the "display the passphrase for verification" question when defining a new passphrase for encrypted repositories.
    BORK_HOST_ID
        Bork usually computes a host id from the FQDN plus the results of ``uuid.getnode()`` (which usually returns
        a unique id based on the MAC address of the network interface. Except if that MAC happens to be all-zero - in
        that case it returns a random value, which is not what we want (because it kills automatic stale lock removal).
        So, if you have a all-zero MAC address or other reasons to control better externally the host id, just set this
        environment variable to a unique value. If all your FQDNs are unique, you can just use the FQDN. If not,
        use fqdn@uniqueid.
    BORK_LOCK_WAIT
        You can set the default value for the ``--lock-wait`` option with this, so
        you do not need to give it as a commandline option.
    BORK_LOGGING_CONF
        When set, use the given filename as INI_-style logging configuration.
        A basic example conf can be found at ``docs/misc/logging.conf``.
    BORK_RSH
        When set, use this command instead of ``ssh``. This can be used to specify ssh options, such as
        a custom identity file ``ssh -i /path/to/private/key``. See ``man ssh`` for other options. Using
        the ``--rsh CMD`` commandline option overrides the environment variable.
    BORK_REMOTE_PATH
        When set, use the given path as bork executable on the remote (defaults to "bork" if unset).
        Using ``--remote-path PATH`` commandline option overrides the environment variable.
    BORK_FILES_CACHE_SUFFIX
        When set to a value at least one character long, instructs bork to use a specifically named
        (based on the suffix) alternative files cache. This can be used to avoid loading and saving
        cache entries for backup sources other than the current sources.
    BORK_FILES_CACHE_TTL
        When set to a numeric value, this determines the maximum "time to live" for the files cache
        entries (default: 20). The files cache is used to determine quickly whether a file is unchanged.
        The FAQ explains this more detailed in: :ref:`always_chunking`
    BORK_SHOW_SYSINFO
        When set to no (default: yes), system information (like OS, Python version, ...) in
        exceptions is not shown.
        Please only use for good reasons as it makes issues harder to analyze.
    BORK_FUSE_IMPL
        Choose the lowlevel FUSE implementation bork shall use for ``bork mount``.
        This is a comma-separated list of implementation names, they are tried in the
        given order, e.g.:

        - ``pyfuse3,llfuse``: default, first try to load pyfuse3, then try to load llfuse.
        - ``llfuse,pyfuse3``: first try to load llfuse, then try to load pyfuse3.
        - ``pyfuse3``: only try to load pyfuse3
        - ``llfuse``: only try to load llfuse
        - ``none``: do not try to load an implementation
    BORK_SELFTEST
        This can be used to influence bork's builtin self-tests. The default is to execute the tests
        at the beginning of each bork command invocation.

        BORK_SELFTEST=disabled can be used to switch off the tests and rather save some time.
        Disabling is not recommended for normal bork users, but large scale bork storage providers can
        use this to optimize production servers after at least doing a one-time test bork (with
        selftests not disabled) when installing or upgrading machines / OS / bork.
    BORK_WORKAROUNDS
        A list of comma separated strings that trigger workarounds in bork,
        e.g. to work around bugs in other software.

        Currently known strings are:

        basesyncfile
            Use the more simple BaseSyncFile code to avoid issues with sync_file_range.
            You might need this to run bork on WSL (Windows Subsystem for Linux) or
            in systemd.nspawn containers on some architectures (e.g. ARM).
            Using this does not affect data safety, but might result in a more bursty
            write to disk behaviour (not continuously streaming to disk).

        retry_erofs
            Retry opening a file without O_NOATIME if opening a file with O_NOATIME
            caused EROFS. You will need this to make archives from volume shadow copies
            in WSL1 (Windows Subsystem for Linux 1).

        authenticated_no_key
            Work around a lost passphrase or key for an ``authenticated`` mode repository
            (these are only authenticated, but not encrypted).
            If the key is missing in the repository config, add ``key = anything`` there.

            This workaround is **only** for emergencies and **only** to extract data
            from an affected repository (read-only access)::

                BORK_WORKAROUNDS=authenticated_no_key bork extract repo::archive

            After you have extracted all data you need, you MUST delete the repository::

                BORK_WORKAROUNDS=authenticated_no_key bork delete repo

            Now you can init a fresh repo. Make sure you do not use the workaround any more.

Output formatting:
    BORK_LIST_FORMAT
        Giving the default value for ``bork list --format=X``.
    BORK_RLIST_FORMAT
        Giving the default value for ``bork rlist --format=X``.
    BORK_PRUNE_FORMAT
        Giving the default value for ``bork prune --format=X``.

Some automatic "answerers" (if set, they automatically answer confirmation questions):
    BORK_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=no (or =yes)
        For "Warning: Attempting to access a previously unknown unencrypted repository"
    BORK_RELOCATED_REPO_ACCESS_IS_OK=no (or =yes)
        For "Warning: The repository at location ... was previously located at ..."
    BORK_CHECK_I_KNOW_WHAT_I_AM_DOING=NO (or =YES)
        For "This is a potentially dangerous function..." (check --repair)
    BORK_DELETE_I_KNOW_WHAT_I_AM_DOING=NO (or =YES)
        For "You requested to DELETE the repository completely *including* all archives it contains:"

    Note: answers are case sensitive. setting an invalid answer value might either give the default
    answer or ask you interactively, depending on whether retries are allowed (they by default are
    allowed). So please test your scripts interactively before making them a non-interactive script.

.. _XDG env var: https://specifications.freedesktop.org/basedir-spec/0.6/ar01s03.html

Directories and files:
    BORK_BASE_DIR
        Defaults to ``$HOME`` or ``~$USER`` or ``~`` (in that order).
        If you want to move all bork-specific folders to a custom path at once, all you need to do is
        to modify ``BORK_BASE_DIR``: the other paths for cache, config etc. will adapt accordingly
        (assuming you didn't set them to a different custom value).
    BORK_CACHE_DIR
        Defaults to ``$BORK_BASE_DIR/.cache/bork``. If ``BORK_BASE_DIR`` is not explicitly set while
        `XDG env var`_ ``XDG_CACHE_HOME`` is set, then ``$XDG_CACHE_HOME/bork`` is being used instead.
        This directory contains the local cache and might need a lot
        of space for dealing with big repositories. Make sure you're aware of the associated
        security aspects of the cache location: :ref:`cache_security`
    BORK_CONFIG_DIR
        Defaults to ``$BORK_BASE_DIR/.config/bork``. If ``BORK_BASE_DIR`` is not explicitly set while
        `XDG env var`_ ``XDG_CONFIG_HOME`` is set, then ``$XDG_CONFIG_HOME/bork`` is being used instead.
        This directory contains all bork configuration directories, see the FAQ
        for a security advisory about the data in this directory: :ref:`home_config_bork`
    BORK_DATA_DIR
        Defaults to ``$BORK_BASE_DIR/.local/share/bork``. If ``BORK_BASE_DIR`` is not explicitly set while
        `XDG env var`_ ``XDG_DATA_HOME`` is set, then ``$XDG_DATA_HOME/bork`` is being used instead.
        This directory contains all bork data directories, see the FAQ
        for a security advisory about the data in this directory: :ref:`home_data_bork`
    BORK_RUNTIME_DIR
        Defaults to ``$BORK_BASE_DIR/.cache/bork``. If ``BORK_BASE_DIR`` is not explicitly set while
        `XDG env var`_ ``XDG_RUNTIME_DIR`` is set, then ``$XDG_RUNTIME_DIR/bork`` is being used instead.
        This directory contains bork runtime files, like e.g. the socket file.
    BORK_SECURITY_DIR
        Defaults to ``$BORK_DATA_DIR/security``.
        This directory contains security relevant data.
    BORK_KEYS_DIR
        Defaults to ``$BORK_CONFIG_DIR/keys``.
        This directory contains keys for encrypted repositories.
    BORK_KEY_FILE
        When set, use the given path as repository key file. Please note that this is only
        for rather special applications that externally fully manage the key files:

        - this setting only applies to the keyfile modes (not to the repokey modes).
        - using a full, absolute path to the key file is recommended.
        - all directories in the given path must exist.
        - this setting forces bork to use the key file at the given location.
        - the key file must either exist (for most commands) or will be created (``bork rcreate``).
        - you need to give a different path for different repositories.
        - you need to point to the correct key file matching the repository the command will operate on.
    TMPDIR
        This is where temporary files are stored (might need a lot of temporary space for some
        operations), see tempfile_ for details.

Building:
    BORK_OPENSSL_PREFIX
        Adds given OpenSSL header file directory to the default locations (setup.py).
    BORK_LIBLZ4_PREFIX
        Adds given prefix directory to the default locations. If a 'include/lz4.h' is found Bork
        will be linked against the system liblz4 instead of a bundled implementation. (setup.py)
    BORK_LIBZSTD_PREFIX
        Adds given prefix directory to the default locations. If a 'include/zstd.h' is found Bork
        will be linked against the system libzstd instead of a bundled implementation. (setup.py)

Please note:

- Be very careful when using the "yes" sayers, the warnings with prompt exist for your / your data's security/safety.
- Also be very careful when putting your passphrase into a script, make sure it has appropriate file permissions (e.g.
  mode 600, root:root).

.. _INI: https://docs.python.org/3/library/logging.config.html#configuration-file-format

.. _tempfile: https://docs.python.org/3/library/tempfile.html#tempfile.gettempdir

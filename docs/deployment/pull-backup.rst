.. include:: ../global.rst.inc
.. highlight:: none
.. _pull_backup:

=======================
Backing up in pull mode
=======================

Typically the bork client connects to a backup server using SSH as a transport
when initiating a backup. This is referred to as push mode.

If you however require the backup server to initiate the connection or prefer
it to initiate the backup run, one of the following workarounds is required to
allow such a pull mode setup.

A common use case for pull mode is to backup a remote server to a local personal
computer.

SSHFS
=====

Assuming you have a pull backup system set up with bork, where a backup server
pulls the data from the target via SSHFS. In this mode, the backup client's file
system is mounted remotely on the backup server. Pull mode is even possible if
the SSH connection must be established by the client via a remote tunnel. Other
network file systems like NFS or SMB could be used as well, but SSHFS is very
simple to set up and probably the most secure one.

There are some restrictions caused by SSHFS. For example, unless you define UID
and GID mappings when mounting via ``sshfs``, owners and groups of the mounted
file system will probably change, and you may not have access to those files if
BorkBackup is not run with root privileges.

SSHFS is a FUSE file system and uses the SFTP protocol, so there may be also
other unsupported features that the actual implementations of sshfs, libfuse and
sftp on the backup server do not support, like file name encodings, ACLs, xattrs
or flags. So there is no guarantee that you are able to restore a system
completely in every aspect from such a backup.

.. warning::

    To mount the client's root file system you will need root access to the
    client. This contradicts to the usual threat model of BorkBackup, where
    clients don't need to trust the backup server (data is encrypted). In pull
    mode the server (when logged in as root) could cause unlimited damage to the
    client. Therefore, pull mode should be used only from servers you do fully
    trust!

.. warning::

    Additionally, while being chrooted into the client's root file system,
    code from the client will be executed. Thus, you should only do that when
    fully trusting the client.

.. warning::

    The chroot method was chosen to get the right user and group name-id
    mappings, assuming they only come from files (/etc/passwd and group).
    This assumption might be wrong, e.g. if users/groups also come from
    ldap or other providers.
    Thus, it might be better to use ``--numeric-ids`` and not archive any
    user or group names (but just the numeric IDs) and not use chroot.

Creating a backup
-----------------

Generally, in a pull backup situation there is no direct way for bork to know
the client's original UID:GID name mapping of files, because Bork would use
``/etc/passwd`` and ``/etc/group`` of the backup server to map the names. To
derive the right names, Bork needs to have access to the client's passwd and
group files and use them in the backup process.

The solution to this problem is chrooting into an sshfs mounted directory. In
this example the whole client root file system is mounted. We use the
stand-alone BorkBackup executable and copy it into the mounted file system to
make Bork available after entering chroot; this can be skipped if Bork is
already installed on the client.

::

    # Mount client root file system.
    mkdir /tmp/sshfs
    sshfs root@host:/ /tmp/sshfs
    # Mount BorkBackup repository inside it.
    mkdir /tmp/sshfs/borkrepo
    mount --bind /path/to/repo /tmp/sshfs/borkrepo
    # Make bork executable available.
    cp /usr/local/bin/bork /tmp/sshfs/usr/local/bin/bork
    # Mount important system directories and enter chroot.
    cd /tmp/sshfs
    for i in dev proc sys; do mount --bind /$i $i; done
    chroot /tmp/sshfs

Now we are on the backup system but inside a chroot with the client's root file
system. We have a copy of Bork binary in ``/usr/local/bin`` and the repository
in ``/borkrepo``. Bork will back up the client's user/group names, and we can
create the backup, retaining the original paths, excluding the repository:

::

    bork create --exclude borkrepo --files-cache ctime,size /borkrepo::archive /

For the sake of simplicity only ``borkrepo`` is excluded here. You may want to
set up an exclude file with additional files and folders to be excluded. Also
note that we have to modify Bork's file change detection behaviour – SSHFS
cannot guarantee stable inode numbers, so we have to supply the
``--files-cache`` option.

Finally, we need to exit chroot, unmount all the stuff and clean up:

::

    exit # exit chroot
    rm /tmp/sshfs/usr/local/bin/bork
    cd /tmp/sshfs
    for i in dev proc sys borkrepo; do umount ./$i; done
    rmdir borkrepo
    cd ~
    umount /tmp/sshfs
    rmdir /tmp/sshfs

Thanks to secuser on IRC for this how-to!

Restore methods
---------------

The counterpart of a pull backup is a push restore. Depending on the type of
restore – full restore or partial restore – there are different methods to make
sure the correct IDs are restored.

Partial restore
~~~~~~~~~~~~~~~

In case of a partial restore, using the archived UIDs/GIDs might lead to wrong
results if the name-to-ID mapping on the target system has changed compared to
backup time (might be the case e.g. for a fresh OS install).

The workaround again is chrooting into an sshfs mounted directory, so Bork is
able to map the user/group names of the backup files to the actual IDs on the
client. This example is similar to the backup above – only the Bork command is
different:

::

    # Mount client root file system.
    mkdir /tmp/sshfs
    sshfs root@host:/ /tmp/sshfs
    # Mount BorkBackup repository inside it.
    mkdir /tmp/sshfs/borkrepo
    mount --bind /path/to/repo /tmp/sshfs/borkrepo
    # Make bork executable available.
    cp /usr/local/bin/bork /tmp/sshfs/usr/local/bin/bork
    # Mount important system directories and enter chroot.
    cd /tmp/sshfs
    for i in dev proc sys; do mount --bind /$i $i; done
    chroot /tmp/sshfs

Now we can run

::

    bork extract /borkrepo::archive PATH

to partially restore whatever we like. Finally, do the clean-up:

::

    exit # exit chroot
    rm /tmp/sshfs/usr/local/bin/bork
    cd /tmp/sshfs
    for i in dev proc sys borkrepo; do umount ./$i; done
    rmdir borkrepo
    cd ~
    umount /tmp/sshfs
    rmdir /tmp/sshfs

Full restore
~~~~~~~~~~~~

When doing a full restore, we restore all files (including the ones containing
the ID-to-name mapping, ``/etc/passwd`` and ``/etc/group``). Everything will be
consistent automatically if we restore the numeric IDs stored in the archive. So
there is no need for a chroot environment; we just mount the client file system
and extract a backup, utilizing the ``--numeric-ids`` option:

::

    sshfs root@host:/ /mnt/sshfs
    cd /mnt/sshfs
    bork extract --numeric-ids /path/to/repo::archive
    cd ~
    umount /mnt/sshfs

Simple (lossy) full restore
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Using ``bork export-tar`` it is possible to stream a backup to the client and
directly extract it without the need of mounting with SSHFS:

::

    bork export-tar /path/to/repo::archive - | ssh root@host 'tar -C / -x'

Note that in this scenario the tar format is the limiting factor – it cannot
restore all the advanced features that BorkBackup supports. See
:ref:`bork_export-tar` for limitations.

socat
=====

In this setup a SSH connection from the backup server to the client is
established that uses SSH reverse port forwarding to transparently
tunnel data between UNIX domain sockets on the client and server and the socat
tool to connect these with the bork client and server processes, respectively.

The program socat has to be available on the backup server and on the client
to be backed up.

When **pushing** a backup the bork client (holding the data to be backed up)
connects to the backup server via ssh, starts ``bork serve`` on the backup
server and communicates via standard input and output (transported via SSH)
with the process on the backup server.

With the help of socat this process can be reversed. The backup server will
create a connection to the client (holding the data to be backed up) and will
**pull** the data.

In the following example *bork-server* connects to *bork-client* to pull a backup.

To provide a secure setup sockets should be stored in ``/run/bork``, only
accessible to the users that run the backup process. So on both systems,
*bork-server* and *bork-client* the folder ``/run/bork`` has to be created::

   sudo mkdir -m 0700 /run/bork

On *bork-server* the socket file is opened by the user running the ``bork
serve`` process writing to the repository
so the user has to have read and write permissions on ``/run/bork``::

   bork-server:~$ sudo chown borks /run/bork

On *bork-client* the socket file is created by ssh, so the user used to connect
to *bork-client* has to have read and write permissions on ``/run/bork``::

   bork-client:~$ sudo chown borkc /run/bork

On *bork-server*, we have to start the command ``bork serve`` and make its
standard input and output available to a unix socket::

   bork-server:~$ socat UNIX-LISTEN:/run/bork/reponame.sock,fork EXEC:"bork serve --append-only --restrict-to-path /path/to/repo"

Socat will wait until a connection is opened. Then socat will execute the
command given, redirecting Standard Input and Output to the unix socket. The
optional arguments for ``bork serve`` are not necessary but a sane default.

.. note::
   When used in production you may also use systemd socket-based activation
   instead of socat on the server side. You would wrap the ``bork serve`` command
   in a `service unit`_ and configure a matching `socket unit`_
   to start the service whenever a client connects to the socket.

   .. _service unit: https://www.freedesktop.org/software/systemd/man/systemd.service.html
   .. _socket unit: https://www.freedesktop.org/software/systemd/man/systemd.socket.html

Now we need a way to access the unix socket on *bork-client* (holding the
data to be backed up), as we created the unix socket on *bork-server*
Opening a SSH connection from the *bork-server* to the *bork-client* with reverse port
forwarding can do this for us::

   bork-server:~$ ssh -R /run/bork/reponame.sock:/run/bork/reponame.sock borkc@bork-client

.. note::

   As the default value of OpenSSH for ``StreamLocalBindUnlink`` is ``no``, the
   socket file created by sshd is not removed. Trying to connect a second time,
   will print a short warning, and the forwarding does **not** take place::

      Warning: remote port forwarding failed for listen path /run/bork/reponame.sock

   When you are done, you have to manually remove the socket file, otherwise
   you may see an error like this when trying to execute bork commands::

      Remote: YYYY/MM/DD HH:MM:SS socat[XXX] E connect(5, AF=1 "/run/bork/reponame.sock", 13): Connection refused
      Connection closed by remote host. Is bork working on the server?


When a process opens the socket on *bork-client*, SSH will forward all
data to the socket on *bork-server*.

The next step is to tell bork on *bork-client* to use the unix socket to communicate with the
``bork serve`` command on *bork-server* via the socat socket instead of SSH::

   bork-client:~$ export BORG_RSH="sh -c 'exec socat STDIO UNIX-CONNECT:/run/bork/reponame.sock'"

The default value for ``BORG_RSH`` is ``ssh``. By default Bork uses SSH to create
the connection to the backup server. Therefore Bork parses the repo URL
and adds the server name (and other arguments) to the SSH command. Those
arguments can not be handled by socat. We wrap the command with ``sh`` to
ignore all arguments intended for the SSH command.

All Bork commands can now be executed on *bork-client*. For example to create a
backup execute the ``bork create`` command::

   bork-client:~$ bork create ssh://bork-server/path/to/repo::archive /path_to_backup

When automating backup creation, the
interactive ssh session may seem inappropriate. An alternative way of creating
a backup may be the following command::

   bork-server:~$ ssh \
      -R /run/bork/reponame.sock:/run/bork/reponame.sock \
      borkc@bork-client \
      bork create \
      --rsh "sh -c 'exec socat STDIO UNIX-CONNECT:/run/bork/reponame.sock'" \
      ssh://bork-server/path/to/repo::archive /path_to_backup \
      ';' rm /run/bork/reponame.sock

This command also automatically removes the socket file after the ``bork
create`` command is done.

ssh-agent
=========

In this scenario *bork-server* initiates an SSH connection to *bork-client* and forwards the authentication
agent connection.

After that, it works similar to the push mode:
*bork-client* initiates another SSH connection back to *bork-server* using the forwarded authentication agent
connection to authenticate itself, starts ``bork serve`` and communicates with it.

Using this method requires ssh access of user *borks* to *borkc@bork-client*, where:

* *borks* is the user on the server side with read/write access to local bork repository.
* *borkc* is the user on the client side with read access to files meant to be backed up.

Applying this method for automated backup operations
----------------------------------------------------

Assume that the bork-client host is untrusted.
Therefore we do some effort to prevent a hostile user on the bork-client side to do something harmful.
In case of a fully trusted bork-client the method could be simplified.

Preparing the server side
~~~~~~~~~~~~~~~~~~~~~~~~~

Do this once for each client on *bork-server* to allow *borks* to connect itself on *bork-server* using a
dedicated ssh key:

::

  borks@bork-server$ install -m 700 -d ~/.ssh/
  borks@bork-server$ ssh-keygen -N '' -t rsa  -f ~/.ssh/bork-client_key
  borks@bork-server$ { echo -n 'command="bork serve --append-only --restrict-to-repo ~/repo",restrict '; cat ~/.ssh/bork-client_key.pub; } >> ~/.ssh/authorized_keys
  borks@bork-server$ chmod 600 ~/.ssh/authorized_keys

``install -m 700 -d ~/.ssh/``

  Create directory ~/.ssh with correct permissions if it does not exist yet.

``ssh-keygen -N '' -t rsa  -f ~/.ssh/bork-client_key``

  Create an ssh key dedicated to communication with bork-client.

.. note::
  Another more complex approach is using a unique ssh key for each pull operation.
  This is more secure as it guarantees that the key will not be used for other purposes.

``{ echo -n 'command="bork serve --append-only --restrict-to-repo ~/repo",restrict '; cat ~/.ssh/bork-client_key.pub; } >> ~/.ssh/authorized_keys``

  Add bork-client's ssh public key to ~/.ssh/authorized_keys with forced command and restricted mode.
  The bork client is restricted to use one repo at the specified path and to append-only operation.
  Commands like *delete*, *prune* and *compact* have to be executed another way, for example directly on *bork-server*
  side or from a privileged, less restricted client (using another authorized_keys entry).

``chmod 600 ~/.ssh/authorized_keys``

  Fix permissions of ~/.ssh/authorized_keys.

Pull operation
~~~~~~~~~~~~~~

Initiating bork command execution from *bork-server* (e.g. init)::

  borks@bork-server$ (
    eval $(ssh-agent) > /dev/null
    ssh-add -q ~/.ssh/bork-client_key
    echo 'your secure bork key passphrase' | \
      ssh -A -o StrictHostKeyChecking=no borkc@bork-client "BORG_PASSPHRASE=\$(cat) bork --rsh 'ssh -o StrictHostKeyChecking=no' init --encryption repokey ssh://borks@bork-server/~/repo"
    kill "${SSH_AGENT_PID}"
  )

Parentheses around commands are needed to avoid interference with a possibly already running ssh-agent.
Parentheses are not needed when using a dedicated bash process.

``eval $(ssh-agent) > /dev/null``

  Run the SSH agent in the background and export related environment variables to the current bash session.

``ssh-add -q ~/.ssh/bork-client_key``

  Load the SSH private key dedicated to communication with the bork-client into the SSH agent.
  Look at ``man 1 ssh-add`` for a more detailed explanation.

.. note::
  Care needs to be taken when loading keys into the SSH agent. Users on the *bork-client* having read/write permissions
  to the agent's UNIX-domain socket (at least borkc and root in our case) can access the agent on *bork-server* through
  the forwarded connection and can authenticate using any of the identities loaded into the agent
  (look at ``man 1 ssh`` for more detailed explanation). Therefore there are some security considerations:

  * Private keys loaded into the agent must not be used to enable access anywhere else.
  * The keys meant to be loaded into the agent must be specified explicitly, not from default locations.
  * The *bork-client*'s entry in *borks@bork-server:~/.ssh/authorized_keys* must be as restrictive as possible.

``echo 'your secure bork key passphrase' | ssh -A -o StrictHostKeyChecking=no borkc@bork-client "BORG_PASSPHRASE=\$(cat) bork --rsh 'ssh -o StrictHostKeyChecking=no' init --encryption repokey ssh://borks@bork-server/~/repo"``

  Run the *bork init* command on *bork-client*.

  *ssh://borks@bork-server/~/repo* refers to the repository *repo* within borks's home directory on *bork-server*.

  *StrictHostKeyChecking=no* is used to automatically add host keys to *~/.ssh/known_hosts* without user intervention.

``kill "${SSH_AGENT_PID}"``

  Kill ssh-agent with loaded keys when it is not needed anymore.

# Configuration for send -h
# Tries to emulate a human typing
# Tweak this if typing is too fast or too slow
set send_human {.05 .1 1 .01 .2}

set script {
# For the pro users, here are some advanced features of bork, so you can impress your friends. ;)
# Note: This screencast was made with __BORK_VERSION__ – older or newer bork versions may behave differently.

# First of all, we can use several environment variables for bork.
# E.g. we do not want to type in our repo path and password again and again…
export BORK_REPO='/media/backup/borkdemo'
export BORK_PASSPHRASE='1234'
# Problem solved, bork will use this automatically… :)
# We'll use this right away…

## ADVANCED CREATION ##

# We can also use some placeholders in our archive name…
bork create --stats --progress --compression lz4 ::{user}-{now} Wallpaper
# Notice the backup name.

# And we can put completely different data, with different backup settings, in our backup. It will be deduplicated, anyway:
bork create --stats --progress --compression zlib,6 --exclude ~/Downloads/big ::{user}-{now} ~/Downloads

# Or let's backup a device via STDIN.
sudo dd if=/dev/loop0 bs=10M | bork create --progress --stats ::specialbackup -

# Let's continue with some simple things:
## USEFUL COMMANDS ##
# You can show some information about an archive. You can even do it without needing to specify the archive name:
bork info :: --last 1

# So let's rename our last archive:
bork rename ::specialbackup backup-block-device

bork info :: --last 1

# A very important step if you choose keyfile mode (where the keyfile is only saved locally) is to export your keyfile and possibly print it, etc.
bork key export --qr-html :: file.html  # this creates a nice HTML, but when you want something simpler…
bork key export --paper ::  # this is a "manual input"-only backup (but it is also included in the --qr-code option)

## MAINTENANCE ##
# Sometimes backups get broken or we want a regular "checkup" that everything is okay…
bork check -v ::

# Next problem: Usually you do not have infinite disk space. So you may need to prune your archive…
# You can tune this in every detail. See the docs for details. Here only a simple example:
bork prune --list --keep-last 1 --dry-run
# When actually executing it in a script, you have to use it without the --dry-run option, of course.

## RESTORE ##

# When you want to see the diff between two archives use this command.
# E.g. what happened between the first two backups?
bork diff ::backup1 backup2
# Ah, we added a file, right…

# There are also other ways to extract the data.
# E.g. as a tar archive.
bork export-tar --progress ::backup2 backup.tar.gz
ls -l

# You can mount an archive or even the whole repository:
mkdir /tmp/mount
bork mount :: /tmp/mount
ls -la /tmp/mount
bork umount /tmp/mount

# That's it, but of course there is more to explore, so have a look at the docs.
}

set script [string trim $script]
set script [string map [list __BORK_VERSION__ [exec bork -V]] $script]
set script [split $script \n]

set ::env(PS1) "$ "
set stty_init -echo
spawn -noecho /bin/sh
foreach line $script {
	expect "$ "
	send_user -h $line\n
	send $line\n
}
expect "$ "

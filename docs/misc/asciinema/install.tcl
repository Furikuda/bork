# Configuration for send -h
# Tries to emulate a human typing
# Tweak this if typing is too fast or too slow
set send_human {.05 .1 1 .01 .2}

set script [string trim {
# This asciinema will show you the installation of bork as a standalone binary. Usually you only need this if you want to have an up-to-date version of bork or no package is available for your distro/OS.

# First, we need to download the version, we'd like to install…
wget -q --show-progress https://github.com/furikuda/bork/releases/download/1.2.1/bork-linux64
# and do not forget the GPG signature…!
wget -q --show-progress https://github.com/furikuda/bork/releases/download/1.2.1/bork-linux64.asc

# In this case, we have already imported the public key of a bork developer. So we only need to verify it:
gpg --verify bork-linux64.asc
# Okay, the binary is valid!

# Now install it:
sudo cp bork-linux64 /usr/local/bin/bork
sudo chown root:root /usr/local/bin/bork
# and make it executable…
sudo chmod 755 /usr/local/bin/bork

# Now check it: (possibly needs a terminal restart)
bork -V

# That's it! Check out the other screencasts to see how to actually use borkbackup.
}]

# wget may be slow
set timeout -1

foreach line [split $script \n] {
	send_user "$ "
	send_user -h $line\n
	spawn -noecho /bin/sh -c $line
	expect eof
}

# -*- mode: ruby -*-
# vi: set ft=ruby :

# Automated creation of testing environments / binaries on misc. platforms

$cpus = Integer(ENV.fetch('VMCPUS', '4'))  # create VMs with that many cpus
$xdistn = Integer(ENV.fetch('XDISTN', '4'))  # dispatch tests to that many pytest workers
$wmem = $xdistn * 256  # give the VM additional memory for workers [MB]

def packages_debianoid(user)
  return <<-EOF
    apt update
    # install all the (security and other) updates
    apt dist-upgrade -y
    # for building borgbackup and dependencies:
    apt install -y libssl-dev libacl1-dev liblz4-dev libfuse-dev fuse pkg-config
    usermod -a -G fuse #{user}
    chgrp fuse /dev/fuse
    chmod 666 /dev/fuse
    apt install -y fakeroot build-essential git curl
    apt install -y python3-dev python3-setuptools python-virtualenv python3-virtualenv
    # for building python:
    apt install -y zlib1g-dev libbz2-dev libncurses5-dev libreadline-dev liblzma-dev libsqlite3-dev libffi-dev
  EOF
end

def packages_arch
  return <<-EOF
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
    locale-gen
    localectl set-locale LANG=en_US.UTF-8
    chown vagrant.vagrant /vagrant
    pacman --sync --noconfirm python-virtualenv python-pip
  EOF
end

def packages_freebsd
  return <<-EOF
    # in case the VM has no hostname set
    hostname freebsd
    # install all the (security and other) updates, base system
    freebsd-update --not-running-from-cron fetch install
    # for building borgbackup and dependencies:
    pkg install -y openssl-devel liblz4 fusefs-libs pkgconf
    pkg install -y fakeroot git bash
    # for building python:
    pkg install -y sqlite3
    pkg install -y py27-virtualenv  # provides "virtualenv" command
    pkg install -y python36 py36-virtualenv py36-pip
    # make sure there is a python3 command
    ln -s /usr/local/bin/python3.6 /usr/local/bin/python3
    # make bash default / work:
    chsh -s bash vagrant
    mount -t fdescfs fdesc /dev/fd
    echo 'fdesc        /dev/fd         fdescfs         rw      0       0' >> /etc/fstab
    # make FUSE work
    echo 'fuse_load="YES"' >> /boot/loader.conf
    echo 'vfs.usermount=1' >> /etc/sysctl.conf
    kldload fuse
    sysctl vfs.usermount=1
    pw groupmod operator -M vagrant
    # /dev/fuse has group operator
    chmod 666 /dev/fuse
    # install all the (security and other) updates, packages
    pkg update
    yes | pkg upgrade
  EOF
end

def install_pyenv(boxname)
  return <<-EOF
    curl -s -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash
    echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bash_profile
    echo 'eval "$(pyenv init -)"' >> ~/.bash_profile
    echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bash_profile
    echo 'export PYTHON_CONFIGURE_OPTS="--enable-shared"' >> ~/.bash_profile
  EOF
end

def fix_pyenv_darwin(boxname)
  return <<-EOF
    echo 'export PYTHON_CONFIGURE_OPTS="--enable-framework"' >> ~/.bash_profile
  EOF
end

def install_pythons(boxname)
  return <<-EOF
    . ~/.bash_profile
    pyenv install 3.6.0  # tests
    pyenv install 3.6.5  # binary build, use latest 3.6.x release
    pyenv rehash
  EOF
end

def build_sys_venv(boxname)
  return <<-EOF
    . ~/.bash_profile
    cd /vagrant/borg
    virtualenv --python=python3 borg-env
  EOF
end

def build_pyenv_venv(boxname)
  return <<-EOF
    . ~/.bash_profile
    cd /vagrant/borg
    # use the latest 3.6 release
    pyenv global 3.6.5
    pyenv virtualenv 3.6.5 borg-env
    ln -s ~/.pyenv/versions/borg-env .
  EOF
end

def install_borg(fuse)
  script = <<-EOF
    . ~/.bash_profile
    cd /vagrant/borg
    . borg-env/bin/activate
    pip install -U wheel  # upgrade wheel, too old for 3.5
    cd borg
    pip install -r requirements.d/development.txt
    python setup.py clean
  EOF
  if fuse
    script += <<-EOF
      # by using [fuse], setup.py can handle different FUSE requirements:
      pip install -e .[fuse]
    EOF
  else
    script += <<-EOF
      pip install -e .
      # do not install llfuse into the virtualenvs built by tox:
      sed -i.bak '/fuse.txt/d' tox.ini
    EOF
  end
  return script
end

def install_pyinstaller()
  return <<-EOF
    . ~/.bash_profile
    cd /vagrant/borg
    . borg-env/bin/activate
    git clone https://github.com/thomaswaldmann/pyinstaller.git
    cd pyinstaller
    git checkout v3.3-fixed
    python setup.py install
  EOF
end

def build_binary_with_pyinstaller(boxname)
  return <<-EOF
    . ~/.bash_profile
    cd /vagrant/borg
    . borg-env/bin/activate
    cd borg
    pyinstaller --clean --distpath=/vagrant/borg scripts/borg.exe.spec
    echo 'export PATH="/vagrant/borg:$PATH"' >> ~/.bash_profile
  EOF
end

def run_tests(boxname)
  return <<-EOF
    . ~/.bash_profile
    cd /vagrant/borg/borg
    . ../borg-env/bin/activate
    if which pyenv 2> /dev/null; then
      # for testing, use the earliest point releases of the supported python versions:
      pyenv global 3.6.0
      pyenv local 3.6.0
    fi
    # otherwise: just use the system python
    if which fakeroot 2> /dev/null; then
      echo "Running tox WITH fakeroot -u"
      fakeroot -u tox --skip-missing-interpreters
    else
      echo "Running tox WITHOUT fakeroot -u"
      tox --skip-missing-interpreters
    fi
  EOF
end

def fs_init(user)
  return <<-EOF
    # clean up (wrong/outdated) stuff we likely got via rsync:
    rm -rf /vagrant/borg/borg/.tox 2> /dev/null
    rm -rf /vagrant/borg/borg/borgbackup.egg-info 2> /dev/null
    rm -rf /vagrant/borg/borg/__pycache__ 2> /dev/null
    find /vagrant/borg/borg/src -name '__pycache__' -exec rm -rf {} \\; 2> /dev/null
    chown -R #{user} /vagrant/borg
    touch ~#{user}/.bash_profile ; chown #{user} ~#{user}/.bash_profile
    echo 'export LANG=en_US.UTF-8' >> ~#{user}/.bash_profile
    echo 'export LC_CTYPE=en_US.UTF-8' >> ~#{user}/.bash_profile
    echo 'export XDISTN=#{$xdistn}' >> ~#{user}/.bash_profile
  EOF
end

Vagrant.configure(2) do |config|
  # use rsync to copy content to the folder
  config.vm.synced_folder ".", "/vagrant/borg/borg", :type => "rsync", :rsync__args => ["--verbose", "--archive", "--delete", "-z"], :rsync__chown => false
  # do not let the VM access . on the host machine via the default shared folder!
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.provider :virtualbox do |v|
    #v.gui = true
    v.cpus = $cpus
  end

  config.vm.define "bionic64" do |b|
    b.vm.box = "ubuntu/bionic64"
    b.vm.provider :virtualbox do |v|
      v.memory = 1024 + $wmem
    end
    b.vm.provision "fs init", :type => :shell, :inline => fs_init("vagrant")
    b.vm.provision "packages debianoid", :type => :shell, :inline => packages_debianoid("vagrant")
    b.vm.provision "build env", :type => :shell, :privileged => false, :inline => build_sys_venv("bionic64")
    b.vm.provision "install borg", :type => :shell, :privileged => false, :inline => install_borg(true)
    b.vm.provision "run tests", :type => :shell, :privileged => false, :inline => run_tests("bionic64")
  end

  config.vm.define "stretch64" do |b|
    b.vm.box = "debian/stretch64"
    b.vm.provider :virtualbox do |v|
      v.memory = 1024 + $wmem
    end
    b.vm.provision "fs init", :type => :shell, :inline => fs_init("vagrant")
    b.vm.provision "packages debianoid", :type => :shell, :inline => packages_debianoid("vagrant")
    b.vm.provision "install pyenv", :type => :shell, :privileged => false, :inline => install_pyenv("stretch64")
    b.vm.provision "install pythons", :type => :shell, :privileged => false, :inline => install_pythons("stretch64")
    b.vm.provision "build env", :type => :shell, :privileged => false, :inline => build_pyenv_venv("stretch64")
    b.vm.provision "install borg", :type => :shell, :privileged => false, :inline => install_borg(true)
    b.vm.provision "install pyinstaller", :type => :shell, :privileged => false, :inline => install_pyinstaller()
    b.vm.provision "build binary with pyinstaller", :type => :shell, :privileged => false, :inline => build_binary_with_pyinstaller("stretch64")
    b.vm.provision "run tests", :type => :shell, :privileged => false, :inline => run_tests("stretch64")
  end

  config.vm.define "arch64" do |b|
    b.vm.box = "terrywang/archlinux"
    b.vm.provider :virtualbox do |v|
      v.memory = 1024 + $wmem
    end
    b.vm.provision "fs init", :type => :shell, :inline => fs_init("vagrant")
    b.vm.provision "packages arch", :type => :shell, :privileged => true, :inline => packages_arch
    b.vm.provision "build env", :type => :shell, :privileged => false, :inline => build_sys_venv("arch64")
    b.vm.provision "install borg", :type => :shell, :privileged => false, :inline => install_borg(true)
    b.vm.provision "run tests", :type => :shell, :privileged => false, :inline => run_tests("arch64")
  end

  config.vm.define "freebsd64" do |b|
    b.vm.box = "freebsd12-amd64"
    b.vm.provider :virtualbox do |v|
      v.memory = 1024 + $wmem
    end
    b.ssh.shell = "sh"
    b.vm.provision "fs init", :type => :shell, :inline => fs_init("vagrant")
    b.vm.provision "packages freebsd", :type => :shell, :inline => packages_freebsd
    b.vm.provision "build env", :type => :shell, :privileged => false, :inline => build_sys_venv("freebsd64")
    b.vm.provision "install borg", :type => :shell, :privileged => false, :inline => install_borg(true)
    b.vm.provision "install pyinstaller", :type => :shell, :privileged => false, :inline => install_pyinstaller()
    b.vm.provision "build binary with pyinstaller", :type => :shell, :privileged => false, :inline => build_binary_with_pyinstaller("freebsd64")
    b.vm.provision "run tests", :type => :shell, :privileged => false, :inline => run_tests("freebsd64")
  end

  # TODO: create more VMs with python 3.5+ and openssl 1.1.
  # See branch 1.1-maint for a better equipped Vagrantfile (but still on py34 and openssl 1.0).
end

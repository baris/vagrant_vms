class ns {
  file {"/etc/resolv.conf":
    content => "nameserver 8.8.8.8\n",
    mode => 0644,
  }
}

class packages {
  file{ '/etc/apt/sources.list.d/emacs24.list':
    content => "deb http://ppa.launchpad.net/cassou/emacs/ubuntu lucid main",
    mode => 0644,
  }

  exec { 'apt-key for emacs24':
    command => "/usr/bin/apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 84DBCE2DCEC45805",
    require => File['/etc/apt/sources.list.d/emacs24.list'],
    refreshonly => true,
  }

  exec { 'apt-get update':
    command => '/usr/bin/apt-get update',
    require => Exec['apt-key for emacs24'],
    refreshonly => true,
  }

  package {"git-core":
    ensure => present,
    require => Exec['apt-get update'],
  }

  package {"emacs-snapshot-nox":
    ensure => present,
    require => Exec['apt-get update'],
  }
}

class repos {
  file { '/home/vagrant/repos/':
    ensure => "directory",
    recurse => true,
    mode => 0777,
    owner => "vagrant",
  }
  
  exec { 'clone emacs':
    cwd => "/home/vagrant/repos",
    path => ["/usr/bin/"],
    command => "git clone https://github.com/baris/emacs.git",
    require => File['/home/vagrant/repos'],
  }

  file { '/home/vagrant/repos/emacs':
    recurse => true,
    owner => "vagrant",
    require => Exec['clone emacs'],
  }

  file { '/home/vagrant/.emacs':
    content => "(load-file \"/home/vagrant/repos/emacs/dotemacs.el\")\n",
  }
}


class {"ns":}
class {"packages":
  require => Class['ns']
}
class {"repos":
  require => Class['packages']
}

# Class: mongodb
#
# This class installs MongoDB (stable)
#
# Notes:
#  This class is Ubuntu specific.
#  By Sean Porter Consulting
#
# Actions:
#  - Install MongoDB using a 10gen Ubuntu repository
#  - Manage the MongoDB service
#  - MongoDB can be part of a replica set
#
# Sample Usage:
#  class { mongodb:
#    replSet => "myReplicaSet",
#    ulimit_nofile => 20000,
#  }
#
class mongodb(
  $replSet = $mongodb::params::replSet,
  $respawn = $mongodb::params::respawn,
  $ulimit_nofile = $mongodb::params::ulimit_nofile,
  $repository = $mongodb::params::repository,
  $package = $mongodb::params::package,
  $enable_service = true
) inherits mongodb::params {

  exec { "10gen-apt-key":
    path => "/bin:/usr/bin",
    command => "apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10",
    unless => "apt-key list | grep 10gen",
  }

  exec { "10gen-apt-repo":
    path => "/bin:/usr/bin",
    command => "echo '${repository}' >> /etc/apt/sources.list",
    unless => "cat /etc/apt/sources.list | grep 10gen",
    require => Exec["10gen-apt-key"],
  }

  exec { "10gen-apt-update":
    path => "/bin:/usr/bin",
    command => "apt-get update",
    unless => "ls /usr/bin | grep mongo",
    require => Exec["10gen-apt-repo"],
  }

  package { $package:
    ensure => installed,
    require => Exec["10gen-apt-update"],
  }

  if $enable_service == true {
    service { "mongodb":
      name => 'mongod',
      enable => true,
      ensure => running,
      require => Package[$package],
    }
  } else {
    service { "mongodb":
      name => 'mongod',
      enable => false,
      ensure => stopped,
      require => Package[$package],
    }
  }

# MongoDB 2.6 uses /etc/mongod.conf instead, but erb template is obsolete
#  file { "/etc/init/mongod.conf":
#    content => template("mongodb/mongodb.conf.erb"),
#    mode => "0644",
#    notify => Service["mongodb"],
#    require => Package[$package],
#  }

}

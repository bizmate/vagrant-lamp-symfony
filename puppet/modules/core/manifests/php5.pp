class core::php5 {
	# NOTE: this repository was recently updated to include PHP 5.5 and Apache 2.4,
	# which is not compatible with the OpenEyes application.
	# (PHP5.5 needs dh-apache2 which is provided only by apache2.4.)

	exec { 'apt-repository-php5':
	  command => '/usr/bin/add-apt-repository ppa:ondrej/php5',
	  require => Package['python-software-properties'],
	}

	exec { 'apt-update-php5':
	  command => '/usr/bin/apt-get update',
	  require => Exec['apt-repository-php5']
	}

	package { 'python-software-properties':
	  ensure  => present,
	  require => Exec['apt-update'],
	}

	package { 'php5':
		ensure  => present,
		require => Exec['apt-update-php5'],
		notify  => Service['apache2']
	}

  package { 'php5-cli':
    ensure  => present,
    require => Exec['apt-update']
  }

	package { 'php5-curl':
		ensure  => present,
		require => Exec['apt-update'],
		notify  => Service['apache2']
	}

  package { 'php5-intl':
    ensure  => present,
    require => Exec['apt-update'],
    notify  => Service['apache2']
  }

  package { 'php5-apcu':
    ensure  => present,
    require => Exec['apt-update'],
    notify  => Service['apache2']
  }

	file {'/etc/php5/cli/conf.d/buffering_settings.ini':
		ensure => present,
		owner => root, group => root, mode => 444,
		content => "output_buffering = On \n
		zend.enable_gc = 0 \n
		date.timezone = Europe/London\n
		realpath_cache_size = 4096k\n
		realpath_cache_ttl=7200\n
		apc.enabled=1
		",
		require => [ Exec['apt-update-php5'], Package['php5', 'php5-cli'] ],
		notify  => Service['apache2']
	}

  file {'/etc/php5/apache2/conf.d/extra_settings.ini':
    ensure => present,
    owner => root, group => root, mode => 444,
    content => "output_buffering = On \n
		zend.enable_gc = 0 \n
		date.timezone = Europe/London\n
		realpath_cache_size = 4096k\n
		realpath_cache_ttl=7200\n
		apc.enabled=1
		",
    require => [ Exec['apt-update-php5'], Package['php5', 'php5-cli'] ],
    notify  => Service['apache2']
  }
}
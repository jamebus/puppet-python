#
# @summary Manages Gunicorn virtual hosts.
#
# @param ensure
# @param config_dir Configure the gunicorn config directory path. Default: /etc/gunicorn.d
# @param manage_config_dir Set if the gunicorn config directory should be created. Default: false
# @param virtualenv Run in virtualenv, specify directory. Default: disabled
# @param mode Gunicorn mode.
# @param dir Application directory.
# @param bind Bind on: 'HOST', 'HOST:PORT', 'unix:PATH'.
#  Default: system-wide: unix:/tmp/gunicorn-$name.socket
#           virtualenv:  unix:${virtualenv}/${name}.socket
# @param environment Set ENVIRONMENT variable. Default: none
# @param appmodule Set the application module name for gunicorn to load when not using Django.
# @param osenv Allows setting environment variables for the gunicorn service. Accepts a hash of 'key': 'value' pairs.
# @param timeout Allows setting the gunicorn idle worker process time before being killed. The unit of time is seconds.
# @param template Which ERB template to use. Default: python/gunicorn.erb
# @param args Custom arguments to add in gunicorn config file. Default: []
#
# @example run gunicorn on vhost in virtualenv /var/www/project1
#  python::gunicorn { 'vhost':
#    ensure      => present,
#    virtualenv  => '/var/www/project1',
#    mode        => 'wsgi',
#    dir         => '/var/www/project1/current',
#    bind        => 'unix:/tmp/gunicorn.socket',
#    environment => 'prod',
#    owner       => 'www-data',
#    group       => 'www-data',
#    appmodule   => 'app:app',
#    osenv       => { 'DBHOST' => 'dbserver.example.com' },
#    timeout     => 30,
#    template    => 'python/gunicorn.erb',
#  }
#
define python::gunicorn (
  $ensure                       = present,
  $config_dir                   = '/etc/gunicorn.d',
  $manage_config_dir            = false,
  $virtualenv                   = false,
  Enum['wsgi', 'django'] $mode  = 'wsgi',
  $dir                          = false,
  $bind                         = false,
  $environment                  = false,
  $owner                        = 'www-data',
  $group                        = 'www-data',
  $appmodule                    = 'app:app',
  $osenv                        = false,
  $timeout                      = 30,
  $workers                      = false,
  $access_log_format            = false,
  $accesslog                    = false,
  $errorlog                     = false,
  $log_level                     = 'error',
  $template                     = 'python/gunicorn.erb',
  $args                         = [],
) {

  # Parameter validation
  if ! $dir {
    fail('python::gunicorn: dir parameter must not be empty')
  }

  validate_re($log_level, 'debug|info|warning|error|critical', "Invalid \$log_level value ${log_level}")

  if $manage_config_dir {
    file { $config_dir:
      ensure => directory,
      mode   => '0755',
      owner  => 'root',
      group  => 'root',
    }
    file { "${config_dir}/${name}":
      ensure  => $ensure,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => template($template),
      require => File[$config_dir],
    }
  } else {
    file { "${config_dir}/${name}":
      ensure  => $ensure,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => template($template),
    }
  }

}

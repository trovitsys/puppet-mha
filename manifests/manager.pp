# == Class: mha::manager
#
# This class installs and cofigures MHA Manager. It's called by mha::manager::instance
# define and you should not call it directly. However, you can and should configure
# your own parameter with this class (we suggest you to use Hiera)
#
# === Parameters
# 
# Most of these parameters are a 1to1 implementation of MHA specific paramaters, so
# please check MHA docs to have more details
#
# https://code.google.com/p/mysql-master-ha/wiki/Parameters
#
# [*manager_name*]
#   Name of the MHA manager
# [*mha_conf_dir*]
#   Base directory for MHA configuration file. Usually under /etc
# [*workdir*]
#   Base directory for MHA manager runtime files. Usually under /var/run
# [*user*]
#   Run MHA scripts as this user
# [*group*]
#   Run MHA scripts as this group
# [*ssh_user*]
#   Connect to remote nodes with this SSH user
# [*ssh_port*]
#   Remote node SSH port
# [*ssh_connection_timeout*]
#   SSH tiemout
# [*ssh_options*]
#   Custom SSH options
# [*skip_reset_slave*]
#   If set to 1, MHA will not issue a RESET SLAVE command upon master failover
# [*mysql_user*]
#   Used to connect to node's mysqld for status check and it will be passed to custom scripts too
# [*mysql_password*]
#   Used to connect to node's mysqld for status check and it will be passed to custom scripts too
# [*port*]
#   Used to connect to node's mysqld for status check and it will be passed to custom scripts too
# [*repl_user*]
#   Used to connect to node's mysqld for status check and it will be passed to custom scripts too
# [*repl_password*]
#   Used to connect to node's mysqld for status check and it will be passed to custom scripts too
# [*disable_log_bin*]
#   When this option is set, when applying differential relay logs to slaves, slaves do not generate binary logs.
# [*master_pid_file*]
#  Setting master's pid file. This might be useful when you are running multiple MySQL instances within single server.
# [*log_level*]
#  Logging threshold that MHA Manager prints. Default is info and should be fine in most cases.
# [*check_repl_delay*]
#  If a slave behinds master more than check_repl_delayMB of relay logs ), MHA does not choice the slave as a new master
# [*check_repl_filter*]
#  If set to 1 and any of the master and slaves has different binary log / replication filtering rule each other, 
#  MHA prints errors and does not start monitoring or failover.
# [*latest_priority*]
#  By default, the latest slave (a slave receives the latest binlog events) is prioritized as a new master
# [*multi_tier_slave*]
#  Used for multi-master replication configuration
# [*ping_interval* N]
#  Check every N seconds if mysql is alive  
# [*ping_type*]
#  Set how to check if mysql is alive. Please read MHA docs for further info
# [*secondary_check_script*]
#  Secondary script to check mysql, possibly through another route
# [*master_ip_failover_script*]
#  Path to the template which will handle automatic master failover 
# [*master_ip_online_change_script*]
#  Path to the template of the script which will handle manual role switch
# [*shutdown_script*]
#  Path to the template of the script which will handle master shutdown
# [*report_script*]
#  Path to the template of the script which will handle reports 
# [*init_conf_load_script*]
#  Path to the template of the script that can be used to print MHA conf value (i.e. passwords)
#  We prefer to use Hiera + eYAML to store passwords
# [*remote_workdir*]
#  Base directory for MHA node runtime files
# [*master_binlog_dir*]
#  Directory full path name where MySQL generates binary logs on the master. 
#
# === Authors
#
# Jordi Clariana <jclariana@trovit.com> <jordiclariana@gmail.com>
# Davide Ferrari <davide@trovit.com> <vide80@gmail.com>
#
# === Copyright
#
# Copyright 2015 Trovit Search S.L.
#
class mha::manager (
  $manager_name                   = $mha::params::manager_name,
  $mha_conf_dir                   = $mha::params::mha_conf_dir,
  $workdir                        = $mha::params::workdir,
  $user                           = $mha::params::user,
  $group                          = $mha::params::group,
  $ssh_user                       = $mha::params::ssh_user,
  $ssh_port                       = $mha::params::ssh_port,
  $ssh_connection_timeout         = $mha::params::ssh_connection_timeout,
  $ssh_options                    = $mha::params::ssh_options,
  $skip_reset_slave               = $mha::params::skip_reset_slave,
  $mysql_user                     = $mha::params::mysql_user,
  $mysql_password                 = $mha::params::mysql_password,
  $port                           = $mha::params::port,
  $repl_user                      = $mha::params::repl_user,
  $repl_password                  = $mha::params::repl_password,
  $disable_log_bin                = $mha::params::disable_log_bin,
  $master_pid_file                = $mha::params::master_pid_file,
  $log_level                      = $mha::params::log_level,
  $check_repl_delay               = $mha::params::check_repl_delay,
  $check_repl_filter              = $mha::params::check_repl_filter,
  $latest_priority                = $mha::params::latest_priority,
  $multi_tier_slave               = $mha::params::multi_tier_slave,
  $ping_interval                  = $mha::params::ping_interval,
  $ping_type                      = $mha::params::ping_type,
  $secondary_check_script         = $mha::params::secondary_check_script,
  $master_ip_failover_script      = $mha::params::master_ip_failover_script,
  $master_ip_online_change_script = $mha::params::master_ip_online_change_script,
  $shutdown_script                = $mha::params::shutdown_script,
  $report_script                  = $mha::params::report_script,
  $init_conf_load_script          = $mha::params::init_conf_load_script,
  $remote_workdir                 = $mha::params::remote_workdir,
  $master_binlog_dir              = $mha::params::master_binlog_dir
) inherits mha::params {

  package { [ 'mha4mysql-manager', 'mha4mysql-node' ]:
    ensure => installed
  }

  File {
    owner   => $user,
    group   => $group
  }

  file { $mha_conf_dir:
    ensure => directory
  }

  @@file { $workdir:
    ensure => directory,
    tag    => "mha_workdir_${manager_name}"
  }

  file { "${mha_conf_dir}/scripts":
    ensure  => directory,
    require => File[$mha_conf_dir]
  }

  file { '/etc/masterha_default.cnf':
    ensure  => present,
    mode    => '0600',
    content => template('mha/masterha_default.cnf.erb')
  }

}

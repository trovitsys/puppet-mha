# == Define: mha::manager::instance
#
# This define configure a MHA manager instance. You can use an instance to control a cluster
# and so you can control many clusters using the same MHA manager installation
#
# === Parameters
#
# Most of these parameters are a 1to1 implementation of MHA specific paramaters, so
# please check MHA docs to have more details
#
# https://code.google.com/p/mysql-master-ha/wiki/Parameters
#
# [*cluster_name*] NAMEVAR
#   String.
#   Specify the cluster name ID. Do not use spaces.
# [*servers*]
#   Hash.
#   An hash of servers that compose the cluser. Be careful: the hash key should always be in 
#   the form "server01" "server02" etc. It's an MHA thing.
#   You can pass more options as a sub-hash (for example, "hostname")
# [*mysql_user*]
#   String.
#   Used to connect to node's mysqld for status check and it will be passed to custom scripts too
# [*mysql_password*]
#   String.
#   Used to connect to node's mysqld for status check and it will be passed to custom scripts too
# [*repl_user*]
#   String.
#   Used to connect to node's mysqld for status check and it will be passed to custom scripts too
# [*repl_password*]
#   String.
#   Used to connect to node's mysqld for status check and it will be passed to custom scripts too
# [*ssh_user*]
#   String.
#   Connect to remote nodes with this SSH user
# [*user_home*]
#   String.
#   Remote node's user home directory
# [*ssh_key_priv*]
#   String.
#   Define private SSH key for ssh_user
# [*ssh_key_pub*]
#   String.
#   Define public SSH key for ssh_user
# [*ssh_key_type*]
#   String.
#   Define SSH key type for ssh_user
# [*master_ip_failover_script*]
#   String.
#   Path to the template which will handle automatic master failover. Overrides mha::manager
# [*master_ip_online_change_script*]
#   String.
#   Path to the template of the script which will handle manual role switch. Overrides mha::manager
# [*shutdown_script*]
#   String.
#   Path to the template of the script which will handle master shutdown. Overrides mha::manager
# [*report_script*]
#   String.
#   Path to the template of the script which will handle reports. Overrides mha::manager
# [*extra_options*]
#   Hash.
#   Generic extra option you would like to add to an instance
# [*wait_on_monitor_error*] N
#   Integer.
#   If an error happens during monitoring, masterha_manager sleeps wait_on_monitor_error seconds and exits.
# [*wait_on_failover_error*] N
#   Integer. 
#   If an error happens during failover, MHA Manager sleeps wait_on_failover_error seconds and exits.
# [*daemon*]
#   Boolean.
#   Set it to true to execute MHA scripts for this instance as a daemon with daemontools. 
#   Optional and tested only under Debian Wheezy
#
define mha::manager::instance (
  $servers,
  $mysql_user,
  $mysql_password,
  $mysql_repl_user,
  $mysql_repl_password,
  $ssh_key_priv,
  $ssh_key_pub,
  $ssh_key_type,
  $master_binlog_dir,
  $cluster_name           = $name,
  $user_home              = '/root',
  $ssh_user               = 'root',
  $manager_log            = '',
  $ssh_options            = '',
  $online_change_script   = '',
  $failover_script        = '',
  $report_script          = '',
  $extra_options          = {},
  $wait_on_monitor_error  = 60,
  $wait_on_failover_error = 60,
  $daemon                 = false
) {

  include mha::manager

  if ( $manager_log == '' or $manager_log == undef) {
    $real_manager_log = "/var/log/masterha_${cluster_name}.log"
  }
  else {
    $real_manager_log = $manager_log
  }

  $real_ssh_options = $ssh_options ? {
    ''      => "-i ${user_home}/.ssh/id_${ssh_key_type}_${cluster_name}",
    default => $ssh_options
  }

  File {
    owner   => $mha::manager::user,
    group   => $mha::manager::group
  }

  @@file { "${user_home}/.ssh/id_${ssh_key_type}_${cluster_name}":
    ensure  => present,
    content => $ssh_key_priv,
    mode    => '0600',
    tag     => [ "mha_${cluster_name}", "mha_${cluster_name}_manager" ]
  }

  @@file { "${user_home}/.ssh/id_${ssh_key_type}_${cluster_name}.pub":
    ensure  => present,
    content => "ssh-${ssh_key_type} ${ssh_key_pub} ${mha::manager::user}@mha_${cluster_name}\n",
    mode    => '0644',
    tag     => [ "mha_${cluster_name}", "mha_${cluster_name}_manager" ]
  }

  @@ssh_authorized_key { "mha@${cluster_name}":
    ensure => present,
    type   => "ssh-${ssh_key_type}",
    key    => $ssh_key_pub,
    user   => $mha::manager::user,
    tag    => "mha_${cluster_name}"
  }

  @@file { "${mha::manager::workdir}/${cluster_name}":
    ensure  => directory,
    mode    => '0750',
    tag     => [ "mha_${cluster_name}", "mha_${cluster_name}_manager" ],
    require => File[$mha::manager::workdir]
  }

  File <<| tag == "mha_workdir" |>>
  File <<| tag == "mha_${cluster_name}_manager" |>>

  $mha_cluster_scripts_dir = "${mha::manager::mha_conf_dir}/scripts/${cluster_name}"
  file { $mha_cluster_scripts_dir:
    ensure  => directory,
    require => File["${mha::manager::mha_conf_dir}/scripts"]
  }

  if $online_change_script != '' {
    $mha_online_change_path = "${mha_cluster_scripts_dir}/mha_online_change.sh"
    file { $mha_online_change_path:
      ensure  => present,
      content => template($online_change_script),
      mode    => '0755',
      require => File["${mha_cluster_scripts_dir}"]
    }
  }

  if $failover_script != '' {
    $mha_failover_path = "${mha_cluster_scripts_dir}/mha_failover.sh"
    file { $mha_failover_path:
      ensure  => present,
      content => template($failover_script),
      mode    => '0755',
      require => File["${mha_cluster_scripts_dir}"]
    }
  }

  if $report_script != '' {
    $mha_report_path = "${mha_cluster_scripts_dir}/mha_report.sh"
    file { $mha_report_path:
      ensure  => present,
      content => template($report_script),
      mode    => '0755',
      require => File["${mha_cluster_scripts_dir}"]
    }
  }

  # compiler voodoo: this goes after all thos $mha_*_path variables
  # because otherwise template('mha/mha.conf.erb') won't expand them
  file { "${mha::manager::mha_conf_dir}/${cluster_name}.conf":
    ensure  => present,
    content => template('mha/mha.conf.erb'),
    mode    => '0600',
    require => File[$mha::manager::mha_conf_dir]
  }

  if ($daemon) {
    ensure_packages('daemontools-run')

    file { "/etc/service/masterha_${cluster_name}":
      ensure  => directory,
      require => Package['daemontools-run'],
    }

    file { "/etc/service/masterha_${cluster_name}/run":
      ensure  => present,
      mode    => '0755',
      content => template('mha/masterha_run.erb'),
      require => File["/etc/service/masterha_${cluster_name}"]
    }
  }
}

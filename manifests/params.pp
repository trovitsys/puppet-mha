# mha::params
class mha::params {

  $mha_conf_dir = '/etc/mha'
  $user = 'root'
  $group = 'root'
  $workdir = '/var/run/mha'
  $ssh_user  = 'root'
  $ssh_port = 22
  $ssh_connection_timeout = 5
  $ssh_options = ''
  $skip_reset_slave = 0
  $mysql_user = 'root'
  $mysql_password = ''
  $port = 3306
  $repl_user = ''
  $repl_password = ''
  $disable_log_bin = 0
  $master_pid_file = ''
  $log_level = 'info'
  $check_repl_delay = 1
  $check_repl_filter = 1
  $latest_priority = 1
  $multi_tier_slave = 0
  $ping_interval = 3
  $ping_type = 'SELECT'
  $secondary_check_script = ''
  $master_ip_failover_script = ''
  $master_ip_online_change_script = ''
  $shutdown_script = ''
  $report_script = ''
  $init_conf_load_script = ''
  $remote_workdir = ''
  $master_binlog_dir = ''
}

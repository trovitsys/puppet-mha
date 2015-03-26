# mha::node
class mha::node ( $cluster_name ) {

  package { 'mha4mysql-node':
    ensure => installed
  }

  File <<| tag == 'mha_workdir' |>>
  File <<| tag == "mha_${cluster_name}" |>>
  Ssh_authorized_key <<| tag == "mha_${cluster_name}" |>>

}

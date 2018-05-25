# mha::node
class mha::node (
  $manager_name,
  $cluster_name,
){

  package { 'mha4mysql-node':
    ensure => installed
  }

  File <<| tag == "mha_workdir_${manager_name}" |>>

  File <<| tag == "mha_${cluster_name}" |>>
  Ssh_authorized_key <<| tag == "mha_${cluster_name}" |>>

}

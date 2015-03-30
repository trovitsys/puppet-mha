# puppet-mha

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Usage](#usage)
4. [Limitations](#limitations)
5. [Development](#development)

## Overview

puppet-mha installs and configures a MHA (Mysql High Availability) cluster
This module is provided to you by [Trovit](http://www.trovit.com) Systems department

## Module Description

This module is composed by the manager and the node. The node class is really simple, it
just installs some helper on the mysqld machine, while the manager is where the magic 
happens. puppet-mha helps you installing all the packages, configuring multiple MHA 
instances, giving SSH access to the nodes etc.

## Usage

### How to install a manager

```
  $servers_hash = { 'server01' => { 'hostname' => 'my-server-01' },
                    'server02' => { 'hostname' => 'my-server-02',
                                    'skip_reset_slave' => 1 }
                  } 
  mha::instance { 'my_cluster':
    servers              => $servers_hash,
    mysql_password       => 'foo',
    mysql_repl_password  => 'bar',
    ssh_key_priv         => 'ashdkshaksahdkj',
    ssh_key_pub          => '3j234324jn',
    online_change_script => 'profiles/mha/mha_online_change.sh.erb'
  }
```

Keep in mind that **online_change_script** and all the other *scripts* parameters
must point to a template YOU have to implement. MHA gives you 100% flexibility about
that and so do we.

### How to install a node

```
  include mha::node
```

### Bottom line

This module is thought with the Hiera/create\_resource pattern in mind,
but you can use it happily without hiera and doing all the dirty work
in your manifest.

## Limitations

This module is tested only on Debian 7 Wheezy and expects Puppet 3.7

## Development

If you have some new cool feature or bugfix, just open a PR and we will take
a look at it for sure!
Feel free to open any issue you find too (but a PR is always better :P )

## Release Notes/Contributors/Etc

Release 0.1.1
 - Linter fixes
 - README fixes

Release 0.1.0
 - Initial release

Author: Jordi Clariana <jordiclariana@gmail.com>

Contributors:
 - Davide Ferrari <vide80@gmail.com>


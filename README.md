# Tcpwrappers

## Overview

Manages hosts.allow and hosts.deny.

Requires https://github.com/puppetlabs/puppetlabs-concat
Requires https://github.com/puppetlabs/puppetlabs-stdlib


## Usage

### `tcpwrappers`
```puppet
    include tcpwrappers
```


The following optional parameters are available:

* _ensure_
    * Whether we should have *any* tcpd files around, 'present' or 'absent'.
    Default 'present'.
* _deny\_by\_default_
    * Installs the default 'ALL:ALL' hosts.deny entry if true. Default: true.
* _enable\_hosts\_deny_
    * Puts rejection ACLs in `/etc/hosts.deny` if true. Otherwise, all
    entries are places in `/etc/hosts.allow` and appended with either
    `:ALLOW` or `:DENY`. In this case, `/etc/hosts.deny` is also deleted.
    Default: false

### `tcpwrappers::allow` and `tcpwrappers::deny`
1. Both `tcpwrappers::allow` or `tcpwrappers::deny` add the specified
entry to `hosts.allow` (or `hosts.deny` if `enable_hosts_deny` is `true`).
2. The `name` variable is not significant if the `client` parameter is used.
3. Both types may be called without explicitly calling the `tcpwrappers` class.
```puppet
    # Simple client specification
    tcpwrappers::allow { '10.0.2.0/24': }
    tcpwrappers::deny  { '10.0.1.0/24': }

    # By default, allow comes before default, so:
    tcpwrappers::allow { '10.0.3.1': }
    tcpwrappers::deny  { '10.0.1.0/24': }
    # ...is equivalent to:
    tcpwrappers::allow { '10.0.3.1':     order => '100' }
    tcpwrappers::deny  { '10.0.1.0/24':  order => '200' }

    # To deny a single host, but allow the rest of the subnet ensure the order
    # (requires enable_hosts_deny to be false (default)):
    tcpwrappers::deny  { '10.0.3.1': order => '099' }
    tcpwrappers::allow { '10.0.1.0/24': }

    # Allowing multiple subnets can happen a couple different ways:
    tcpwrappers::allow { ['10.0.1.0/24','10.0.2.0/24]: }

    tcpwrappers::allow { 'my fav subnets':
      comment => 'Need to allow favorite subnets to ALL',
      client  => ['10.0.1.0/24','10.0.2.0/24'],
    }

    tcpwrappers::allow { 'my fav subnets to sshd':
      client => ['10.0.1.0/24','10.0.2.0/24'],
      daemon => 'sshd',
    }

    # With an exception specification
    tcpwrappers::allow { 'ALL':
        daemon => 'mydaemon',
        client => 'ALL',
        except => '/etc/hosts.deny.inc',
    }
```

The following optional parameters are available:

* _ensure_
    * Whether the entry should be 'present' or 'absent'.  Default 'present'.
* _client_
    * The client specification to be added.  May be a string or array or
    strings. Each string must evaluate to a valid IPv4 or IPv6 subnet.
    Default: '$name'.
* _comment_
    * A comment to go above the entry. Default: none.
* _daemon_
    * The identifier supplied to libwrap by the daemon, often just the
    process name. Default: 'ALL'.
* _except_
    * Another client specification, acting as a filter for the first
    client specifiction. Default: none.
* _order_
    * The 3-number digit, signifying the order the line appears in the
    file. Default is '100' for tcpwrappers::allow and '200' for
    tcpwrappers::deny.

The `client` (or `name`) and `except` parameters must have one of the
following forms:

Type           | Example
-------------- | -------
FQDN:          | example.com
Domain suffix: | .example.com
IP address:    | 192.0.2.1
IP prefix:     | 192. 192.0. 192.0.2.
IP range:      | 192.0.2.0/24 192.0.2.0/255.255.255.0
Filename:      | /path/to/file.acl
Keyword:       | ALL LOCAL PARANOID

The client specification will be normalized before being matched against
or added to the existing entries in hosts.allow/hosts.deny.


## See also

hosts.allow(5)

# Initialization class for tcpwrappers module.
class tcpwrappers {

  include concat::setup

  # The files to manage
  $files = ['/etc/hosts.allow','/etc/hosts.deny']

  # Set up virtual concat resource that ensures permissions and ownership.
  @concat { $files :
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  tcpwrappers::comment { "hosts.allow managed by Puppet ${name}":
    type   => 'allow',
    order  => '01',
  }
  tcpwrappers::comment { "hosts.deny managed by Puppet ${name}":
    type   => 'deny',
    order  => '01',
  }
  tcpwrappers::comment { 'Append default deny if not already there.':
    type   => 'deny',
    order  => 98,
  }
  tcpwrappers::deny { 'tcpwrappers/deny-by-default':
    daemon => 'ALL',
    client => 'ALL',
    order  => 99,
  }
}

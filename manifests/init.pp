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

  # Append default deny if not already there
  tcpwrappers::deny { 'tcpwrappers/deny-by-default':
    daemon => 'ALL',
    client => 'ALL',
    order  => 99,
  }
}

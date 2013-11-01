# Defined type to manage hosts.deny
define tcpwrappers::deny(
  $client = $name,
  $daemon = 'ALL',
  $ensure = present,
  $except = undef,
  $order  = 10,
) {
  tcpwrappers::entry { "Deny ${name}":
    ensure => $ensure,
    type   => deny,
    daemon => $daemon,
    client => $client,
    except => $except,
    order  => $order,
  }
}

# Defined type to manage hosts.deny
define tcpwrappers::deny(
  $client,
  $daemon='ALL',
  $ensure='present',
  $except=undef,
  $order='10',
  $comment=undef,
  $allow=false,
) {

  tcpwrappers::entry { $name:
    ensure => $ensure,
    type   => deny,
    daemon => $daemon,
    client => $client,
    except => $except,
    order  => $order,
    allow  => $allow,
  }
}

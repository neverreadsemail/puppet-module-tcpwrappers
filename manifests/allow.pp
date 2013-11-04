# Defined type to manage hosts.allow
define tcpwrappers::allow(
  $client,
  $daemon='ALL',
  $ensure=present,
  $except=undef,
  $order='10',
) {

  tcpwrappers::entry { $name:
    ensure => $ensure,
    type   => allow,
    daemon => $daemon,
    client => $client,
    except => $except,
    order  => $order,
  }
}

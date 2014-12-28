# Defined type to manage hosts.allow
define tcpwrappers::allow(
  $ensure  = 'present',
  $client  = $name,
  $comment = undef,
  $daemon  = 'ALL',
  $except  = undef,
  $order   = '100',
) {
  tcpwrappers::entry { $name :
    ensure  => $ensure,
    action  => 'allow',
    client  => $client,
    comment => $comment,
    daemon  => $daemon,
    except  => $except,
    order   => $order,
  }
}

# Defined type to manage hosts.deny
define tcpwrappers::deny(
  $ensure  = 'present',
  $client  = $name,
  $comment = undef,
  $daemon  = 'ALL',
  $except  = undef,
  $order   = '200',
) {
  tcpwrappers::entry { $name :
    ensure  => $ensure,
    action  => 'deny',
    client  => $client,
    comment => $comment,
    daemon  => $daemon,
    except  => $except,
    order   => $order,
  }
}

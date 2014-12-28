# Defined type to manage hosts.deny
define tcpwrappers::deny(
  $ensure      = 'present',
  $client      = $name,
  $comment     = undef,
  $daemon      = 'ALL',
  $enable_ipv6 = true,
  $except      = undef,
  $order       = '200',
) {
  tcpwrappers::entry { $name :
    ensure      => $ensure,
    action      => 'deny',
    client      => $client,
    comment     => $comment,
    daemon      => $daemon,
    enable_ipv6 => $enable_ipv6,
    except      => $except,
    order       => $order,
  }
}

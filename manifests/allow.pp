# Defined type to manage hosts.allow
define tcpwrappers::allow(
  $ensure      = 'present',
  $client      = $name,
  $comment     = undef,
  $daemon      = 'ALL',
  $enable_ipv6 = true,
  $except      = undef,
  $order       = '100',
) {
  tcpwrappers::entry { $name :
    ensure      => $ensure,
    action      => 'allow',
    client      => $client,
    comment     => $comment,
    daemon      => $daemon,
    enable_ipv6 => $enable_ipv6,
    except      => $except,
    order       => $order,
  }
}

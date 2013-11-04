# A defined type to manage entries in hosts.{allow,deny}.
define tcpwrappers::entry(
  $type,
  $daemon,
  $client,
  $ensure=present,
  $except=undef,
  $order='10',
  $comment=undef,
) {
  # concat requires stdlib, so we'll use it too.
  include stdlib

  validate_re($ensure, '^$|^present$|^absent$')
  validate_re($type, '^$|^allow$|^deny$')
  validate_re($daemon, '^(?:\w[\w.-]*\w|\w)$')
  validate_string($client)
  if $order { validate_string($order) }

  $client_ = normalize_tcpwrappers_client($client)

  if $except {
    validate_string($except)
    $except_ = normalize_tcpwrappers_client($except)
    $key = "tcpwrappers/${type}/${daemon}:${client}:${except}"
    $content = "${daemon_}:${client_} EXCEPT ${except_}\n"
  } else {
    $except_ = undef
    $key = "tcpwrappers/${type}/${daemon}:${client}"
    $content = "${daemon_}:${client_}\n"
  }

  if $comment {
    validate_string($comment)
    tcpwrappers::comment { "${key}/${order}/${comment}":
      type    => $type,
      order   => $order,
      before  => Concat::Fragment[$key],
      require => Concat["/etc/hosts.${type}"],
    }
  }

  concat::fragment { $key :
    ensure  => $ensure,
    target  => "/etc/hosts.${type}",
    content => $content,
    order   => $order,
    require => Concat["/etc/hosts.${type}"],
  }
}

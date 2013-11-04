# A defined type to manage entries in hosts.{allow,deny}.
# Should only be called by either tcpwrappers::allow or tcpwrappers::deny.
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
    $key = "${type} ${daemon}:${client}:${except}"
    $content = "${daemon_}:${client_} EXCEPT ${except_}\n"
  } else {
    $except_ = undef
    $key = "${type} ${daemon}:${client}"
    $content = "${daemon_}:${client_}\n"
  }

  # Concat temp filename based on $key.
  # Most filesystems don't allow for >256 chars.
  validate_slength($key,255)

  if $comment {
    validate_string($comment)
    tcpwrappers::comment { "${key}/${order}/${comment}":
      type    => $type,
      order   => $order,
      before  => Concat::Fragment[$key],
    }
  }

  concat::fragment { $key :
    ensure  => $ensure,
    target  => "/etc/hosts.${type}",
    content => $content,
    order   => $order,
  }
}

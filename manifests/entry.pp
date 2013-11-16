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
  $allow=undef,
  $deny=undef,
  $comment=undef,
) {
  # concat requires stdlib, so we'll use it too.
  include stdlib

  validate_re($ensure, '^$|^present$|^absent$')
  validate_re($type, '^$|^allow$|^deny$')
  validate_re($daemon, '^(?:\w[\w.-]*\w|\w)$')
  validate_string($client)
  validate_string($order)

  $client_ = normalize_tcpwrappers_client($client)

  if $except {
    validate_string($except)
    $except_ = normalize_tcpwrappers_client($except)
    $key     = "${type} ${daemon}:${client_}:${except}"
    $content = "${daemon}:${client_} EXCEPT ${except_}\n"
  } else {
    $key     = "${type} ${daemon}:${client_}"
    $content = "${daemon}:${client_}\n"
  }

  if $allow and $type == 'deny' {
    validate_bool($allow)
    $content_ = "${content}:deny"
    $key_     = "${key}/deny"
  } elsif $deny and $type == 'allow' {
    validate_bool($deny)
    $content_ = "${content}:allow"
    $key_     = "${key}/allow"
  } else {
    $content_ = $content
    $key_     = $key
  }

  # Concat temp filename based on $key.
  # Most filesystems don't allow for >256 chars.
  validate_slength($key_,255)

  if $comment {
    validate_string($comment)
    tcpwrappers::comment { "${key}/${order}/${comment}":
      type    => $type,
      order   => $order,
      before  => Concat::Fragment[$key_],
    }
  }
  concat::fragment { $key_ :
    ensure  => $ensure,
    target  => "/etc/hosts.${type}",
    content => $content_,
    order   => $order,
  }
}

# A defined type to manage entries in hosts.{allow,deny}.
define tcpwrappers::entry(
  $type,
  $daemon,
  $client,
  $ensure=present,
  $except=undef,
  $order=10,
  $comment=undef,
) {

  include concat::setup

  case $type {
    allow,deny: {} # NOOP
    default: { fail("Invalid type: ${type}") }
  }

  # instantiate virtual resource.
  realize Concat["/etc/hosts.${type}"]

  if $daemon =~ /^(?:\w[\w.-]*\w|\w)$/ {
    $daemon_ = $daemon
  } else {
    fail("Invalid daemon: ${daemon}")
  }

  $client_ = normalize_tcpwrappers_client($client)

  if $except {
    $except_ = normalize_tcpwrappers_client($except)
    $key = "tcpwrappers/${type}/${daemon}:${client}:${except}"
    $content = "${daemon_}:${client_} EXCEPT ${except_}\n"
  } else {
    $except_ = undef
    $key = "tcpwrappers/${type}/${daemon}:${client}"
    $content = "${daemon_}:${client_}\n"
  }

  if $comment {
    tcpwrappers::comment { "${key}/${order}/${comment}":
      type => $type,
    }
  }

  case $ensure {
    present: {
      concat::fragment { $key :
        target  => "/etc/hosts.${type}",
        content => $content,
        order   => $order,
      }
    } default: {
      fail("Invalid ensure: ${ensure}")
    }
  }
}

# A defined type to manage entries in hosts.{allow,deny}.
define tcpwrappers::entry(
  $type,
  $daemon,
  $client,
  $ensure=present,
  $except=undef,
  $order=10,
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

  $comment = "# Puppet ordered entry ${order}."

  if $except {
    $except_ = normalize_tcpwrappers_client($except)
    $key = "tcpwrappers/${type}/${daemon}:${client}:${except}"
    $content = "${comment} ${key}\n${daemon_}:${client_} EXCEPT ${except_}\n"
  } else {
    $except_ = undef
    $key = "tcpwrappers/${type}/${daemon}:${client}"
    $content = "${comment} ${key}\n${daemon_}:${client_}\n"
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

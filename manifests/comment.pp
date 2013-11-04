# A defined type to manage comments in hosts.{allow,deny}.
define tcpwrappers::comment(
  $type,
  $order='10',
) {

  case $type {
    allow,deny: {} # NOOP
    default: { fail("Invalid type: ${type}") }
  }

  # instantiate virtual resource.
  realize Concat["/etc/hosts.${type}"]

  $comment = "# ${name}\n"

  concat::fragment { $name :
    target  => "/etc/hosts.${type}",
    content => $comment,
    order   => $order,
  }
}

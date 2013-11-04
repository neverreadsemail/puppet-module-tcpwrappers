# A defined type to manage comments in hosts.{allow,deny}.
define tcpwrappers::comment(
  $type,
  $ensure = 'present',
  $order  = '10',
) {
  include stdlib

  validate_re($ensure, '^$|^present$|^absent$')
  validate_re($type, '^$|^allow$|^deny$')

  $comment = "# ${name}\n"

  concat::fragment { $name :
    target  => "/etc/hosts.${type}",
    content => $comment,
    order   => $order,
    require =>  Concat["/etc/hosts.${type}"],
  }
}

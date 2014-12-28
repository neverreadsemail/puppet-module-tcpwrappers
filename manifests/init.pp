# Initialization class for tcpwrappers module.
#
# NOTE: Almost any modern version of tcpd can accept an ACL option at
# the end of the line, e.g. ': ALLOW' or ': DENY'. In addition to
# making debugging more obvious by containing all settings in a single
# file, BSD kernels notably list /etc/hosts.deny as deprecated. So, we
# want all entries in /etc/hosts.allow to be the default behavior. See
# `man 5 hosts_options` on your OS for details.
class tcpwrappers (
  $ensure            = 'present',
  $deny_by_default   = true,
  $enable_hosts_deny = false,
) {
  validate_bool($deny_by_default,$enable_hosts_deny)
  validate_re($ensure, '^(ab|pre)sent$')

  if $enable_hosts_deny {
    $concat_target = ['/etc/hosts.allow','/etc/hosts.deny']
  } else {
    $concat_target = '/etc/hosts.allow'
    file { '/etc/hosts.deny':
      ensure  => 'absent',
      require => Concat[$concat_target],
    }
  }

  $tcpd_name = $::osfamily ? {
    'Debian' => 'tcpd',
    'RedHat' => 'tcp_wrappers',
    default  => undef,
  }

  # Set up concat resource(s).
  concat { $concat_target :
    ensure => $ensure,
    group  => 'root',
    mode   => '0644',
    order  => 'numeric',
    owner  => 'root',
    warn   => true,
  }

  # Conditionally install
  if $tcpd_name { ensure_packages($tcpd_name, { before => Concat[$files] }) }

  if $deny_by_default == true {
    tcpwrappers::deny { 'deny_by_default':
      ensure  => $ensure,
      comment => 'deny everything by default',
      daemon  => 'ALL',
      client  => 'ALL',
      order   => '999',
    }
  }
}

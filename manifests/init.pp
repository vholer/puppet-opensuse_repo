define opensuse_repo (
  $enabled      = 1,
  $descr        = undef,
  $urlprefix    = 'http://download.opensuse.org/repositories',
  $baseurl      = undef,
  $platform     = undef,
  $gpgkey       = undef,
  $local_gpgkey = true,
  $gpgcheck     = 1,
  $autorefresh  = 1,
  $keeppackages = 0,
  $type         = 'rpm-md'
) {
  validate_bool($local_gpgkey)

  case $enabled {
    0,1:     { $_ensure = present }
    absent:  { $_ensure = absent }
    default: { fail('Enabled must be 0, 1 or "absent"') }
  }

  # make repository name friendly for filename
  $_name = regsubst(
    regsubst($title, '/', '_', 'G'),  # replace / -> _
    '[:`]', '', 'G')                  # remove some characters

  # detect platform and transform name and version
  # into http://download.opensuse.org compatible format
  # SLE_x_SPy or openSUSE_x.y
  if $platform {
    $_platform = $platform
  } else {
    if $::operatingsystem =~ /^SLE[SD]$/ {
      # transform 11.3 -> 11_SP3
      $version = regsubst($::operatingsystemrelease, '\.', '_SP')
      $_platform = "SLE_${version}"
    } elsif $::operatingsystem =~ /SuSE/ {
      $_platform = "openSUSE_${::operatingsystemrelease}"
    } else {
      fail("Unsupported OS: ${::operatingsystem}")
    }
  }

  if $baseurl {
    if $baseurl =~ /\/$/ {
      $_baseurl = $baseurl
    } else {
      $_baseurl = "${baseurl}/" # if missing, add / at the end
    }
  } else {
    $_baseurl = "${urlprefix}/${title}/${_platform}/"
  }

  if $gpgkey {
    $_gpgkey = $gpgkey
  } elsif $local_gpgkey == false {
    $_gpgkey = "${_baseurl}repodata/repomd.xml.key"
  } elsif $local_gpgkey == true {
    $_gpgkey_fn = "/etc/pki/rpm-gpg/RPM-GPG-KEY-${_name}-${_platform}"
    $_gpgkey = "file://${_gpgkey_fn}"

    # on RH systems directory used to store
    # GPG keys before importing
    if ! defined(File['/etc/pki/rpm-gpg']) {
      file { '/etc/pki/rpm-gpg':
        ensure => directory,
      }
    }

    opensuse_repo::gpgkey { $_gpgkey_fn:
      ensure  => $_ensure,
      source  => "puppet:///modules/opensuse_repo/${title}/${_platform}/repodata/repomd.xml.key",
      require => File['/etc/pki/rpm-gpg'],
      before  => Zypprepo[$_name],
    }
  }

  if $descr {
    $_descr = $descr
  } else {
    $_descr = "Repository ${title} for ${platform}"
  }

  #TODO: absent
  zypprepo { $_name:
    enabled      => $enabled,
    descr        => $descr,
    baseurl      => $_baseurl,
    gpgkey       => $_gpgkey,
    gpgcheck     => $gpgcheck,
    autorefresh  => $autorefresh,
    keeppackages => $keeppackages,
    type         => $type,
  }
}

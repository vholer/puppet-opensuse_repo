define obs_repo (
  $enabled      = 1,
  $descr        = undef,
  $urlprefix    = 'https://download.opensuse.org/repositories',
  $baseurl      = undef,
  $platform     = undef,
  $gpgkey       = undef,
  $gpgcheck     = 1,
  $autorefresh  = 1,
  $keeppackages = 0,
  $type         = 'rpm-md'
) {
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
  if ! empty($platform) {
    $_platform = $platform
  } else {
    if $::operatingsystem =~ /^SLE[SD]$/ {
      # transform 11.3 -> 11_SP3
      $version = regsubst($::operatingsystemrelease, '\.', '_SP')
      $_platform = "SLE_${version}"
    } elsif $::operatingsystem =~ /SuSE/ {
      if versioncmp($::operatingsystemmajrelease, '13') > 0 {
        $_platform = "openSUSE_Leap_${::operatingsystemrelease}"
      } else {
        $_platform = "openSUSE_${::operatingsystemrelease}"
      }
    } else {
      fail("Unsupported OS: ${::operatingsystem}")
    }
  }

  if ! empty($baseurl) {
    if $baseurl =~ /\/$/ {
      $_baseurl = $baseurl
    } else {
      $_baseurl = "${baseurl}/" # if missing, add / at the end
    }
  } else {
    $_baseurl = "${urlprefix}/${title}/${_platform}/"
  }

  if ! empty($gpgkey) {
    $_gpgkey = $gpgkey
  } else {
    $_gpgkey = "${_baseurl}repodata/repomd.xml.key"
  }

  if ! empty($descr) {
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

  # automatically import GPG key
  if ($enabled == 1) and ($gpgcheck == 1) {
    exec { "zypper-refresh-${_name}":
      command     => "zypper --gpg-auto-import-keys refresh ${_name}",
      path        => '/bin:/usr/bin:/sbin:/usr/sbin',
      refreshonly => true,
      subscribe   => Zypprepo[$_name],
    }
  }
}

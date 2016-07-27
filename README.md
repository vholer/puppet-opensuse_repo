# Puppet OpenSUSE Build Service repositories module

[![Puppet Forge](http://img.shields.io/puppetforge/v/vholer/obs_repo.svg)](https://forge.puppetlabs.com/vholer/obs_repo)

This module manages local configuration of repositories from the OpenSUSE
(http://download.opensuse.org/repositories). It contains mirror of public
signing GPG keys, which can be automatically imported before adding
new repository.

### Requirements

Module has been tested on:

* Puppet 3.3
* SLES 11 SP3

Required modules:

* stdlib (https://github.com/puppetlabs/puppetlabs-stdlib)
* zypprepo (https://github.com/deadpoint/puppet-zypprepo)

# Quick Start

Add repository and import mirrored GPG key. Example:

```puppet
obs_repo { 'systemsmanagement:/puppet':
  enabled => 0,
}
```

Full configuration options:

```puppet
obs_repo { name:
  enabled      => 0|1|absent,  # enable state
  descr        => '...',       # repository description
  urlprefix    => 'http://download.opensuse.org/repositories',
  baseurl      => '...',       # custom repository URL
  platform     => '...',       # custom repository platform
  gpgkey       => '...',       # custom GPG key URL
  local_gpgkey => true|false,  # use GPG key from module
  gpgcheck     => 0|1,         # check GPG signatures?
  autorefresh  => 0|1,         # autorefresh repo. metadata?
  keeppackages => 0|1,         # keep downloaded files?
  type         => '...',       # repository type (format)
}
```

Class wrapper for adding multiple repositories via Hiera:

```puppet
include obs_repo::multiple
```
With Hiera only resolved parameters:

- **repos** - array of repository names
- **options** - hash of opensuse\_repo options

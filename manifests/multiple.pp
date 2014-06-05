class opensuse_repo::multiple (
  $repos   = [],
  $options = {},
  $stage   = setup
) {
  ensure_resource('opensuse_repo',$repos,$options)
}

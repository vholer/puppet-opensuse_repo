class opensuse_repo::multiple (
  $repos   = [],
  $options = {}
) {
  ensure_resource('opensuse_repo',$repos,$options)
}

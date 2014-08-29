class opensuse_repo::multiple (
  $repos   = hiera_array('opensuse_repo::multiple::repos', []),
  $options = {},
  $stage   = setup
) {
  validate_array($repos)
  validate_hash($options)

  ensure_resource('opensuse_repo',$repos,$options)
}

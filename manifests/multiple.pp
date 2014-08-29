class opensuse_repo::multiple (
  $stage = setup
) {
  ensure_resource(
    'opensuse_repo',
    hiera_array('opensuse_repo::multiple::repos', []),
    hiera('opensuse_repo::multiple::options', {})
  )
}

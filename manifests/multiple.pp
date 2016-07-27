class obs_repo::multiple (
  $stage = setup
) {
  ensure_resource(
    'obs_repo',
    hiera_array('obs_repo::multiple::repos', []),
    hiera('obs_repo::multiple::options', {})
  )
}

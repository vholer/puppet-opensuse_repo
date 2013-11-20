class suserepo::multiple (
  $repos   = [],
  $options = {}
) {
  ensure_resource('suserepo',$repos,$options)
}

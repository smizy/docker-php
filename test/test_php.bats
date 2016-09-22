@test "php is the correct version" {
  run docker run smizy/php:${TAG} php -v
  [ $status -eq 0 ]
  [ "${lines[0]:0:5}" = "PHP 5" ]
}

@test "xdebug flag is correctly set" {
  run docker run -e XDEBUG_REMOTE=1 -e XDEBUG_PROFILER=1 smizy/php:${TAG} sh -c "php -i | grep xdebug.remote_enable"
  echo "${output}"  

  [ $status -eq 0 ]
  [ "${lines[0]}" = "xdebug.remote_enable => On => On" ]
}
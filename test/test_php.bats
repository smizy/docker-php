@test "php is the correct version" {
  run docker run smizy/php:${VERSION}-alpine php -v
  [ $status -eq 0 ]
  [ "${lines[0]:0:5}" = "PHP 5" ]
}

@test "xdebug is set to the correct flag" {
  run docker run -e XDEBUG_REMOTE=1 -e XDEBUG_PROFILER=1 smizy/php:${VERSION}-alpine php -i | grep xdebug.remote_enable
  echo "${output}"

  [ $status -eq 0 ]
  [ "${lines[0]}" = "xdebug.remote_enable => On => On" ]
}
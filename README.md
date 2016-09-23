# docker-php
[![](https://images.microbadger.com/badges/image/smizy/php:7-alpine.svg)](https://microbadger.com/images/smizy/php "Get your own image badge on microbadger.com") 
[![](https://images.microbadger.com/badges/version/smizy/php:7-alpine.svg)](https://microbadger.com/images/smizy/php "Get your own version badge on microbadger.com")
[![CircleCI](https://circleci.com/gh/smizy/docker-php/tree/php7.svg?style=svg&circle-token=c0772bbd1324e123a5bc5b10b00cf1191efd7846)](https://circleci.com/gh/smizy/docker-php/tree/php7)

PHP docker image based on alpine

# Usage 
```
# run php-fpm (xdebug disabled)
docker run -v $(pwd):/var/www/html -d  smizy/php:7-alpine 

# run built-in php server (xdebug remote debug enabled with xdebug.remote_connect_back=On 
docker run -it --rm -v $(pwd):/var/www/html -p 8090:9000 -e XDEBUG_REMOTE=1  smizy/php:7-alpine built-in 

# specify ip manually instead of connect_back=On (ex. Docker for mac)
docker run -it --rm -v $(pwd):/var/www/html -p 8090:9000 -e XDEBUG_REMOTE=<your local IDE ip>  smizy/php:7-alpine built-in 

# see xdebug log when remote debug not started
docker run -it --rm -v $(pwd):/var/www/html -p 8090:9000 -e XDEBUG_REMOTE=1 -e XDEBUG_LOG=1 smizy/php:7-alpine built-in 

# run built-in php server (xdebug profiler enabled)
docker run --name xdebug.profile -v $(pwd):/var/www/html -v /tmp -p 8090:9000 -e XDEBUG_PROFILER=1 -d smizy/php:7-alpine built-in 

## add XDEBUG_PROFILE param to target page and profile data saved on /tmp
open http://$(docker-machine ip default):8090/?XDEUBG_PROFILE

## run webgrind(profile analyzer) server
docker run -it --rm --volumes-from xdebug.profile  -p 8091:9000 -w /code smizy/php:7-alpine built-in 

## access webgrind
open http://$(docker-machine ip default):8091/webgrind/
```


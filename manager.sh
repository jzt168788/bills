#!/bin/bash

nginx_image_name='jinzhuotao/nginx'
mysql_image_name='jinzhuotao/mysql'
php_image_name='jinzhuotao/phpfpm'
#php_image_name='php:7.0-fpm'

nginx_name='dev_nginx'
mysql_name='dev_mysql'
php_name=dev_phpfpm

now_dir_path=$PWD

#执行
function run_cmd(){
    local t=`date`
    echo "\033[32m $t: $1\033[0m"
    eval $1
}

#测试
function test(){
    local cmd="echo 'This is a test function!'"
    run_cmd "$cmd"
}

function test1(){
    local cmd="ls -la"
    run_cmd "$cmd"
}

function stop_nginx(){
    stop_image "$nginx_name"
}

function stop_php(){
    stop_image "$php_name"
}

function stop_mysql(){
    stop_image "$mysql_name"
}

function start_nginx(){
    start_image "$nginx_name"
}

function start_php(){
    start_image "$php_name"
}

function start_mysql(){
    start_image "$mysql_name"
}

function del_nginx(){
    del_image "$nginx_name"
}

function del_php(){
    del_image "$php_name"
}

function del_mysql(){
    del_image "$mysql_name"
}

function run_mysql(){
    local cmd="$cmd -p 3307:3306 -e MYSQL_ROOT_PASSWORD=123qwe"
    cmd="$cmd -v $now_dir_path/docker/mysql/mysql-init:/docker-entrypoint-initdb.d"
    run_cmd "docker run -d $cmd --name $mysql_name $mysql_image_name"
}

function run_php(){
    local cmd=" --restart always"

    cmd="$cmd -v $now_dir_path/:/var/www/"
    cmd="$cmd -v $now_dir_path/docker/php-fpm/php-base.ini:/usr/local/etc/php/php.ini"
    cmd="$cmd -p 9001:9000 --link $mysql_name:mysql"

    run_cmd "docker run -d $cmd --name $php_name $php_image_name"

    _php_exec
}

function run_nginx(){
    local args=$1

    args="$args -p 8080:80"
    args="$args -v $now_dir_path/:/var/www/"
    args="$args -v $now_dir_path/docker/nginx-config/extra:/etc/nginx/conf.d/"
    args="$args --link $php_name:phpfpm"

    run_cmd "docker run -d $args --name $nginx_name $nginx_image_name"
}

function _php_exec(){
    run_cmd "docker exec $php_name docker-php-ext-install pdo_mysql"
#    run_cmd "docker exec $php_name apt-get install git -y"
#    run_cmd "docker exec $php_name curl -sS https://getcomposer.org/installer | php"
#    run_cmd "docker exec $php_name mv /var/www/composer.phar /usr/local/bin/composer"
#    run_cmd "docker exec $php_name composer install -d /var/www/cat-bills"
    run_cmd "docker exec $php_name php /var/www/cat-bills/artisan config:cache"
    run_cmd "docker exec $php_name cp /var/www/cat-bills/.env.example /var/www/cat-bills/.env"
    run_cmd "docker exec $php_name php /var/www/cat-bills/artisan key:generate"
    run_cmd "docker exec $php_name php /var/www/cat-bills/artisan migrate"
}

function start_image(){
    run_cmd "docker start $1"
}

function stop_image(){
    run_cmd "docker stop $1"
}

function del_image(){
    run_cmd "docker rm $1"
}

function start_all(){
    start_nginx
    start_php
    start_mysql
}

function stop_all(){
    stop_nginx
    stop_php
    stop_mysql
}

function del_all(){
    del_nginx
    del_php
    del_mysql
}

function clean_all(){
    stop_all
    del_all
}

function new_egg(){
    run_mysql
    run_php
    run_nginx
}

function help(){
    cat <<-EOF

        Run Step:
            1.sh manager.sh clean_all
            2.sh manager.sh new_egg

        Usage: manager.sh [option]
                test
                clean_all
                new_egg
EOF
}

action=$@
if [ -z "$action" ]; then
    action='help'
fi

$action
#!/bin/bash

dir=$(pwd)
dir_name="${dir%"${dir##*[!/]}"}"
dir_name=${dir_name##*/}
site_name=${dir_name}.local

config_file_name=${site_name}.conf
config_file="/etc/nginx/sites-available/${config_file_name}"

sites_enabled_dir=/etc/nginx/sites-enabled/
host_file=/etc/hosts

function remove_site_from_hosts {

    awk -v site_name=$1 -v site_name_w="www."$1 '
    {
        if ($1=="127.0.0.1" && $2==site_name) {}
        else if ($1=="127.0.0.1" && $2==site_name_w) {}
        else {
            print $0
        }
    }
    ' $host_file > "${host_file}.tmp"

    mv "${host_file}.tmp" ${host_file}
    rm "${host_file}.tmp"
}

echo "Site name :: ${site_name}"

echo "Delete nginx site config file >> ${config_file}"
rm -f ${config_file} 2> /etc/null
echo "nginx site configuration file deleted"
echo ""

echo "Delete the associated symlink >> ${sites_enabled_dir}"
rm -f ${sites_enabled_dir} 2> /etc/null
echo "symlink deleted"
echo ""

echo "Attempting to remove host entry >> ${host_file}"
remove_site_from_hosts $site_name
echo ""

echo "Testing nginx config files"
test_new_config
echo ""

echo "Reloading services . . . "
reload_services
echo ""
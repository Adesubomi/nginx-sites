#!/bin/bash

dir=$(pwd)
dir_name="${dir%"${dir##*[!/]}"}"
dir_name=${dir_name##*/}
site_name=${dir_name}.local

config_file_name=${site_name}.conf
config_file="/etc/nginx/sites-available/${config_file_name}"

sites_enabled_dir=/etc/nginx/sites-enabled/
host_file=/etc/hosts

function generate_file {
    
    sudo cat > ${config_file} << EOF
server {
    listen 80;
    listen [::]:80;
    server_name    ${site_name} www.${site_name};
    root           ${dir}/public;
    index          index.php index.html index.htm index.nginx-debian.html;

    location / {
      try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~* \.php\$ {
      fastcgi_pass unix:/run/php/php7.2-fpm.sock;
      include         fastcgi_params;
      fastcgi_param   SCRIPT_FILENAME    \$document_root\$fastcgi_script_name;
      fastcgi_param   SCRIPT_NAME        \$fastcgi_script_name;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

}

function generate_symlink {
    # this creates symlink of config file
    # in sites_available directory
    # into sites_enabled
 
    ln -s $config_file $sites_enabled_dir
}

function test_new_config {

    test_output=$(nginx -t)
    
    echo $test_output
}

function reload_services {

    outputs=$(systemctl reload nginx)
    echo $outputs
}

function add_site_to_hosts {
    
    new_host_entry="127.0.0.1\t%s${site_name} www.${site_name}"

    printf "\n%s" >> $host_file
    printf "$new_host_entry" >> $host_file

    printf "$new_host_entry\n%s"
}


echo "Site name :: ${site_name}"

echo "Generating nginx site config file >> ${config_file}"
generate_file
echo "nginx site config file generated"
echo ""

echo "Generating symlink >> ${sites_enabled_dir}"
generate_symlink
echo "symlink generated"
echo ""

echo "Creating host entry >> ${host_file}"
add_site_to_hosts
echo "Site has been added to host"
echo ""

echo "Testing nginx config files"
test_new_config
echo ""

echo "Reloading services . . . "
reload_services
echo ""




#!/bin/bash


IS_INSTALL_NGINX=yes
IS_INSTALL_VIRTUALENV=yes
IS_INSTALL_UWSGI=yes
get_path()
{
        i=1
        sdpath=""
        lastele=""
        OLDIFS=$IFS;IFS='\/'
        for elem in $0
        do  
                if [ $i -eq 1 ]; then
                        if [ -z $elem ]; then
                                lastele=""
                        else
                                lastele=$elem
                        fi  
                else
                        sdpath=$sdpath$lastele"="
                        lastele=$elem
                fi  
                i=$(($i + 1))
        done
        IFS=OLDIFS

        sdpath=`echo $sdpath | sed 's/=/\//g'`
        echo $sdpath
}

script_path=`cd "$(get_path "$0")";pwd`

echo -e "\e[35m parameters_numbers=$# $0 $1 $script_path \e[0m"


if [ "$IS_INSTALL_NGINX" = "yes" ];then
        echo -e "\e[30m installing  nginx \e[0m"
        sudo apt-get install nginx
	nginx -v
	systemctl enable nginx
fi

if [ "$IS_INSTALL_VIRTUALENV" = "yes" ];then
        echo -e "\e[30m installing  virtualenv \e[0m"
        pip install virtualenv
fi

stty erase '^H'

read -p "Please enter your projects name: " projects_name
envs_name=$projects_name
code_name=$projects_name

if [ -z $projects_name ]
then
        projects_dir=$projects_name"app"
        echo -e "\e[30m create default projects dir : $projects_name \e[0m"
        mkdir $projects_dir
else
        echo -e "\e[30m create projects dir  : $projects_name \e[0m"
        projects_dir=$projects_name"_app"
        mkdir $projects_dir
fi

cd $projects_dir


current_dir=`pwd`
echo -e "\e[30m create workspace $current_dir \e[0m"
#read -p "Please enter your envs dir  name: " envs_name

if [ -z $envs_name ]
then
        envs_name=envs
        echo -e "\e[30m create default envs dir : $envs_name \e[0m"
        mkdir $envs_name
else
        echo -e "\e[30m create envs dir  : $envs_name \e[0m"
        envs_name=$envs_name"_envs"
        mkdir $envs_name
fi
#read -p "Please enter save your code dir  name: " code_name

if [ -z $code_name ]
then
        code_name=code
        echo -e "\e[30m create default save code  dir : $code_name \e[0m"
        mkdir $code_name
else
        echo -e "\e[30m create save code  dir  : $code_name \e[0m"
        code_name=$code_name"_code"
        mkdir $code_name
fi

echo -e "\e[35m virtualenv $current_dir:$projects_name \e[0m"

envs_dir=$current_dir/$envs_name/$projects_name
virtualenv $envs_dir --python=python3
#echo -e "\e35m create virtualenv $current_dir:$projects_name success \e[0m"


source $envs_dir/bin/activate
echo -e "\e[35m source $envs_dir/bin/activate success \e[0m"
if [ "$IS_INSTALL_UWSGI" = "yes" ];then
        echo -e "\e[30m installing  uwsgi \e[0m"
        pip uninstall uwsgi
        sudo apt-get install libpcre3 libpcre3-dev
        pip install uwsgi --no-cache-dir
fi

pip install -r $script_path/requirements.txt

echo -e "\e[35m create $code_name/static $code_name/templates $code_name/templates/index.html $code_name/app.py \e[0m"
mkdir $code_name/static $code_name/templates
touch $code_name/templates/index.html $code_name/app.py

cat $script_path/index.html > $code_name/templates/index.html
cat $script_path/app.py > $code_name/app.py

deactivate
echo -e  "\e[35m configuration $projects_name"_uwsgi.ini" \e[0m"
echo "[uwsgi]
socket = 192.168.0.48:8008
chdir = $current_dir/$code_name/
wsgi-file = $current_dir/$code_name/app.py
callable = app
processes = 1
virtualenv = $current_dir/$envs_name/$projects_name" > $projects_dir"_uwsgi.ini"

cat $projects_dir"_uwsgi.ini"

echo -e  "\e[35m configuration build.sh \e[0m"
echo "
#!/bin/sh
echo -e "\"\\e[35m starting  nginx \\e[0m\""
nginx -v
source $envs_dir/bin/activate
systemctl stop nginx
systemctl start nginx
nginx -s reload
nginx -s reopen
echo -e "\"\\e[35m start nginx success \\e[0m"\"

uwsgi --ini $projects_dir"_uwsgi.ini"  --enable-threads --thunder-lock" > build.sh

cat build.sh
chmod 755 $projects_dir"_uwsgi.ini"  build.sh

#echo -e  "\e[35m configuration nginx.conf \e[0m"

sed -i -e "s/                root \/home\/workspace\/web\/app\/code\/;/                root \/home\/workspace\/web\/$projects_dir\/$code_name\/;/" $script_path/nginx.conf
sed -i -e "s/                        alias \/home\/workspace\/web\/app\/code\/static;/                        alias \/home\/workspace\/web\/$projects_dir\/$code_name\/static;/" $script_path/nginx.conf
 

echo -e "\e[35m hlep conmmand start---------------------------------- \e[0m"
echo -e "\e[35m source $envs_dir/bin/activate \e[0m"
echo -e "\e[35m deactivate \e[0m"
echo -e "\e[35m hlep conmmand end  ---------------------------------- \e[0m"




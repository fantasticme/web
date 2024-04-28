
#!/bin/sh
echo -e "\e[35m starting nginx \e[0m"
nginx -v
source /home/workspace/web/app/envs//bin/activate
systemctl stop nginx
systemctl start nginx
nginx -s reload
nginx -s reopen
echo -e "\e[35m start nginx success \e[0m"

uwsgi --ini app_uwsgi.ini  --enable-threads --thunder-lock

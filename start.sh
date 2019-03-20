#!/bin/bash
cd /usr/bin
fdfs_trackerd /etc/fdfs/tracker.conf restart
fdfs_storaged /etc/fdfs/storage.conf restart
#cd /usr/local/nginx
nginx  -g 'daemon off;'

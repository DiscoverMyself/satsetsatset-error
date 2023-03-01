# 1. Create Directory
```
mkdir -p /<disk_name>/www/html
mkdir -p /<disk_name>/www/snapshot/<file_name>
```

# 2. Create Symlink
```
ln -sf /<disk_name>/www/html /var/www/html
ln -sf /<disk_name>/www/snapshot/<file_name> /var/www/snapshot/<file_name>
```

## OR

# 2. Allow Access
```
chmod a+rx /<disk_name>/www/html
chmod a+rx /<disk_name>/www/snapshot/<file_name>
```

# 3. Compress Snap file
```
cd $HOME/<config_folder>
sudo systemctl stop <binary>
tar -cf - data | lz4 > /<disk_name>/www/snapshot/<file_name>/<file_name>-snapshot-$(date +%Y%m%d).tar.lz4
sudo systemctl start <binary>
```

# 4. Allow File Access
```
chmod a+rx /<disk_name>/www/snapshot/<folder_name>/<file_name>-snapshot-$(date +%Y%m%d).tar.lz4
```

# 5. Set Nginx Config file
```
sudo tee /etc/nginx/sites-available/<your_web_domain>.conf <<EOF
server {
        root /<disk_name>/www/html;
        index index.html index.htm index.nginx-debian.html;
        server_name <your_web_domain>;

        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                root /<disk_name>/www/snapshot/;
                autoindex on;
                autoindex_exact_size off;
                autoindex_format html;
                autoindex_localtime on;
        }


    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/explorer.apramweb.tech/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/explorer.apramweb.tech/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot


}
server {
    if ($host = <your_web_domain>) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


        server_name <your_web_domain>;
    listen 80;
    return 404; # managed by Certbot


}
EOF
```

**if you found some error, try to re-write `$host` and `request_uri` inside the file manually.

# 6. Test your .conf file
```
nginx -t
```

# 7. Create symlink for file
```
ln -sf /etc/nginx/sites-available/<your_web_domain>.conf /etc/nginx/sites-enabled
```

# 8. Enable SSL
```
sudo certbot --nginx --register-unsafely-without-email
sudo certbot --nginx --redirect -d <your_web_domain>
```

# 9. Create script for daily snapshot
```
sudo tee $HOME/snapshot.sh <<EOF
sudo systemctl stop <binary>
cd $HOME/<config_folder>/
rm /<disk_name>/www/snapshot/<folder_name>/*
tar -cf - data | lz4 > /datastore/www/snapshot/<folder_name>/<file_name>-snapshot-$(date +%Y%m%d).tar.lz4
sudo systemctl start <binary>
EOF
```

# 10. Allow Script access
```
chmod +x snapshot.sh
```

# 11. Set crontab job (for daily snapshot)
```
crontab -e
```

put in the bottom of the file:
(minutes 0-59) (hour 0-23) (day 1-7) (month 1-30) (command =folder/file.sh)
ex : 0 1 * * * /root/test.sh = in 01.00 am script in test.sh will executed


# INSTALLATION
```
sudo systemctl stop <binary>
cp $HOME/<config_folder>/data/priv_validator_state.json $HOME/<config_folder>/priv_validator_state.json.backup
rm -rf $HOME/<config_folder>/data

curl -L https://<your_web_domain>/<folder_name>/<file_name_on_your_website> | tar -Ilz4 -xf - -C $HOME/<config_folder>
mv $HOME/<config_folder>/priv_validator_state.json.backup $HOME/<config_folder>/data/priv_validator_state.json

sudo systemctl start <binary> && sudo journalctl -fu <binary> -o cat
```

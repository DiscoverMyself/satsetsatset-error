# Create API, RPC, gRPC

## Prerequisites
- Domain


## Create Subdomain

<img src="https://user-images.githubusercontent.com/78480857/215321972-36d560bf-1ede-43e5-a3c0-a17830f98277.png">

**Server Domain**
1. Click DNS
2. Choose **A** on type
3. Fill with `planq`
4. Fill your VPS IP
5. (Let it being default)
6. Add

**API Domain**
1. Click DNS
2. Choose **CNAME** on type
3. Fill with `api.planq`
4. Fill with planq.<your_domain> (eg: `planq.apramweb.tech`)
5. (Let it being default)
6. Add

**RPC Domain**
1. Click DNS
2. Choose **CNAME** on type
3. Fill with `rpc.planq`
4. Fill with planq.<your_domain> (eg: `planq.apramweb.tech`)
5. (Let it being default)
6. Add

**gRPC Domain**
1. Click DNS
2. Choose **CNAME** on type
3. Fill with `grpc.planq`
4. Fill with planq.<your_domain> (eg: `planq.apramweb.tech`)
5. (Let it being default)
6. Add


## Install Dependencies
```
sudo apt update && sudo apt upgrade -y
```
```
sudo apt install nginx certbot python3-certbot-nginx -y
```
```
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
```
```
sudo apt-get update && apt install -y nodejs git
```
```
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
```
```
sudo apt-get update && sudo apt-get install yarn -y
```



## Enabled & Find the API Address

<img src="https://user-images.githubusercontent.com/78480857/215321918-c15a39d7-4b77-4ede-9675-2762cc1e38fe.png">

```
nano $HOME/.planqd/config/app.toml
```
1. Change the value from `false` to `true`
2. Save your local API Address (eg: `0.0.0.0:60137`)

**Restart the Node**
```
sudo systemctl restart planqd
```


## Find your local Port RPC

<img src ="https://user-images.githubusercontent.com/78480857/215321924-0846f66b-9f63-4f9d-b7bf-5bcc588e6f8b.png">

```
nano $HOME/.planqd/config/config.toml
```
Save this value (ip:port)


## Find your local Port gRPC

<img src="https://user-images.githubusercontent.com/78480857/215321924-0846f66b-9f63-4f9d-b7bf-5bcc588e6f8b.png">

```
nano $HOME/.planqd/config/app.toml
```
Save this value (ip:port)



## Create Variable

(change this value on your notepad first)
```
API_DOMAIN=<your_API_domain>
RPC_DOMAIN=<your_RPC_domain>
GRPC_DOMAIN=<your_gRPC_domain>
API_ADDRESS=<your_local_API_address>
RPC_ADDRESS=<your_local_RPC_address>
GRPC_ADDRESS=<your_local_gRPC_address>
```

## Create API Services

```
sudo tee /etc/nginx/sites-enabled/${API_DOMAIN}.conf > /dev/null <<EOF
server {
    server_name $API_DOMAIN;
    listen 80;
    location / {
        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Max-Age 3600;
        add_header Access-Control-Expose-Headers Content-Length;

	proxy_set_header   X-Real-IP        \$remote_addr;
        proxy_set_header   X-Forwarded-For  \$proxy_add_x_forwarded_for;
        proxy_set_header   Host             \$host;

        proxy_pass http://$API_ADDRESS;

    }
}
EOF
```

## Create RPC Services

```
sudo tee /etc/nginx/sites-enabled/${RPC_DOMAIN}.conf > /dev/null <<EOF
server {
    server_name $RPC_DOMAIN;
    listen 80;
    location / {
        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Max-Age 3600;
        add_header Access-Control-Expose-Headers Content-Length;

	proxy_set_header   X-Real-IP        \$remote_addr;
        proxy_set_header   X-Forwarded-For  \$proxy_add_x_forwarded_for;
        proxy_set_header   Host             \$host;

        proxy_pass http://$RPC_ADDRESS;

    }
}
EOF
```

## Create gRPC Services
```
sudo tee /etc/nginx/sites-enabled/${GRPC_DOMAIN}.conf > /dev/null <<EOF
server {
    server_name $GRPC_DOMAIN;
    listen 80;
    location / {
        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Max-Age 3600;
        add_header Access-Control-Expose-Headers Content-Length;

	proxy_set_header   X-Real-IP        \$remote_addr;
        proxy_set_header   X-Forwarded-For  \$proxy_add_x_forwarded_for;
        proxy_set_header   Host             \$host;

        proxy_pass http://$GRPC_ADDRESS;

    }
}
EOF
```
## Setup SSL Certificate for all of services above

```
sudo certbot --nginx --register-unsafely-without-email
sudo certbot --nginx --redirect
```

- you can choose 1 for direct or 2 redirect (secure sites/https)
- Then select all (let it blank, click `Enter`)

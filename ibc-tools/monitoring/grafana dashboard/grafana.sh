

#
# Thanks to: Salman Wahib (sxlmnwb)
#

# User Input

read -p "Enter your job : " JOB
read -p "Enter 

# Download Component Grafana And Self Delete
cd $HOME
wget https://raw.githubusercontent.com/sxlzptprjkt/resource/master/grafana/resources.sh
chmod +x resources.sh
./resources.sh uninstall grafana
./resources.sh uninstall prometheus

# Deploy Grafana And Prometheus
./resources.sh deploy grafana
./resources.sh deploy prometheus
rm -f resources.sh

# Install Packages
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update
sudo apt install make build-essential gcc git jq chrony lz4 nginx unzip nodejs yarn -y

# Download Grafana Render And Move
wget https://github.com/grafana/grafana-image-renderer/archive/refs/heads/master.zip
unzip master.zip -d /opt/
rm -f master.zip
sudo mkdir -p /opt/grafana-plugin
sudo mv /opt/grafana-image-renderer-master /opt/grafana-plugin/

# Build Grafana Render
cd /opt/grafana-plugin/grafana-image-renderer-master
yarn install --pure-lockfile
yarn run build

# Create Service
sudo tee /etc/systemd/system/grafana-render.service > /dev/null <<EOF
[Unit]
Description=Grafana instance
Documentation=http://docs.grafana.org
Wants=network-online.target
After=network-online.target
After=postgresql.service mariadb.service mysql.service

[Service]
User=grafana
Group=grafana
Type=simple
ExecStart=/usr/bin/node /opt/grafana-plugin/grafana-image-renderer-master/build/app.js server --port=8081

[Install]
WantedBy=multi-user.target
EOF

# Register Start Service And Install Plugin
sudo systemctl daemon-reload
sudo systemctl start grafana-render
grafana-cli plugins install grafana-image-renderer

# Setting Port || Config Grafana (Public Dashboard)
# sed -i.bak \
#   -e "s|^;http_port *=.*|;http_port = 3000|" \
#   -e "s|^;server_url *=.*|;server_url = http://127.0.0.1:8081/render|" \
#   -e "s|^;callback_url *=.*|;callback_url = http://127.0.0.1:3000|" \
#   /etc/grafana/grafana.ini

curl -Ls <link> > /etc/grafana/grafana.ini

# Restart Grafana
sudo systemctl restart grafana-server

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "USERNAME : \e[1m\e[31madmin\e[0m"
echo -e "PASSWORD : \e[1m\e[31madmin\e[0m"
echo -e "LOGIN YOUR GRAFANA : \e[1m\e[31mhttp://$(curl -s ifconfig.me):3000/login\e[0m"
echo ""
echo -e "CHECK LOGS GRAFANA    : \e[1m\e[31msystemctl status grafana-server\e[0m"
echo -e "CHECK LOGS PROMETHEUS : \e[1m\e[31msystemctl status prometheus\e[0m"
echo ""

cd #HOME
rm -f grafana.sh
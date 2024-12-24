#!/bin/bash

# Menampilkan ASCII Art untuk "Saandy"
echo "
███████╗███████╗██████╗  ██████╗     ██████╗ ██████╗  ██████╗ ██████╗ 
╚══███╔╝██╔════╝██╔══██╗██╔═══██╗    ██╔══██╗██╔══██╗██╔═══██╗██╔══██╗
  ███╔╝ █████╗  ██████╔╝██║   ██║    ██║  ██║██████╔╝██║   ██║██████╔╝
 ███╔╝  ██╔══╝  ██╔══██╗██║   ██║    ██║  ██║██╔══██╗██║   ██║██╔═══╝ 
███████╗███████╗██║  ██║╚██████╔╝    ██████╔╝██║  ██║╚██████╔╝██║     
╚══════╝╚══════╝╚═╝  ╚═╝ ╚═════╝     ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝                                                                       
"

# Menghapus direktori 'executor' jika ada
rm -rf executor

# Download dan ekstrak file
curl -L -o executor-linux-v0.31.0.tar.gz https://github.com/t3rn/executor-release/releases/download/v0.31.0/executor-linux-v0.31.0.tar.gz && \
tar -xzvf executor-linux-v0.31.0.tar.gz && \
rm -rf executor-linux-v0.31.0.tar.gz && \
cd executor/executor/bin

# Menanyakan PRIVATE_KEY_LOCAL kepada pengguna
read -p "Masukkan PRIVATE_KEY_LOCAL Anda: " PRIVATE_KEY_LOCAL

# Menanyakan RPC endpoints
read -p "Masukkan RPC_ENDPOINTS_ARBT: " RPC_ENDPOINTS_ARBT
read -p "Masukkan RPC_ENDPOINTS_BSSP: " RPC_ENDPOINTS_BSSP
read -p "Masukkan RPC_ENDPOINTS_BLSS: " RPC_ENDPOINTS_BLSS
read -p "Masukkan RPC_ENDPOINTS_OPSP: " RPC_ENDPOINTS_OPSP

# Menanyakan nilai EXECUTOR_MAX_L3_GAS_PRICE (default 10)
read -p "Masukkan nilai EXECUTOR_MAX_L3_GAS_PRICE (default 10): " EXECUTOR_MAX_L3_GAS_PRICE
# Jika tidak ada input, set ke 10
EXECUTOR_MAX_L3_GAS_PRICE=${EXECUTOR_MAX_L3_GAS_PRICE:-10}

# Membuat file service systemd dengan variabel yang diisi
sudo tee /etc/systemd/system/t3rn-executor.service > /dev/null <<EOF
[Unit]
Description=t3rn Executor Service
After=network.target

[Service]
ExecStart=/root/executor/executor/bin/executor
Environment="NODE_ENV=testnet"
Environment="LOG_LEVEL=debug"
Environment="LOG_PRETTY=false"
Environment="EXECUTOR_PROCESS_ORDERS=true"
Environment="EXECUTOR_PROCESS_CLAIMS=true"
Environment="PRIVATE_KEY_LOCAL=$PRIVATE_KEY_LOCAL"
Environment="ENABLED_NETWORKS=arbitrum-sepolia,base-sepolia,blast-sepolia,optimism-sepolia,l1rn"
Environment="RPC_ENDPOINTS_ARBT=$RPC_ENDPOINTS_ARBT"
Environment="RPC_ENDPOINTS_BSSP=$RPC_ENDPOINTS_BSSP"
Environment="RPC_ENDPOINTS_BLSS=$RPC_ENDPOINTS_BLSS"
Environment="RPC_ENDPOINTS_OPSP=$RPC_ENDPOINTS_OPSP"
Environment="EXECUTOR_MAX_L3_GAS_PRICE=$EXECUTOR_MAX_L3_GAS_PRICE"
Restart=always
RestartSec=5
User=$USER

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable dan start service
sudo systemctl daemon-reload
sudo systemctl enable t3rn-executor.service
sudo systemctl start t3rn-executor.service

# Menampilkan log service secara real-time
sudo journalctl -u t3rn-executor.service -f --no-hostname -o cat

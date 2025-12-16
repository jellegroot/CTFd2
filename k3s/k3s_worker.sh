SERVER_TOKEN="K10317bf673e87647f8eb24c3d12c94ac441f61a795841ba7794eadced0658e3259::server:1f778f7d4c0f3384e4217e761f58d6bf"
SERVER_IP="192.168.2.24"
TCP_PORT=6443
NODE_IP="192.168.2.23"

curl -4 -sfL https://get.k3s.io | \
  K3S_URL=https://${SERVER_IP}:${TCP_PORT} \
  K3S_TOKEN=${SERVER_TOKEN} \
  sh -s - agent \
  --node-ip=${NODE_IP}

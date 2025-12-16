#!/usr/bin/env bash
set -e
echo "==> Install htpasswd (apache2-utils)"
sudo apt-get update
sudo apt-get install -y apache2-utils
# Config
SERVER_IP="192.168.2.24"
REGISTRY_USER=ctfd
REGISTRY_PASS=cybermeister123
HTPASSWD="$(htpasswd -nbB "$REGISTRY_USER" "$REGISTRY_PASS" | tr -d '\n')"


# Disable ipv6 (pull errors)
echo "==> Disable ipv6 for pulling images"

sudo tee /etc/sysctl.d/99-disable-ipv6.conf <<EOF
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF

echo "==> Install k3s server"

curl -sfL https://get.k3s.io | sh -s - \
  --tls-san ${SERVER_IP}

echo "==> Install add-ons"
# cert manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
# Istioctl
curl -L https://istio.io/downloadIstio | sh -
cd istio-*
sudo mv bin/istioctl /usr/local/bin/

istioctl install --set profile=default -y

echo "==> Configure kubeconfig"
# Move config file to local user
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
chmod 600 ~/.kube/config

# Change gateway IP to server (or loadbalancer when used)
sed -i "s|https://127.0.0.1:6443|https://${SERVER_IP}:6443|g" ~/.kube/config


sudo systemctl restart k3s

sleep 5

echo "==> Create challenge namespace"
kubectl get ns ctfd-registry >/dev/null 2>&1 || kubectl create namespace ctfd-registry



echo "==> Ensure local-path storage provisioner"

kubectl get storageclass local-path >/dev/null 2>&1 || \
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml

echo "==> Ensure local-path is default StorageClass"

kubectl patch storageclass local-path \
  -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}' \
  --type=merge || true


echo "==> Create registry PVC"

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: registry-pvc
  namespace: ctfd-registry
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: local-path
EOF

echo "==> Create registry htpasswd ConfigMap"

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: registry-htpasswd-map
  namespace: ctfd-registry
data:
  htpasswd: |
    $HTPASSWD
EOF

echo "==> Create registry docker auth secret"

kubectl delete secret registry-auth-map -n ctfd-registry --ignore-not-found

kubectl create secret docker-registry registry-auth-map \
  --docker-server=challenge-registry-service.ctfd-registry:5000 \
  --docker-username="$REGISTRY_USER" \
  --docker-password="$REGISTRY_PASS" \
  --docker-email=ctfd@local \
  -n ctfd-registry

kubectl rollout restart deployment registry -n ctfd-registry


# kubectl taint node manager node-role.kubernetes.io/manager=true:NoSchedule


echo "==> Done"

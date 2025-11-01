#!/bin/bash
# ============================================================
# 🚀 FULL KUBERNETES INSTALLATION SCRIPT
# Ubuntu 22.04+ | Containerd | Helm | Cilium CNI | ArgoCD
# ============================================================

set -e

# ====================== [I] FIREWALL CONFIG ======================
echo "🔧 Cấu hình firewall cho Kubernetes..."

ufw --force enable
ufw allow 22/tcp comment 'SSH remote access'
ufw allow 80/tcp comment 'HTTP service'
ufw allow 443/tcp comment 'HTTPS service'
ufw allow 30000:32767/tcp comment 'Kubernetes NodePort Services'
ufw allow out 5473/tcp comment 'Calico Typha (worker to Typha)'
ufw allow 179/tcp comment 'Calico BGP peering'
ufw allow 4789/udp comment 'Calico VXLAN tunnel'
ufw allow 51820/udp comment 'Calico WireGuard encryption'
ufw allow 51821/udp comment 'Calico WireGuard backup'
ufw allow 8472/udp comment 'VXLAN overlay (UDP)'
ufw allow 4240/tcp comment 'Cilium Agent communication'
ufw allow 4244/tcp comment 'Hubble observability'
ufw allow 4245,4250/tcp comment 'Cilium additional communication (TCP)'
ufw allow 9962:9964/tcp comment 'Cilium internal service ports (TCP)'
ufw allow 51871/tcp comment 'Cilium dynamic port (TCP)'
ufw allow 2377/tcp comment 'Swarm cluster management (manager only)'
ufw allow 7946/tcp comment 'Swarm node discovery TCP'
ufw allow 7946/udp comment 'Swarm node discovery UDP'
ufw allow 4789/udp comment 'Swarm overlay network (VXLAN)'
ufw allow 9100/tcp comment 'Node Exporter'
ufw allow 8080/tcp comment 'cAdvisor metrics'

# ====================== [II] SYSTEM TUNING ======================
echo "⚙️ Cấu hình sysctl và giới hạn hệ thống..."

cat <<EOF >/etc/sysctl.conf
fs.file-max = 1048576
fs.nr_open = 1048576
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 1024

vm.max_map_count=262144

net.ipv4.tcp_retries2 = 5
net.ipv4.tcp_fastopen = 3

net.ipv4.neigh.default.gc_stale_time = 600
net.ipv4.neigh.default.gc_interval = 30
net.ipv4.neigh.default.gc_thresh1 = 1024
net.ipv4.neigh.default.gc_thresh2 = 2048
net.ipv4.neigh.default.gc_thresh3 = 4096

net.ipv4.ip_local_port_range = 10000 65535
net.core.somaxconn = 1000000
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 12582912 16777216
net.ipv4.tcp_wmem = 4096 12582912 16777216
net.ipv4.tcp_mem = 786432 1697152 1945728
net.core.netdev_max_backlog = 4096

net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_max_tw_buckets = 400000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2
net.ipv4.ip_forward = 1
net.ipv4.ip_nonlocal_bind = 1

net.netfilter.nf_conntrack_max = 1048576
net.netfilter.nf_conntrack_buckets = 262144
net.netfilter.nf_conntrack_tcp_timeout_established = 1800
net.netfilter.nf_conntrack_tcp_timeout_close_wait = 60

net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF

sysctl -p

# ====================== [III] INSTALL CONTAINERD ======================
echo "📦 Cài đặt Containerd..."

apt update && apt upgrade -y
apt install -y containerd

mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml >/dev/null
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

# Enable kernel modules
cat <<EOF >/etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# Disable swap
swapoff -a
sed -i '/swap/s/^/#/' /etc/fstab

# Sysctl config for containerd
cat <<EOF >/etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

sysctl --system

systemctl enable containerd
systemctl restart containerd

# ====================== [IV] INSTALL KUBERNETES ======================
echo "☸️ Cài đặt Kubernetes (kubeadm, kubelet, kubectl)..."

apt-get install -y apt-transport-https ca-certificates curl gnupg
mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key \
  | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' \
  | tee /etc/apt/sources.list.d/kubernetes.list

apt update
apt install -y kubelet=1.31.12-1.1 kubeadm=1.31.12-1.1 kubectl=1.31.12-1.1
apt-mark hold kubelet kubeadm kubectl

mkdir -p /etc/systemd/system/kubelet.service.d
cat <<EOF >/etc/systemd/system/kubelet.service.d/containerd.conf
[Service]
Environment="KUBELET_EXTRA_ARGS=--runtime-request-timeout=15m --image-service-endpoint=unix:///run/containerd/containerd.sock --cgroup-driver=systemd"
EOF

echo "runtime-endpoint: unix:///run/containerd/containerd.sock" > /etc/crictl.yaml

cat <<EOF >/var/lib/kubelet/kubeadm-flags.env
KUBELET_KUBEADM_ARGS="--container-runtime=remote --container-runtime-endpoint=/run/containerd/containerd.sock --pod-infra-container-image=k8s.gcr.io/pause:3.4.1"
EOF

systemctl daemon-reload
systemctl enable kubelet
systemctl restart kubelet

# ====================== [V] INSTALL HELM ======================
echo "🎯 Cài đặt Helm..."

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod +x get_helm.sh
./get_helm.sh
rm get_helm.sh

# ====================== [VI] INIT K8S CLUSTER ======================
echo "🚀 Khởi tạo cụm Kubernetes Master Node..."

cat <<EOF > ~/init-config.yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
kubernetesVersion: "1.31.12"
controlPlaneEndpoint: "$(hostname -I | awk '{print $1}'):6443"
networking:
  podSubnet: "10.244.0.0/16"
EOF

kubeadm init --config ~/init-config.yaml

# Setup kubeconfig for current user
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# ====================== [VII] INSTALL CILIUM CNI ======================
echo "🌐 Cài đặt Cilium CNI qua Helm..."

helm repo add cilium https://helm.cilium.io/
helm repo update
kubectl create namespace cilium || true

MASTER_IP=$(hostname -I | awk '{print $1}')
helm install cilium cilium/cilium --namespace cilium \
  --version 1.15.5 \
  --set k8sServiceHost=$MASTER_IP \
  --set k8sServicePort=6443 \
  --set hubble.enabled=true \
  --set routingMode=tunnel

# ====================== [VIII] INSTALL ARGOCD ======================
echo "🎨 Cài đặt ArgoCD..."

kubectl create namespace argocd || true
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd -n argocd

echo "✅ Hoàn tất cài đặt ArgoCD!"
echo "Truy cập bằng NodePort qua:"
kubectl get svc -n argocd

echo "⚙️ Toàn bộ cụm K8s đã được cài đặt thành công!"
echo "➡️ Kiểm tra bằng: kubectl get nodes && kubectl get pods -A"

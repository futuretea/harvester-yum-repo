# harvester-yum-repo

## Setup Repo Server
```bash
docker run -d -p 2009:2009 --name=harvester-yum-repo futuretea/harvester-yum-repo:v0.0.3
```

## Add Yum Repo
```bash
# replace 192.168.5.79 with your repo server ip
repo_server="192.168.5.79"
cat <<EOF | sudo tee /etc/yum.repos.d/harvester.repo
[harvester]
name=harvester
baseurl=http://${repo_server}:2009/rpms
enabled=1
gpgcheck=0
exclude=kubelet kubeadm kubectl
EOF
```

## Config Alias
```
alias hi='yum -y install --disableexcludes=harvester --disablerepo="*" --enablerepo="harvester"'
```
## Upgrade Kernel
```bash
hi kernel-lt
grub2-set-default 0
reboot
```

## Longhorn packages
```bash
hi iscsi-initiator-utils nfs-utils
```

## Docker packages
```bash
hi docker-ce docker-ce-cli containerd.io

sudo mkdir /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
sudo systemctl enable --now docker
systemctl status docker
```

## K8s config
```bash
# Disable swap
swapoff -a
sed -i '/swap/d' /etc/fstab

# configure kernel
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

# Disable firewalld
systemctl stop firewalld.service
systemctl disable firewalld.service

# Set SELinux in permissive mode (effectively disabling it)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
```

## K8s packages
```bash
hi kubelet kubeadm kubectl

# Set SELinux in permissive mode (effectively disabling it)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
sudo systemctl enable --now kubelet
systemctl status kubelet
```

## K3s packages
```bash
hi container-selinux selinux-policy-base k3s-selinux
sudo curl -OL http://${repo_server}:2009/bins/k3s && chmod +x k3s && mv k3s /usr/local/bin/
curl -sfL http://${repo_server}:2009/bins/k3s-install.sh | INSTALL_K3S_SKIP_DOWNLOAD=true INSTALL_K3S_SKIP_SELINUX_RPM=true sh -
```

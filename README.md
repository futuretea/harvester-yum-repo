# harvester-yum-repo

## Setup repo server
```bash
docker run -d -p 2009:2009 --name=harvester-yum-repo futuretea/harvester-yum-repo:v0.0.1
```

## Add yum repo
```bash
# replace 192.168.1.79 with your repo server ip
repo_server="192.168.1.79"
cat <<EOF | sudo tee /etc/yum.repos.d/harvester.repo
[harvester]
name=harvester
baseurl=http://${repo_server}:2009/rpms
enabled=1
gpgcheck=0
exclude=kubelet kubeadm kubectl
EOF
```

## Install packages
```bash
yum -y install --disableexcludes=harvester --disablerepo="*" --enablerepo="harvester" \
    kernel-lt \
    docker-ce docker-ce-cli containerd.io \
    kubelet kubeadm kubectl \
    iscsi-initiator-utils nfs-utils \
    libvirt-client
grub2-set-default 0
reboot
```

## Start Docker
```bash
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

## Start Kubelet
```bash
# Set SELinux in permissive mode (effectively disabling it)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
sudo systemctl enable --now kubelet
systemctl status kubelet
```

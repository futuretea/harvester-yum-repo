# harvester-yum-repo

## Setup repo server
```bash
docker run -d -p 2009:2009 --name=harvester-yum-repo futuretea/harvester-yum-repo:v0.0.1
```

## Add yum repo
```bash
cat <<EOF | sudo tee /etc/yum.repos.d/harvester.repo
[harvester]
name=harvester
baseurl=http://repo-server-ip:2009/rpms
enabled=1
gpgcheck=0
exclude=kubelet kubeadm kubectl
EOF
```

## Install packages
```bash
sudo yum --disablerepo="*" --enablerepo="harvester" list available
sudo yum -y install --disableexcludes=harvester --enablerepo=harvester kernel-lt docker-ce docker-ce-cli containerd.io kubelet kubeadm kubectl iscsi-initiator-utils nfs-utils libvirt-client
```


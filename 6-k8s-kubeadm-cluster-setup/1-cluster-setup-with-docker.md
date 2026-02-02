# SETTING-UP A KUBERNETES CLUSTER WITH EITHER 'DOCKER-ENGINE':


STAGE 1: INITIAL SETUP 

# 1: Disable swap (on all nodes)

# to view current content:
cat /etc/fstab
# to disable temporarily (for current session): 
swapoff -a 
# to disable permenantly: 
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab 
# (or) Open the 'fstab' file of '/etc' directory, find the line containing 'swap', and comment the line & save file.
# eg:
# #UUID=7243b160-7e93-4364-95ca-c6f6cf2ec176 none                    swap    defaults
# to verify file content (after above edit)
cat /etc/fstab


# 2: Disable SELinux permanently (on all nodes)
# optional. Because, cluster setup was successful even without disabling 'selinux'. so, this step is just for reference.

# to view current content:
cat /etc/selinux/config
# to disable temporary: (for current session)
setenforce 0   
# to disable permanently:
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
# verify file content (after above edit)
cat /etc/selinux/config
# check the status:
sestatus

# Notes:
# total 3 modes. enforcing, permissive, disabled. permissive mode: selinux policies are not enforced. but logged.


# 3: verify VM's uniqueness (IP & UUID): (on all nodes)
# Note: virtualbox handles this by default. so, this step is just for reference.

# IP: Get the MAC address of the network interfaces using the command 'ifconfig' or 'ip a':
ip a
# UUID: The product_uuid can be checked by using the command: (on RHEL distros)
cat /sys/class/dmi/id/product_uuid


# 4: Firewall (on all nodes)

# for reference:
sudo systemctl status firewalld     
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo systemctl start firewalld
sudo systemctl enable --now firewalld
sudo firewall-cmd --permanent --add-port=<<port/port-range>>/protocol
sudo firewall-cmd --permanent --remove-port=<<port/port-range>>/protocol

# on master node:
# allow the ports: 6443/tcp (API server), 2379-2380/tcp (etcd), 10250/tcp (kubelet), 8472/udp (NCI)
firewall-cmd --permanent --add-port=2379-2380/tcp      # etcd
firewall-cmd --permanent --add-port=6443/tcp           # API server
firewall-cmd --permanent --add-port=10250/tcp          # kubelet API
# sudo firewall-cmd --permanent --add-port=10257/tcp          # kube-controller-manager (optional)
# sudo firewall-cmd --permanent --add-port=10259/tcp          # kube-scheduler  (optional)
firewall-cmd --permanent --add-port=8472/udp           # Required CNI UDP Port (for Flannel), ## to allow worker to worker traffic
# sudo firewall-cmd --permanent --add-port=30000-32767/tcp   # for 'NodePort service' exposure (Needed if the master will also run user workloads). I think it's optional. need to verify.
firewall-cmd --permanent --zone=public --add-source=10.244.0.0/16  # to allow pod network interface

# on worker nodes:
# allow the ports: 10250/tcp (kubelet), 8472/udp (NCI), and 30000-32767 (to expose NodePort services)
firewall-cmd --permanent --add-port=8472/udp           # Required CNI UDP Port (for Flannel), ## to allow worker to worker traffic
firewall-cmd --permanent --add-port=10250/tcp          # kubelet API
firewall-cmd --permanent --add-port=30000-32767/tcp    # for k8s - NodePort Services exposure
firewall-cmd --permanent --zone=public --add-source=10.244.0.0/16  # to allow pod network interface

# reload firewall to reflect changes
firewall-cmd --reload
firewall-cmd --list-ports
firewall-cmd --list-all

## NOTE: 
# 10257 (controller manager) and 10259 (scheduler). These ports are internal communication ports and are not strictly necessary to open in the firewall. since communication happens over the internal network interfaces (which are usually less restricted) or via the API server. So, Keeping only 6443, 2379-2380, 10250, and 8472 is sufficient and cleaner on master node. And for worker node, 10250, 8472, 30000-32767. But, make sure to add public zone with pod network NIC IP.


# 5: Set hostnames (on all nodes)
# update the '/etc/hosts' file, with the master and worker node ips.
192.168.31.159 tron-master
192.168.31.137 tron-worker1
192.168.31.189 tron-worker2


# 6: Load networking modules to kernel. (on all nodes)
# These steps prepare the kernel for Kubernetes networking.
# create 'k8s.conf' file in '/etc/modules-load.d/' directory & add the 'overlay' & 'br_netfileter' modules to it.
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
# Apply the modules
sudo modprobe overlay
sudo modprobe br_netfilter


# 7: Load networking parameters to kernel. (on all nodes)
# These settings are standard for Kubernetes networking. 
# create 'k8s.conf' file in '/etc/sysctl.d' directory & add the following 'sysctl parameters' to it.
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
# Apply the sysctl parameters
sysctl --system



STAGE 2: INSTALL CONTAINER RUNTIME & K8S-COMPONENTS: kubeadm, kubelet, kubectl (on all nodes)


# 8: If the Container runtime is: 'Docker-Engine'


# Steps to install 'docker-engine'. (on all nodes)

# 8.1: Remove any existing Docker installation.
sudo dnf remove docker \
              docker-client \
              docker-client-latest \
              docker-common \
              docker-latest \
              docker-latest-logrotate \
              docker-logrotate \
              docker-engine

# 8.2: Install dnf-plugins-core.
sudo dnf -y install dnf-plugins-core

# 8.3: Add the Docker repository:
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

# 8.4: Install Docker, Containerd, and necessary plugins.
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# verify GPG KEY, if prompted (as per 'docker' documentation):
060A 61C5 1B55 8A7F 742B 77AA C52F EB6B 621E 9F35
# installed dependencies: container-selinux, fuse-common, fuse-overlayfs, fuse3, iptables-nft, passt, passt-selinux, tar, docker-ce-rootless-extras (weak dependency)

# 8.5: Enable and start Docker (Required after installation)
sudo systemctl status docker
sudo systemctl start docker
sudo systemctl enable --now docker

# 8.6: Add the os user to the docker group (helps, to run the docker cli commands as non root user)
# as os user, run:
sudo usermod -aG docker $USER
# (OR) as the root user, run:
usermod -aG docker phoenix
# DONE

# 8.7: exit to switch to os user and run:
newgrp docker
no need to run this command it seems.


# Install 'CRI-Dockerd' Service: (on all nodes)
# #########################################################################

## Given Instructions: (for version: v0.3.12)
# download the rpm package from  https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.12/cri-dockerd-0.3.12-3.el8.src.rpm
# install the downloaded RPM ( rpm -ivh rpm package name)
# start the cri dockerd
# systemctl enable --now cri-docker.service

# on official github page, for version v0.3.12, I found these 2 are available for el8:
https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.12/cri-dockerd-0.3.12-3.el8.x86_64.rpm
https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.12/cri-dockerd-0.3.12-3.el8.src.rpm


# Install using 'x86_64' rpm:

# Without libcgroup, I am getting error to install 'cri-dockerd'
# 8.1.8: download and intall libcgroup.
wget https://kojihub.stream.centos.org/kojifiles/packages/libcgroup/0.41/19.el8/x86_64/libcgroup-0.41-19.el8.x86_64.rpm
sudo dnf install -y libcgroup-0.41-19.el8.x86_64.rpm

# 8.1.9: After installing 'libcgroup', download and install 'cri-dockerd':
wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.12/cri-dockerd-0.3.12-3.el8.x86_64.rpm
sudo dnf install -y cri-dockerd-0.3.12-3.el8.x86_64.rpm

# 8.1.10: enable 'cri-dockerd':
sudo systemctl daemon-reload
sudo systemctl status cri-docker.socket
sudo systemctl enable cri-docker.socket
sudo systemctl start cri-docker.socket
sudo systemctl status cri-docker.socket
# DONE.
# #########################################################################


### (OR) install using a TAR Ball. 
# Recommended method. Always pickup the latest release, but not pre-release version. (version: 'v0.3.20')
# Installing necessary utility: wget, tar. Use, 'which wget/tar' or 'dnf list installed wget/tar' commands, to verify.
sudo dnf install -y wget tar
# version v0.3.21 is also available, https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.21/cri-dockerd-0.3.21.amd64.tgz
# But I am installing 'v0.3.20':
wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.20/cri-dockerd-0.3.20.amd64.tgz
# Extract the archive
tar xvf cri-dockerd-0.3.20.amd64.tgz
# Move the binary to a system path
sudo install -o root -g root -m 0755 cri-dockerd/cri-dockerd /usr/local/bin/cri-dockerd
# Download the systemd service and socket files
sudo wget -O /etc/systemd/system/cri-docker.socket https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.socket
sudo wget -O /etc/systemd/system/cri-docker.service https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.service
# Update the service file to point to the correct binary location (/usr/local/bin)
sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
# Clean up downloaded files
rm -rf cri-dockerd cri-dockerd-0.3.20.amd64.tgz
# Reload the systemd daemon configuration
sudo systemctl daemon-reload
# Check status, and enable 'cri-docker' service (and socket)
sudo systemctl status cri-docker.service        # not active and not enabled.
sudo systemctl enable --now cri-docker.service
sudo systemctl status cri-docker.service
# Verify the service is running (optional)
systemctl status cri-docker.socket      # active but disabled
systemctl enable cri-docker.socket
systemctl status cri-docker.socket
# Installed 'cri-docker service' (version: 'v0.3.20')
# DONE.
# ################################################################



# 9: Install Kubeadm, Kubelet, and Kubectl: (on all nodes)
# create a repository to install kubelet, kubeadm, kubectl.

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

# Install the K8s components (kubelet, kubeadm and kubectl)
sudo dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
# installed dependencies: conntrack-tools, cri-tools, kubernetes-cni, libnetfilter_cthelper, libnetfilter_cttimeout, libnetfilter_queue

# MUST enable kubelet, before initializing k8s cluster.
sudo systemctl status kubelet
sudo systemctl enable kubelet.service
sudo systemctl status kubelet



STAGE 3: INITIALIZE THE CLUSTER.    (on master node)


# 10: Initialize cluster (with 'Docker')


# To initialize a cluster with: 'DOCKER-ENGINE'
# use '--pod-network-cidr' and '--cri-socket' flags with values. For single master node, '--control-plane-endpoint' flag is optional.
# initialize as os user.
# example:
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --cri-socket=unix:///var/run/cri-dockerd.sock
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --cri-socket=unix:///var/run/cri-dockerd.sock --control-plane-endpoint=192.168.31.67:6443
###


# if the custer set-up is successful, you will see the following message.
# Example Output:
###
# Your Kubernetes control-plane has initialized successfully!

# To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

# You should now deploy a pod network to the cluster.
# Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
#  https://kubernetes.io/docs/concepts/cluster-administration/addons/

# You can now join any number of control-plane nodes by copying certificate authorities and service account keys on each node and then running the following as root:

  kubeadm join 192.168.31.67:6443 --token t1t6af.lz6wguanwq5gqtn8 \
        --discovery-token-ca-cert-hash sha256:94ae00d9729dac7923e087c14808d1646ad904b6c389eff7206120faf522d915 \
        --control-plane

# Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.31.67:6443 --token t1t6af.lz6wguanwq5gqtn8 \
        --discovery-token-ca-cert-hash sha256:94ae00d9729dac7923e087c14808d1646ad904b6c389eff7206120faf522d915 \ 
        --cri-socket=unix:///var/run/cri-dockerd.sock
###



# as per the above output, follow the on-screen instructions.

# 1: Configure Kubectl Access for OS user. Run as os user. (On master node)
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
# (OR) as root user, run:
export KUBECONFIG=/etc/kubernetes/admin.conf

# 2: Should now deploy a 'pod network add-on'. (on master node)
# For 'flannel': 
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# 3: You can now join any number of control-plane nodes by copying certificate authorities and service account keys on each node and then running the following as root:
# syntax:
  kubeadm join 192.168.31.189:6443 --token <token> \
        --discovery-token-ca-cert-hash sha256:<hash> \
        --control-plane

# 4. Join worker nodes to the cluster: (on worker nodes)
# use the 'kubeadm join' command with 'tokens/hash' values that were generated during the cluster initialization.
# MUST use '--cri-socket' flag with value, if using 'docker-engine' runtime. Omit '--cri-socket' flag for 'containerd' runtime.
# syntax:
sudo kubeadm join 192.168.31.182:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash> --cri-socket=unix:///var/run/cri-dockerd.sock
###

### NOTE:
# In case, if tokens generated using 'kubeadm init' command are lost, use following command to refetch them:
sudo kubeadm token create --print-join-command
# example output:
kubeadm join 192.168.31.182:6443 --token 2vcpph.kgugurjfdod9onw5 --discovery-token-ca-cert-hash sha256:6eb2a8ca920529eeac775d73baa55fce80a8d44c97965e51a2537adf232c3d69 --cri-socket=unix:///var/run/cri-dockerd.sock



Stage 5: INSTALL METRICS SERVER & configure it.

# Install metrics server: (on master node)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# As we do not have secure certificates, edit metric server deployment to add the flag '--kubelet-insecure-tls'. (spec.template.spec.containers.args)
kubectl edit deployment/metrics-server -n kube-system
# Save it.
# if needed, restart the metrics-server using rollout. BUT, no need to rollout. k8s is automatically starting a new metrics server.
# kubectl rollout restart deployment/metrics-server -n kube-system



Stage 6: Verify cluster setup

# Check node status (they should eventually transition to 'Ready')
kubectl get nodes
kubectl get deployments -n kube-system
kubectl get deployments
kubectl get services

# ultimate check: get the resource usage data with top command.
kubectl top nodes



Stage 7: Add-ons: Git, Bash completion, Chrony, wget, tar, dnf-plugins-core, 

# Install Git. (On all nodes?)
sudo dnf install -y git
# sudo dnf history
# sudo dnf remove git
# sudo dnf autoremove

# Bash completion:
echo 'source <(kubectl completion bash)' >> ~/.bashrc
source ~/.bashrc
sudo dnf install bash-completion -y
echo '[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && . /usr/share/bash-completion/bash_completion' >> ~/.bashrc
source ~/.bashrc

# I got some errors related to time syncronization. So did some research and installed 'chrony' to resolve the errors.
# Install Chrony service & enable it:
sudo dnf install -y chrony
sudo systemctl enable --now chronyd
# Force an immediate time synchronization:
sudo chronyc sources        # Optional: check connection to time sources
sudo chronyc -a makestep    # Force step the system clock
# Check the time on the node:
date
# Verify whether the time zone is reasonable and the clock is accurate.



### To remove a 'worker node' from the cluster:
###
# step 1: (on master node)
kubectl drain tron-worker1 --ignore-daemonsets --delete-local-data
# output:
Flag --delete-local-data has been deprecated, This option is deprecated and will be deleted. Use --delete-emptydir-data.
node/tron-worker1 cordoned
Warning: ignoring DaemonSet-managed Pods: kube-flannel/kube-flannel-ds-wxfrs, kube-system/kube-proxy-hmfrt
node/tron-worker1 drained
# ran the above command w.r.t output message:
kubectl drain tron-worker1 --ignore-daemonsets --delete-emptydir-data
# output:
node/tron-worker1 already cordoned
Warning: ignoring DaemonSet-managed Pods: kube-flannel/kube-flannel-ds-wxfrs, kube-system/kube-proxy-hmfrt
node/tron-worker1 drained
# once the drain is complete, delete node from the cluster
kubectl delete node tron-worker1

# step 2: (on worker node)
sudo kubeadm reset --force
# its asking to set the socket.
sudo kubeadm reset --force --cri-socket=unix:///var/run/cri-dockerd.sock
# optional (I didn't done)
# sudo rm -rf /etc/cni/net.d/*
# sudo rm -rf /var/lib/kubelet/*
kubeadm join 192.168.31.78:6443 --token 9ibkbe.sn1kcwe7fzmuujnx \
        --discovery-token-ca-cert-hash sha256:35369cdbbb640c8a346dc6c0bf2b137f9fa185400f8dedbf2accc0ab6cc238b2 \
        --cri-socket=unix:///var/run/cri-dockerd.sock
###
# DONE
# working.
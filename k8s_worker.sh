curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
cat <<EOF | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
# cat /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl kubernetes-cni

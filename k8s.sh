curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
cat <<EOF | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
# cat /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl kubernetes-cni
sudo kubeadm init
mkdir ~/.kube
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
sudo sysctl net.bridge.bridge-nf-call-iptables=1
kubever=$(kubectl version | base64 | tr -d '\n')
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"
sudo kubeadm token create --print-join-command 2>/dev/null

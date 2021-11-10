# Install minikube v1.22.0
sudo apt install conntrack -y
curl -LO https://github.com/kubernetes/minikube/releases/download/v1.22.0/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube config set driver none

# vagrant-tech-test
Vagrant environment for use in the DevOps Technical Test

## Requirements:

Install git for windows
```
https://github.com/git-for-windows/git/releases/download/v2.33.1.windows.1/Git-2.33.1-64-bit.exe
```
Enable OpenSSH Client for windows
```
https://winaero.com/enable-openssh-client-windows-10/
```
Install Vagrant 2.2.19: 
```
https://releases.hashicorp.com/vagrant/2.2.19/vagrant_2.2.19_x86_64.msi
```
Install VirtualBox 6.1.28 and Extension Package same version: 
```
https://download.virtualbox.org/virtualbox/6.1.28/VirtualBox-6.1.28-147628-Win.exe
https://download.virtualbox.org/virtualbox/6.1.28/Oracle_VM_VirtualBox_Extension_Pack-6.1.28.vbox-extpack
```

## Step by step to run the environment
1 - After clone the project, in the root folder, Start the vagrant box
```
vagrant up && vagrant ssh
```
2 - Inside the vagrant box, start the minikube k8s cluster and install the ingress controller: 
```
minikube start
minikube addons enable ingress
```
3 - Run the terraform init and terraform apply inside the project folder
```
cd ~/projects/terraform-infra
terraform init
terraform apply -auto-approve
```
After terraform apply, the application is accessible by address below:
```
mywebsite-app-192-168-50-11.nip.io
```
4 - Install Prometheus and Grafana via helm repositories
Prometheus
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/prometheus --namespace douglas-k8s-demo
kubectl expose service --namespace douglas-k8s-demo prometheus-server --type=NodePort --target-port=9090 --name=prometheus-server-np
```
Grafana
```
helm repo add grafana https://grafana.github.io/helm-charts
helm install grafana grafana/grafana --namespace douglas-k8s-demo
kubectl expose service --namespace douglas-k8s-demo grafana --type=NodePort --target-port=3000 --name=grafana-np
Grafana password:
kubectl get secret --namespace douglas-k8s-demo grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```
List minikube services nodeports and access using the ip 192.168.50.11:port instead
```
minikube service list --namespace douglas-k8s-demo | grep np
```
Login in the grafana dashboard (192.168.50.11:grafana_port) and configure:
```
datasource: Prometheus, with url http://prometheus-server:80 
dashboard: import new dashboard and load from https://grafana.com/grafana/dashboards/6417 and select the prometheus datasource
```
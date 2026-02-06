# Variables
CLUSTER_NAME=lab
IMAGE_NAME=my-nginx-image:latest
PORT_TEST=9000

all: install build cluster-prep deploy test

install:
	@echo "--- Installation des outils ---"
	wget -q https://releases.hashicorp.com/packer/1.10.0/packer_1.10.0_linux_amd64.zip
	unzip -o packer_1.10.0_linux_amd64.zip && sudo mv packer /usr/local/bin/
	rm packer_1.10.0_linux_amd64.zip
	pip install ansible kubernetes
	ansible-galaxy collection install kubernetes.core

build:
	@echo "--- Build de l'image avec Packer ---"
	packer init image.pkr.hcl
	packer build image.pkr.hcl

cluster-prep:
	@echo "--- Configuration du cluster K3d ---"
	-k3d cluster create $(CLUSTER_NAME) --servers 1 --agents 2
	k3d image import $(IMAGE_NAME) -c $(CLUSTER_NAME)

deploy:
	@echo "--- Déploiement avec Ansible ---"
	ansible-playbook deploy.yml

test:
	@echo "--- Test de l'application sur le port $(PORT_TEST) ---"
	@echo "Lien disponible dans l'onglet PORTS du Codespace"
	kubectl port-forward svc/nginx-service $(PORT_TEST):80

clean:
	@echo "--- Nettoyage ---"
	k3d cluster delete $(CLUSTER_NAME)
	docker rmi $(IMAGE_NAME)

------------------------------------------------------------------------------------------------------
ATELIER FROM IMAGE TO CLUSTER
------------------------------------------------------------------------------------------------------
L’idée en 30 secondes : Cet atelier consiste à **industrialiser le cycle de vie d’une application** simple en construisant une **image applicative Nginx** personnalisée avec **Packer**, puis en déployant automatiquement cette application sur un **cluster Kubernetes** léger (K3d) à l’aide d’**Ansible**, le tout dans un environnement reproductible via **GitHub Codespaces**.
L’objectif est de comprendre comment des outils d’Infrastructure as Code permettent de passer d’un artefact applicatif maîtrisé à un déploiement cohérent et automatisé sur une plateforme d’exécution.
  
---------------------------------------------------
---------------------------------------------------
Séquence 2 : Création du cluster Kubernetes K3d
---------------------------------------------------
Objectif : Créer votre cluster Kubernetes K3d  
Difficulté : Simple (~5 minutes)
---------------------------------------------------
Vous allez dans cette séquence mettre en place un cluster Kubernetes K3d contenant un master et 2 workers.  
Dans le terminal du Codespace copier/coller les codes ci-dessous etape par étape :  

**Création du cluster K3d**  
```
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
```
```
k3d cluster create lab \
  --servers 1 \
  --agents 2
```
**vérification du cluster**  
```
kubectl get nodes
```
**Déploiement d'une application (Docker Mario)**  
```
kubectl create deployment mario --image=sevenajay/mario
kubectl expose deployment mario --type=NodePort --port=80
kubectl get svc
```
**Forward du port 80**  
```
kubectl port-forward svc/mario 8080:80 >/tmp/mario.log 2>&1 &
```
**Réccupération de l'URL de l'application Mario** 
Votre application Mario est déployée sur le cluster K3d. Pour obtenir votre URL cliquez sur l'onglet **[PORTS]** dans votre Codespace et rendez public votre port **8080** (Visibilité du port).
Ouvrez l'URL dans votre navigateur et jouer !

---------------------------------------------------
Séquence 3 : Exercice
---------------------------------------------------
Objectif : Customisez un image Docker avec Packer et déploiement sur K3d via Ansible
Difficulté : Moyen/Difficile (~2h)
---------------------------------------------------  
Votre mission (si vous l'acceptez) : Créez une **image applicative customisée à l'aide de Packer** (Image de base Nginx embarquant le fichier index.html présent à la racine de ce Repository), puis déployer cette image customisée sur votre **cluster K3d** via **Ansible**, le tout toujours dans **GitHub Codespace**.  

**Architecture cible :** Ci-dessous, l'architecture cible souhaitée.   
  
![Screenshot Actions](Architecture_cible.png)   
  
---------------------------------------------------  
## Processus de travail (résumé)

1. Installation du cluster Kubernetes K3d (Séquence 1)
2. Installation de Packer et Ansible
3. Build de l'image customisée (Nginx + index.html)
4. Import de l'image dans K3d
5. Déploiement du service dans K3d via Ansible
6. Ouverture des ports et vérification du fonctionnement

---------------------------------------------------
---------------------------------------------------

# Les Outils et leurs Rôles

Packer créé une image Docker "immutable" en prenant une base Nginx et en y injectant notre code (index.html).

K3dLe est une version légère de Kubernetes (K3s) qui tourne dans Docker, idéale pour simuler un environnement de production localement.

Ansible automatise le déploiement. Au lieu de taper des commandes kubectl manuellement, on décrit l'état voulu dans un fichier YAML.

GitHub Codespaces fournit une machine de développement reproductible dans le cloud.


## Guide de démarrage r

### 1. Préparation de l'environnement

```
Installation de Packer
wget https://releases.hashicorp.com/packer/1.10.0/packer_1.10.0_linux_amd64.zip
unzip packer_1.10.0_linux_amd64.zip && sudo mv packer /usr/local/bin/

# Installation d'Ansible et des dépendances K8s
pip install ansible kubernetes
ansible-galaxy collection install kubernetes.core
```

### 2. Création de l'infrastructure
```
k3d cluster create lab --servers 1 --agents 2
```

### 3. Build et Import de l'image
```
# Build de l'image custom
packer init image.pkr.hcl
packer build image.pkr.hcl

# Import dans le cluster
k3d image import my-nginx-image:latest -c lab
```

### 4. Déploiement 
```
ansible-playbook deploy.yml
```
### 5. Vérifier que tout fonctionne 

Vérifier les ressources
```
kubectl get all
```
->  2 pods nginx-custom en état "Running" et un service nginx-service.

Accès à l'interface (le port-forwarding)
```
kubectl port-forward svc/nginx-service 8080:80
```
Cliquez sur l'alerte "Open in Browser" -> une maison apparait
# **DevOps TP2 - GitHub Actions**

<image src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSpJDw7JAy7mQ_Av8IU14GcsPBBdrwfZV8cHQ&usqp=CAU" width=750 center>


[<img src="https://img.shields.io/badge/GitHub Actions-CI/CD Workflow-yellow.svg?logo=githubactions">](https://www.redhat.com/en/topics/devops/what-is-ci-cd#:~:text=CI%2FCD%20is%20a%20method,continuous%20delivery%2C%20and%20continuous%20deployment.)                                             [<img src="https://img.shields.io/badge/docker registry-frimpongefrei/api:1.0.0-blue.svg?logo=docsdotrs">](https://hub.docker.com/r/frimpongefrei/api/tags)                                              [<img src="https://img.shields.io/badge/PyPI-requests:2.29.0-important.svg?logo=pypi">](https://pypi.org/project/requests/)                                              [<img src="https://img.shields.io/badge/dockerhub-hadolint/hadolint-blueviolet.svg?logo=docker">](https://hub.docker.com/r/hadolint/hadolint)                                              [<img src="https://img.shields.io/badge/Homebrew-aquasecurity/trivy/trivy-red.svg?logo=homebrew">](https://aquasecurity.github.io/trivy/v0.18.3/installation/)



***
***
## **SYNOPSIS**

Ce projet vise à automatiser le déploiement d'une image `Docker` d'une part et à transformer en API le wrapper `Python` écrit dans le précédent TP. 

***
***
## **REVUE TECHNIQUE**

> ### **<u>Configurer un Workflow GitHub Actions</u>**

> Préalablement, se connecter à son compte DockerHub et obtenir `l'API TOKEN` vous permettant de lire, écrire et supprimer. Pour ce faire, sur votre espace `DockerHub`, aller à `Account settings > Security > New Access Token` et entrer les informations necessaires puis copier l'API TOKEN dans un lieu sûr. Ensuite sur votre repository `GitHub`, aller à `Settings > Secrets and variables > Actions > New repository secret`. Nommez le token `USERNAME_DOCKERHUB` et donnez lui en valeur votre nom d'utilisateur DockerHub. Répétez la même opération avec `TOKEN_DOCKERHUB` comme nom de TOKEN et l'API TOKEN comme valeur.

> En se positionnant dans notre repository GitHub, sélectionner l'onglet `Actions > New workflow > set up a workflow yourself`, puis coller le code suivant dans l'espace de code:

```
name: Automatisation du déploiement du container sur DockerHub

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:

  build:

    runs-on: ubuntu-latest

    steps:
    - name: Scanner du code
      uses: actions/checkout@v3
    - name: Authentification à DockerHub
      uses: docker/login-action@v1
      with:
        username: ${{ secrets.USERNAME_DOCKERHUB }}
        password: ${{ secrets.TOKEN_DOCKERHUB }}
    - name: Construction du container
      uses: docker/build-push-action@v2
      with:
        context: .
        push: true
        tags: frimpongefrei/api:1.0.0
```

Ensuite nommer le fichier `docker-image.yml`. Et effectuer l'opération de `Start commit`. Retourner dans `Actions`, et suivre l'évolution du processus d'automatisation.
***

> ### **<u>Transformation du wrapper en API(fichier *Dockerfile*)</u>**
> Le Dockerfile contient des instructions à exécutions séquentiels pour créer le container final. On distingue:

```
FROM python:3.11
```
- Cette instruction permet de spécifier l'image Docker à partir de laquelle notre container sera construite (ici l'image `python:3.11`).

```
ARG LAT
ENV LAT=$LAT
ARG LONG
ENV LONG=$LONG
ARG API_KEY
ENV API_KEY=$API_KEY
```
- L'instruction `ARG LAT` permet de définir une valeur pour la variable `LAT`. Ensuite l'instruction `ENV LAT=$LAT` permet d'initialiser la variable d'environnement `LAT` à partir de la valeur de la variable de `ARG LAT` précédemment déclarée. Le même mécanisme s'applique aux autres variables d'environnement. Plus d'informations [ici](https://vsupalov.com/docker-arg-env-variable-guide/#:~:text=ARG%20are%20also%20known%20as,access%20values%20of%20ARG%20variables.).

```
WORKDIR /app
```
- Cette instruction spécifie le répertoire courant par défaut du container (ici `/app`).

```
COPY weatherWraper.py /app
```
- Cette instruction effectue une copie du fichier `weatherWraper.py` dans le répertoire courant par défaut du container.

```
RUN pip install --no-cache-dir requests==2.29.0
```
- Cette instruction exécute la commande d'installation de la version `2.29.0` du package Python `requests`. Le paramètre `--no-cache-dir` permet de nettoyer les métadonnées en cache générées par la commande (utile pour libérer de l'espace mémoire).

```
CMD ["sh", "-c", "python weatherWraper.py $LAT $LONG $API_KEY"]
```
- Cette instruction exécute en mode `shell` la commande `python weatherWraper.py LAT LONG API_KEY`, tout en tenant compte des variables d'environnement définies dans le Dockerfile.

***
***
## **SCRIPT D'EXECUTION (FICHIER *setup.sh*)**
Le script d'exécution est contenu dans le fichier `setup.sh`. Il suffit de l'exécuter pour créer le container à partir du Dockerfile et l'envoyer dans un registry. Il faut d'abord s'authentifier préalablement. Pour modifier le nom du registry ou le nom du container créer, il suffit de modifier les variables prédéfinies dans le fichier.
```
####### VARIABLES ##########
REGISTRY=frimpongefrei/api:1.0.0
CONTAINER_NAME=api:1.0.0
```

Pour exécuter le fichier, pocéder comme suit:
```
> chmod u+x setup.sh
> docker log -u myusername
> sh setup.sh
```


***
***
## **TESTS TECHNIQUES**

> ### **<u>Lint Errors</u>**
> La commande suivante permet de passer en revue notre Dockerfile à la lumière d'un linter. Le linter utilisé est `hadolint` (l'image docker). Pour ce faire, il suffit d'exécuter la commande suivante.
```
> docker run --rm -i hadolint/hadolint < Dockerfile
```

**<u>N.B</u>: Notre Dockerfile a 0 lint error(s).**

***

> ### **<u>CVE checking</u>**
> Cette étape nous permet de visualiser les différentes vulnérabilités présentes dans le container créé. Pour ce faire, exécuter la commande suivante (Sur MacOS):
```
> brew install aquasecurity/trivy/trivy
> trivy image maregistry/api:1.0.0
```
***
***



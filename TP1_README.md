# **DevOps TP1 - Docker**

<image src="https://www.howtogeek.com/wp-content/uploads/csit/2021/04/075c8694.jpeg?height=200p&trim=2,2,2,2&crop=16:9" width=800 center>

<br />

[<img src="https://img.shields.io/badge/dockerhub-python:3.11-yellow.svg?logo=docker">](https://hub.docker.com/_/python)                                             [<img src="https://img.shields.io/badge/docker registry-frimpongefrei/api:1.0.0-blue.svg?logo=docsdotrs">](https://hub.docker.com/r/frimpongefrei/api/tags)                                              [<img src="https://img.shields.io/badge/PyPI-requests:2.29.0-important.svg?logo=pypi">](https://pypi.org/project/requests/)                                              [<img src="https://img.shields.io/badge/dockerhub-hadolint/hadolint-blueviolet.svg?logo=docker">](https://hub.docker.com/r/hadolint/hadolint)                                              [<img src="https://img.shields.io/badge/Homebrew-aquasecurity/trivy/trivy-red.svg?logo=homebrew">](https://aquasecurity.github.io/trivy/v0.18.3/installation/)

<br />

***
***
<br />

## **SYNOPSIS**

Ce projet vise à créer un programme (un wrapper) qui retourne la météo d'un lieu donné avec sa latitude et sa longitude (passées en variable d'environnement) en utilisant `Openweather API` dans le langage deprogrammation de votre choix (`bash`, `python`, `go`, `nodejs`, etc). Ce programme devra être packagé dans un `Dockerfile` et déployé sous forme de container `Docker`. 

<br />

***
***
<br />

## **REVUE TECHNIQUE**

> ### **<u>Création du wrapper</u> (fichier *weatherWraper.py*)**
> Notre Wrapper est un programme `Python` (le fichier `weatherWraper.py`) qui utilise des appels API pour obtenir les informations météo selon les coordonnées géographiques. Notamment, le package `requests` de python permet de réaliser ces appels API. Le wrapper, grâce au module `sys.argv`, permet de prendre en compte des valeurs passées en ligne de commande. Cette propriété du wrapper permettra de lui associer les variables d'environnement du Dockerfile. Les arguments pris en ligne de commande devront être obligatoirement disposés dans l'ordre suivant: LAT -> LONG -> API_KEY. L'exécution type est la suivante :

```
> python weatherWraper.py LAT LONG API_KEY
```
***
<br />

> ### **<u>Création du Dockerfile (fichier *Dockerfile*)</u>**
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

<br />

***
***
<br />

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

<br />

***
***
<br />

## **TESTS TECHNIQUES**

> ### **<u>Lint Errors</u>**
> La commande suivante permet de passer en revue notre Dockerfile à la lumière d'un linter. Le linter utilisé est `hadolint` (l'image docker). Pour ce faire, il suffit d'exécuter la commande suivante.
```
> docker run --rm -i hadolint/hadolint < Dockerfile
```

**<u>N.B</u>: Notre Dockerfile a 0 lint error(s).**

***
<br />

> ### **<u>CVE checking</u>**
> Cette étape nous permet de visualiser les différentes vulnérabilités présentes dans le container créé. Pour ce faire, exécuter la commande suivante (Sur MacOS):
```
> brew install aquasecurity/trivy/trivy
> trivy image maregistry/api:1.0.0
```
***
***

<br />

## **DOCKER HUB**
> L'image Docker de ce projet est `frimpongefrei/api:1.0.0`

> Exemple d'exécution:
```
> docker pull frimpongefrei/api:1.0.0
> docker run --env LAT="31.2504" --env LONG="-99.2506" --env API_KEY=**** frimpongefrei/api:1.0.0
```

<br />

***
***

<br />

## **CRÉDITS**

<image src="https://frimpong-adotri-01.github.io/mywebsite/pictures/me.png" width=200 center>  

**AUTEUR :** ADOTRI Frimpong

**PROMO :** Big Data & Machine Learning (EFREI)

**PROFESSEUR :** DOMINGUES Vincent

**COPYRIGHT :** Avril 2023

***
***



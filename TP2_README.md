# **DevOps TP2 - GitHub Actions**


<image src="https://www.padok.fr/hubfs/Imported_Blog_Media/github-actions-tutorial.webp" width=1000 center>

<br />

[<img src="https://img.shields.io/badge/GitHub Actions-CI/CD Workflow-yellow.svg?logo=githubactions">](https://github.com/efrei-ADDA84/20220505/actions/workflows/docker-image.yml)                                             [<img src="https://img.shields.io/badge/docker registry-frimpongefrei/api:1.0.0-blue.svg?logo=docsdotrs">](https://hub.docker.com/r/frimpongefrei/api/tags)                                              [<img src="https://img.shields.io/badge/PyPI-requests:2.29.0-important.svg?logo=pypi">](https://pypi.org/project/requests/)                               [<img src="https://img.shields.io/badge/fastAPI-0.95.1-blue.svg?logo=fastapi">](https://fastapi.tiangolo.com/)                               [<img src="https://img.shields.io/badge/uvicorn-0.22.0-red.svg?logo=gunicorn">](https://www.uvicorn.org/)                                         [<img src="https://img.shields.io/badge/dockerhub-hadolint/hadolint-blueviolet.svg?logo=docker">](https://hub.docker.com/r/hadolint/hadolint)


<br />

***
***
<br />

## **SYNOPSIS**

Ce projet vise à automatiser le déploiement d'une image `Docker` d'une part et à transformer en API le wrapper `Python` écrit dans le précédent TP. 

<br />

***
***
<br />

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
    - name: Ckecking des Lint errors avec Hadolint
      uses: hadolint/hadolint-action@v3.1.0
      with:
        dockerfile: Dockerfile
    - name: Construction du container
      uses: docker/build-push-action@v2
      with:
        context: .
        push: true
        tags: frimpongefrei/api:2.0.0
```

Ensuite nommer le fichier `docker-image.yml`. Et effectuer l'opération de `Start commit`. Retourner dans `Actions`, et suivre l'évolution du processus d'automatisation.

***
<br />

> ### **<u>Transformation du wrapper en API</u>**

> Notre wrapper étant écrit en Python, nous utiliserons le module Python `fastAPI` pour transformer notre wrapper en API. Le code suivant transforme le wrapper en API:

```
from os import environ
import requests
from fastapi import FastAPI

# ================ fastAPI setup ================

app = FastAPI()

@app.get("/")
async def read_item(lat:float, lon:float):
    url = f"https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API_Key}"
    res = requests.get(url)
    data = res.json()
    return data
```
***
<br />

> ### **<u>*Requirements.txt*</u>**

> Il nous faut définir un fichier `requirements.txt` afin de spécifier au `Dockerfile` les packages nécessaires à l'exécution du fichier  `weatherWraperAPI.py`. Le contenu du fichier `requirements.txt` est le suivant:

```
fastapi==0.95.1
uvicorn==0.22.0
requests==2.29.0
```
***
<br />

> ### **<u>*Dockerfile*</u>**

> Le Dockerfile contient des instructions à exécutions séquentiels pour créer le container final. On distingue:

```
FROM python:3.11
```
- Cette instruction permet de spécifier l'image Docker à partir de laquelle notre container sera construite (ici l'image `python:3.11`).

```
WORKDIR /app
```
- Cette instruction spécifie le répertoire courant par défaut du container (ici `/app`).

```
COPY weatherWraperAPI.py /app
COPY requirements.txt /app
```
- Cette instruction effectue une copie du fichier `weatherWraper.py` dans le répertoire courant par défaut du container. Idem pour le fichier `requirements.txt`

```
RUN pip install --no-cache-dir -r requirements.txt
```

- Cette instruction exécute la commande d'installation des packages Python dans le fichier `requirements.txt`. Le paramètre `--no-cache-dir` permet de nettoyer les métadonnées en cache générées par la commande (utile pour libérer de l'espace mémoire).

```
CMD ["uvicorn", "weatherWraperAPI:app", "--port", "8081", "--host", "0.0.0.0", "--reload"]
```
- Cette instruction exécute la commande `uvicorn weatherWraperAPI:app --port 8081 --host 0.0.0.0 --reload` qui démarre un serveur en background au port $8080$ et l'actualise en temps réel.

<br />

***
***
<br />

## **EXÉCUTION**
> À chaque `push` sur le repository GitHub, le `Workflow GitHub Actions` automatise la construction et le déploiement des images Docker dans le DockerHub.

<br />

***
***
<br />

## **TESTS TECHNIQUES**

> ### **<u>Lint Errors</u>**
> Le test des Lint errors est intégré au code de configuration `.yml` du `Workflow GitHub Actions`. Le code est le suivant:

```
- name: Ckecking des Lint errors avec Hadolint
      uses: hadolint/hadolint-action@v3.1.0
      with:
        dockerfile: Dockerfile
```

**<u>N.B</u>: Notre Dockerfile a 0 lint error(s).**

<br />

***
***

<br />

## **DOCKER HUB**
> L'image Docker de ce projet est `frimpongefrei/api:2.0.0`

> Pour exécuter le projet:
```
> docker pull frimpongefrei/api:2.0.0
> docker run -p 8081:8081 --env API_KEY=myApiKey frimpongefrei/api:2.0.0
```
Dans un autre terminal, exécuter des commandes `curl` pour effectuer les appels APIs. Si l'on souhaite obtenir les informations pour des coordonnées géographiques spécifiques (`lat=5.902785, lon=102.754175`):

```
> curl "http://localhost:8081/?lat=5.902785&lon=102.754175"
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

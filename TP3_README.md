# **DevOps TP3 - GitHub Actions + Azure containers**


<image src="https://learn.microsoft.com/en-us/azure/container-apps/media/github-actions/azure-container-apps-github-actions.png" width=1000 center>

[<img src="https://img.shields.io/badge/GitHub Actions-CI/CD Workflow-yellow.svg?logo=githubactions">](https://github.com/efrei-ADDA84/20220505/actions/workflows/docker-image.yml)                                             [<img src="https://img.shields.io/badge/Azure Container Instance-devops--20220505.francecentral.azurecontainer.io-blue.svg?logo=microsoftazure">]()                                              [<img src="https://img.shields.io/badge/PyPI-requests:2.29.0-important.svg?logo=pypi">](https://pypi.org/project/requests/)                               [<img src="https://img.shields.io/badge/fastAPI-0.95.1-blue.svg?logo=fastapi">](https://fastapi.tiangolo.com/)                               [<img src="https://img.shields.io/badge/uvicorn-0.22.0-red.svg?logo=gunicorn">](https://www.uvicorn.org/)                       ![Deploy badge](https://github.com/efrei-ADDA84/20220505/actions/workflows/azure-docker-image.yml/badge.svg?event=push)           ![Deploy badge](https://github.com/efrei-ADDA84/20220505/actions/workflows/dockerhub-image-build.yml/badge.svg?event=push)         [<img src="https://img.shields.io/badge/dockerhub-hadolint/hadolint-blueviolet.svg?logo=docker">](https://hub.docker.com/r/hadolint/hadolint)                                       

<br />

***
***
<br />

## **SYNOPSIS**

Ce projet vise à automatiser le déploiement d'une image `Docker` sur **Azure** d'une part et à transformer en API le wrapper `Python` écrit dans le précédent TP. 

<br />

***
***
<br />

## **REVUE TECHNIQUE**

> ### **<u>Configurer un Workflow GitHub Actions</u>**

Préalablement, on créé un nouveau fichier `.yml` dans le réperoire `.github/workflows/` nommé `azure-docker-image.yml` Ensuite on y insère les instructions `yaml` ci-dessous. Concrètement, on se connecte à l'**API Azure** avec la variable `secrets.AZURE_CREDENTIALS` puis on envoie l'image buildée au **Azure Container Registry** avec les variables `secrets.REGISTRY_LOGIN_SERVER`, `secrets.REGISTRY_USERNAME` et `secrets.REGISTRY_PASSWORD`. On effectue un build du Dockerfile avec le contenu de l'instruction `run`. Ensuite à l'aide des variables `secrets.RESOURCE_GROUP` et `secrets.REGISTRY_LOGIN_SERVER` on déploie l'image buildée dans une `Azure Container Instance`. On prend le soin de satisfaire certaines contraintes de configuration en spécifiant:
- `name: '20220505'`
- `location: 'france central'`
- `ports: 8081`
- `environment-variables: API_KEY=${{ secrets.API_KEY }}`.

**N.B:** La variable `secrets.API_KEY` contient en dissimulé le contenu de l'API Key utilisée pour requêter l'API de **OpenWeatherMap**.

```yml
on: [push]
name: Deploy docker image on Azure

jobs:
    build-and-deploy:
        runs-on: ubuntu-latest
        steps:
        # checkout the repo
        - name: 'Checkout GitHub Action'
          uses: actions/checkout@main
      
        # ======================= Déploiement sur Azure =======================
        - name: 'Login via Azure CLI'
          uses: azure/login@v1
          with:
              creds: ${{ secrets.AZURE_CREDENTIALS }}

        - name: 'Build and push image'
          uses: azure/docker-login@v1
          with:
              login-server: ${{ secrets.REGISTRY_LOGIN_SERVER }}
              username: ${{ secrets.REGISTRY_USERNAME }}
              password: ${{ secrets.REGISTRY_PASSWORD }}
        - run: |
              docker build . -t ${{ secrets.REGISTRY_LOGIN_SERVER }}/20220505:v1
              docker push ${{ secrets.REGISTRY_LOGIN_SERVER }}/20220505:v1

        - name: 'Deploy to Azure Container Instances'
          uses: 'azure/aci-deploy@v1'
          with:
                resource-group: ${{ secrets.RESOURCE_GROUP }}
                dns-name-label: devops-20220505
                image: ${{ secrets.REGISTRY_LOGIN_SERVER }}/20220505:v1
                registry-login-server: ${{ secrets.REGISTRY_LOGIN_SERVER }}
                registry-username: ${{ secrets.REGISTRY_USERNAME }}
                registry-password: ${{ secrets.REGISTRY_PASSWORD }}
                name: '20220505'
                location: 'france central'
                ports: 8081
                environment-variables: API_KEY=${{ secrets.API_KEY }}
```

Effectuer l'opération de `Start commit`. Retourner dans `Actions`, et suivre l'évolution du processus d'automatisation.

***
<br />

> ### **<u>Transformation du wrapper en API</u>**

Notre wrapper étant écrit en Python reste le même que celui utilisé dans le TP2. Voici son contenu pour se rafraîchir la mémoire:

```python
from os import environ
import requests
from fastapi import FastAPI

# ================ fastAPI setup ================

API_Key=environ.get("API_KEY")

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

Ce fichier reste similaire à celui du TP2. Son contenu est le suivant:

```txt
fastapi==0.95.1
uvicorn==0.22.0
requests==2.29.0
```
***
<br />

> ### **<u>*Dockerfile*</u>**

Le Dockerfile contient des instructions à exécutions séquentiels pour créer le container final. On distingue:

```dockerfile
FROM python:3.11
```
- Cette instruction permet de spécifier l'image Docker à partir de laquelle notre container sera construite (ici l'image `python:3.11`).

```dockerfile
WORKDIR /app
```
- Cette instruction spécifie le répertoire courant par défaut du container (ici `/app`).

```dockerfile
COPY weatherWraperAPI.py /app
COPY requirements.txt /app
```
- Cette instruction effectue une copie du fichier `weatherWraper.py` dans le répertoire courant par défaut du container. Idem pour le fichier `requirements.txt`

```dockerfile
RUN pip install --no-cache-dir -r requirements.txt
```

- Cette instruction exécute la commande d'installation des packages Python dans le fichier `requirements.txt`. Le paramètre `--no-cache-dir` permet de nettoyer les métadonnées en cache générées par la commande (utile pour libérer de l'espace mémoire).

```dockerfile
CMD ["uvicorn", "weatherWraperAPI:app", "--port", "8081", "--host", "0.0.0.0", "--reload"]
```
- Cette instruction exécute la commande `uvicorn weatherWraperAPI:app --port 8081 --host 0.0.0.0 --reload` qui démarre un serveur en background au port $8081$ et l'actualise en temps réel.

Voici le contenu du Dockerfile du TP2

```dockerfile
FROM python:3.11

WORKDIR /app

COPY weatherWraperAPI.py /app
COPY requirements.txt /app

RUN pip install --no-cache-dir -r requirements.txt

CMD ["uvicorn", "weatherWraperAPI:app", "--port", "8081", "--host", "0.0.0.0", "--reload"]
```

<br />

***
***
<br />

## **EXÉCUTION**
À chaque `push` sur le repository GitHub, le `Workflow GitHub Actions` automatise la construction et le déploiement des images Docker dans le DockerHub.

<br />

***
***
<br />

## **TESTS TECHNIQUES**

> ### **<u>Lint Errors</u>**
Le test des Lint errors est intégré au code de configuration `.yml` du `Workflow GitHub Actions`. Le code est le suivant:

```yml
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
L'image Docker s'exécute en container Docker dans une `Azure Container Instance` lié au ressources groupe **ADDA84-CTP**. 

Pour exécuter le projet, exécuter dans un terminal les commandes `curl` pour effectuer les appels APIs. Si l'on souhaite obtenir les informations pour des coordonnées géographiques spécifiques (`lat=5.902785, lon=102.7542`), on entre la commande suivante qui génère un résultat au format JSON:
```sh
> curl "devops-20220505.francecentral.azurecontainer.io:8081/?lat=5.902785&lon=102.754175"

[output]
{
    "coord": {
        "lon": 102.7542,
        "lat": 5.9028
    },
    "weather": [
        {
            "id": 804,
            "main": "Clouds",
            "description": "overcast clouds",
            "icon": "04d"
        }
    ],
    "base": "stations",
    "main": {
        "temp": 299.22,
        "feels_like": 299.22,
        "temp_min": 299.22,
        "temp_max": 299.22,
        "pressure": 1007,
        "humidity": 78,
        "sea_level": 1007,
        "grnd_level": 980
    },
    "visibility": 10000,
    "wind": {
        "speed": 2.11,
        "deg": 159,
        "gust": 2.25
    },
    "clouds": {
        "all": 100
    },
    "dt": 1682810347,
    "sys": {
        "country": "MY",
        "sunrise": 1682808993,
        "sunset": 1682853348
    },
    "timezone": 28800,
    "id": 1736405,
    "name": "Jertih",
    "cod": 200
}
```
<br />

***
***

<br />

## **AUTRES**
Aucune donnée sensible n'est stockée dans l'image ou dans le code source.

<br />

***
***

<br />

## **CRÉDITS**

<image src="https://frimpong-adotri-01.github.io/mywebsite/pictures/me.png" width=200 center>  

**AUTEUR :** ADOTRI Frimpong

**PROMO :** Big Data & Machine Learning (EFREI)

**PROFESSEUR :** DOMINGUES Vincent

**COPYRIGHT :** Mai 2023

***
***

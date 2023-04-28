# ========================== TP1 ==========================

#FROM python:3.11

#ARG LAT
#ENV LAT=$LAT
#ARG LONG
#ENV LONG=$LONG
#ARG API_KEY
#ENV API_KEY=$API_KEY

#WORKDIR /app

#COPY weatherWraper.py /app

#RUN pip install -r --no-cache-dir requests==2.29.0

#CMD ["sh", "-c", "python weatherWraper.py $LAT $LONG $API_KEY"]


# ========================== TP2 ==========================

FROM python:3.11

WORKDIR /app

COPY weatherWraperAPI.py /app
COPY requirements.txt /app

RUN pip install --no-cache-dir -r requirements.txt

CMD ["uvicorn", "weatherWraperAPI:app", "--port", "8081", "--host", "0.0.0.0", "--reload"]
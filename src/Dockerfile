FROM python:3.7

EXPOSE 5000

RUN mkdir -p /opt/star-wars-api
WORKDIR /opt/star-wars-api

ENV ACCESS_KEY=""
ENV SECRET_KEY=""

COPY ./ src/
COPY requirements.txt .

RUN chmod +x /opt/star-wars-api/src/scripts/entrypoint.sh
RUN pip install -r requirements.txt

ENTRYPOINT [ "/opt/star-wars-api/src/scripts/entrypoint.sh" ]

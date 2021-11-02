FROM python:3.7

EXPOSE 5000

RUN mkdir -p /opt/star-wars-api
WORKDIR /opt/star-wars-api

ENV ACCESS_KEY="AKIARCN4W35SKNZPZINW"
ENV SECRET_KEY="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"

COPY ./ src/
COPY requirements.txt .

RUN chmod +x /opt/star-wars-api/src/scripts/entrypoint.sh
RUN pip install -r requirements.txt

ENTRYPOINT [ "/opt/star-wars-api/src/scripts/entrypoint.sh" ]
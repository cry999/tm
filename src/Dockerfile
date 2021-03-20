FROM frederikp/python-poetry-alpine as poetry

WORKDIR /app
ADD pyproject.toml /app
RUN poetry export -f requirements.txt -o requirements.txt

FROM python:3.9-alpine as prd

WORKDIR /app
ADD . /app
COPY --from=poetry /app/requirements.txt /app
RUN apk add --no-cache \
    build-base \
    mariadb-connector-c-dev
RUN pip install -r requirements.txt
RUN ls

ENTRYPOINT [ "gunicorn", "myproject.wsgi:application", "-b", "0.0.0.0:8000" ]

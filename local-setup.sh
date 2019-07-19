#!/bin/bash
docker run -d --name postgres -e POSTGRES_PASSWORD=docker -e POSTGRES_USER=postgres -e POSTGRES_DB=mysite -d -p 5432:5432 -v postgres:/var/lib/postgresql/data postgres
python -m pip install -r requirements.txt
python manage.py migrate
python manage.py runserver

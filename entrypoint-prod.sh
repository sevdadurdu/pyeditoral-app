#!/bin/sh

python manage.py makemigrations
python manage.py migrate
python manage.py migrate --run-syncdb
gunicorn PyEditorial.wsgi:application --bind 0.0.0.0:8000


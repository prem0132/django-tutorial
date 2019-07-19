FROM python:3.7
MAINTAINER prem.it.rits@gmail.com
WORKDIR /usr/src/app
COPY requirements.txt .
RUN pip install -r requirements.txt
ADD . /usr/src/app
EXPOSE 8000
ENTRYPOINT [ "gunicorn", "mysite.wsgi:application", "-w", "2", "-b", ":8000", "--reload" ] 
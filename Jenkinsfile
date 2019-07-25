pipeline {
  agent {
    docker {
      args '-u root -v /var/run/docker.sock:/var/run/docker.sock'
      image 'premhashmap/python:build-agent'
    }
  }
  stages {
    stage('Installing deps') {
      steps {
        sh 'pip install -r requirements.txt'
      }
    }       
    stage('Launching Postgres') {
      steps {
        sh 'docker run -d --name $GIT_COMMIT -e POSTGRES_PASSWORD=docker -e POSTGRES_DB=mysite -d -p 5432 postgres'
      }
    } 
    stage('Running Tests') {
      steps {
        sh '''
        DATABASE_HOST=$(docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" $GIT_COMMIT)
        sed -i -e "s/DATABASE_HOST=localhost/DATABASE_HOST=$DATABASE_HOST/g" .env
        '''
        sh 'python manage.py test'
      }
    }         
    stage('Build Image') {
      steps {
        sh 'docker build -t premhashmap/django-demo-dbsetup -f Dockerfile-database-setup .'
        sh 'docker build -t premhashmap/django-demo .'
        sh 'docker build -t premhashmap/nginx:django-demo -f Dockerfile-nginx.'
      }
    }
    stage('Publish Image') {
      steps {
        withCredentials(bindings: [usernamePassword(credentialsId: 'dockerhubPWD', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
          sh 'docker login -u $USERNAME -p $PASSWORD'
        }

        sh 'docker push premhashmap/django-demo-dbsetup'
        sh 'docker push premhashmap/django-demo'
        sh 'docker push premhashmap/nginx:django-demo'
      }
    }
  }
  options {
    timeout(time: 2, unit: 'HOURS')
  }
  post {
    always {
      sh 'chmod -R 777 .'
      sh 'docker rm -f $GIT_COMMIT'
    }
  }  
}

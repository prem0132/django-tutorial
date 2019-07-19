pipeline {
  agent {
    docker {
      args '-u root -v /var/run/docker.sock:/var/run/docker.sock'
      image 'hashmapinc/python:build-agent'
    }
  }
  stages {
    stage('Run Tests') {
      steps {
        sh 'pip install -r requirements.txt'
        sh 'python manage.py test'
      }
    }
    stage('Build Image') {
      steps {
        sh 'ls -larth'
        sh 'docker build -t premhashmap/django-demo-dbsetup -f Dockerfile-database-setup .'
        sh 'docker build -t premhashmap/django-demo .'
      }
    }
    stage('Publish Image') {
      steps {
        withCredentials(bindings: [usernamePassword(credentialsId: 'dockerhubPWD', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
          sh 'docker login -u $USERNAME -p $PASSWORD'
        }

        sh 'docker push premhashmap/django-demo-dbsetup'
        sh 'docker push premhashmap/django-demo'
      }
    }
  }
  options {
    timeout(time: 2, unit: 'HOURS')
  }
}

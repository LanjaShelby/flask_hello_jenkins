pipeline {
  agent {
    docker {
      image 'python:3.10'
    }
  }

  stages {
    stage('Test Python') {
      steps {
        sh '''
          apt-get update && apt-get install -y python3-venv python3-distutils
          python3 -m venv venv
          . venv/bin/activate
          pip install -r requirements.txt
          python test.py
        '''
      }
    }

    stage('Build Docker Image') {
      steps {
        sh '''
          docker build -t flask_hello .
        '''
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        sh '''
          kubectl apply -f kubernetes/deployment.yaml
          kubectl apply -f kubernetes/service.yaml
        '''
      }
    }
  }
}

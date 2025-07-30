pipeline {
  agent any

  stages {
    stage('Test Python') {
      steps {
        sh '''
          pip3 install -r requirements.txt
          python3 test.py
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

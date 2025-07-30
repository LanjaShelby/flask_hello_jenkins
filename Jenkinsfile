pipeline {
  agent any

  stages {
    stage('Test Python') {
      steps {
        sh '''
          pip install -r requirements.txt
          python test.py
        '''
      }
    }

    stage('Build Docker Image') {
      steps {
        sh '''
          eval $(minikube docker-env)
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

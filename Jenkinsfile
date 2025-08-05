pipeline {
  agent any

  triggers {
    pollSCM('* * * * *')
  }

  environment {
    KUBECONFIG = '/var/lib/jenkins/.kube/config'
  }

  stages {
    stage('Test Python') {
      steps {
        sh '''
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
          docker build -t 192.168.49.1:4000/flask_hello .
          docker push 192.168.49.1:4000/flask_hello
        '''
      }
    }

    stage('Deploy to Minikube') {
      steps {
        sh '''
          kubectl apply -f kubernetes/deployment.yaml
          kubectl apply -f kubernetes/service.yaml
        '''
      }
    }
  }
}

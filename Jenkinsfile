pipeline {
    triggers {
        pollSCM('* * * * *')
    }
    
    agent {
        kubernetes {
            label 'jenkins-agent-my-app'
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    component: ci
spec:
  containers:
  - name: python
    image: python:3.9
    command:
    - cat
    tty: true
    
  - name: docker
    image: docker:latest
    command:
    - cat
    tty: true
    volumeMounts:
    - mountPath: /var/run/docker.sock
      name: docker-sock
      
  - name: kubectl
    image: bitnami/kubectl:latest
    command:
    - cat
    tty: true
      
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
"""
        }
    }
    
    stages {
        stage('Test Python') {
            steps {
                container('python') {
                    sh "pip install -r requirements.txt"
                    sh "python test.py"
                }
            }
        }
        
        stage('Build Image') {
            steps {
                container('docker') {
                    sh '''
                        # Construire et pousser vers le registry Kubernetes interne
                        docker build -t registry.jenkins.svc.cluster.local:5000/pythontest:latest .
                        docker push registry.jenkins.svc.cluster.local:5000/pythontest:latest
                    '''
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    sh '''
                        mkdir -p kubernetes
                        
                        cat > kubernetes/deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pythontest
  labels:
    app: pythontest
spec:
  selector:
    matchLabels:
      app: pythontest
  strategy:
    type: Recreate
  replicas: 1
  template:
    metadata:
      labels:
        app: pythontest
    spec:
      containers:
      - image: registry.jenkins.svc.cluster.local:5000/pythontest:latest
        name: pythontest
        ports:
        - containerPort: 5000
          name: microport
EOF

                        cat > kubernetes/service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: pythontest
  labels:
    app: pythontest
spec:
  ports:
  - port: 5000
    nodePort: 31000
  selector:
    app: pythontest
  type: NodePort
EOF

                        kubectl apply -f kubernetes/deployment.yaml
                        kubectl apply -f kubernetes/service.yaml
                        
                        # Vérifier
                        kubectl get deployments
                        kubectl get services
                        kubectl get pods
                    '''
                }
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline terminé'
        }
        success {
            echo 'Pipeline réussi !'
        }
        failure {
            echo 'Pipeline échoué'
        }
    }
}

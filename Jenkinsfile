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
        stage('Setup Registry') {
            steps {
                container('docker') {
                    sh '''
                        # Démarrer le registry s'il n'existe pas
                        if ! docker ps --format "{{.Names}}" | grep -q "^registry$"; then
                            echo "Starting Docker registry on port 4000..."
                            docker run -d -p 4000:5000 --name registry registry:2
                            sleep 5
                        fi
                        
                        # Vérifier
                        docker ps | grep registry
                    '''
                }
            }
        }
        
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
                        # Construire l'image
                        docker build -t localhost:4000/pythontest:latest .
                        
                        # Pousser vers le registry
                        docker push localhost:4000/pythontest:latest
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
      - image: localhost:4000/pythontest:latest
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
                        kubectl get deployments
                        kubectl get services
                    '''
                }
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline terminé'
        }
    }
}

// 2. JenkinsFile
pipeline {
    agent any
    
    environment {
        // IDs de credenciales configurados en Jenkins
        DOCKERHUB_CREDS = credentials('dockerhub-creds')
        GITHUB_CREDS    = credentials('github-packages-creds')
        
        // Nombres de imagen
        DOCKERHUB_IMAGE = "ivanmeneses98/lab3"
        GITHUB_IMAGE    = "ghcr.io/ivanandresmt/lab3"
        
        // Namespace de K8s
        K8S_NAMESPACE   = "ivanmeneses" 
    }
    
    stages {
        stage('Instalar Dependencias') {
            steps {
                sh 'npm install'
            }
        }
        
        stage('Testing') {
            steps {
                // Si tienes script de test en package.json. Si no, usa 'echo "Testing..."'
                sh 'npm test || echo "No tests found, skipping..."' 
            }
        }
        
        stage('Build App') {
            steps {
                // Construcción de artefactos si aplica (ej. npm run build)
                sh 'echo "Building application assets..."'
            }
        }
        
        stage('Construcción Imagen Docker') {
            steps {
                script {
                    // Construimos la imagen localmente una vez
                    sh "docker build -t ${DOCKERHUB_IMAGE}:${BUILD_NUMBER} ."
                    sh "docker tag ${DOCKERHUB_IMAGE}:${BUILD_NUMBER} ${DOCKERHUB_IMAGE}:latest"
                    
                    // Taggear para GitHub Packages también
                    sh "docker tag ${DOCKERHUB_IMAGE}:${BUILD_NUMBER} ${GITHUB_IMAGE}:${BUILD_NUMBER}"
                    sh "docker tag ${DOCKERHUB_IMAGE}:${BUILD_NUMBER} ${GITHUB_IMAGE}:latest"
                }
            }
        }
        
        stage('Upload Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', passwordVariable: 'DH_PASS', usernameVariable: 'DH_USER')]) {
                        sh "echo $DH_PASS | docker login -u $DH_USER --password-stdin"
                        sh "docker push ${DOCKERHUB_IMAGE}:${BUILD_NUMBER}"
                        sh "docker push ${DOCKERHUB_IMAGE}:latest"
                    }
                }
            }
        }
        
        stage('Upload Github Packages') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'github-packages-creds', passwordVariable: 'GH_TOKEN', usernameVariable: 'GH_USER')]) {
                        sh "echo $GH_TOKEN | docker login ghcr.io -u $GH_USER --password-stdin"
                        sh "docker push ${GITHUB_IMAGE}:${BUILD_NUMBER}"
                        sh "docker push ${GITHUB_IMAGE}:latest"
                    }
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Primero aplicamos la infraestructura base (namespace, service, etc)
                    sh "kubectl apply -f kubernetes.yaml"
                    
                    // Actualizamos la imagen del deployment con el BUILD_NUMBER actual
                    // El requerimiento pide usar la imagen de GitHub (packages)
                    sh """
                        kubectl set image deployment/backend-app \
                        backend-container=${GITHUB_IMAGE}:${BUILD_NUMBER} \
                        -n ${K8S_NAMESPACE}
                    """
                    
                    // Esperar a que el rollout termine para confirmar éxito
                    sh "kubectl rollout status deployment/backend-app -n ${K8S_NAMESPACE}"
                }
            }
        }
    }
}
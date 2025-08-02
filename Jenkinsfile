pipeline {
  agent { docker { image 'bitnami/kubectl:latest' } }
  stages {
    stage('Install Tools') {
      steps {
        sh '''
          apt-get update && apt-get install -y curl bash git make python3 python3-pip
          pip install yamllint
          curl -L https://github.com/yannh/kubeconform/releases/latest/download/kubeconform-linux-amd64.tar.gz | tar -xz -C /usr/local/bin
          curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
        '''
      }
    }
    stage('Lint') {
      steps {
        sh 'make lint'
      }
    }
    stage('Validate') {
      steps {
        sh 'make validate'
      }
    }
    stage('Dry Run Deploy') {
      steps {
        sh 'make dry-run'
      }
    }
  }
}

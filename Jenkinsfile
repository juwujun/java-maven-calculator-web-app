pipeline {
  agent {
    node{label 'docker'}
  }
  stages {
    stage('Build && Test') {
      agent{
        docker {
            image 'maven:3-alpine'
            label 'docker'
            args '-v maven-repo:/root/.m2'
        }
      }
      steps {
        sh 'mvn clean package -Dmaven.test.skip=true'
        sh "mvn test"
        sh "mvn integration-test"
        stash includes: 'target/*', name: 'BuildTarget'
      }
      post {
        always {
        	junit 'target/surefire-reports/*.xml'
        	tapdTestReport frameType: 'JUnit', onlyNewModified: true, reportPath: 'target/surefire-reports/*.xml'
        }
      }
    }
    stage('Nexus') {
        steps{
            dir("${WORKSPACE}"){
                sh label: '', script: "ls -la"
                unstash 'BuildTarget'
                nexusPublisher nexusInstanceId: 'DevOpsNexus', nexusRepositoryId: 'releases', packages: [[$class: 'MavenPackage', mavenAssetList: [[classifier: 'c', extension: 'war', filePath: 'target/calculator.war']], mavenCoordinate: [artifactId: 'calculator', groupId: 'cn.tapd.template', packaging: 'war', version: '${BUILD_NUMBER}']]]
            }
        }
    }
     stage('Code Scanner'){
        agent{
          docker{
            image 'sonarsource/sonar-scanner-cli'
            label 'docker'
            args '-v ${WORKSPACE}:/usr/src'
          }
        }
         steps {
               withSonarQubeEnv('DevOpsSonarQube') {
                    sh 'sonar-scanner -X -Dsonar.language=java -Dsonar.projectKey=$JOB_NAME -Dsonar.projectName=$JOB_NAME -Dsonar.projectVersion=$GIT_COMMIT -Dsonar.sources=src/ -Dsonar.sourceEncoding=UTF-8 -Dsonar.java.binaries=target/ -Dsonar.exclusions=src/test/**'
              }
            
        }

    }
    stage('Archive') {
      steps {
        archiveArtifacts(artifacts: 'target/*.war', fingerprint: true)
      }
    }
    stage('Package Docker') {
      steps {
        sh "docker build -t calculator:${env.BUILD_NUMBER} -t calculator:latest ."
      }
    }
    stage('Deploy'){
      steps {
        sh "docker-compose up --force-recreate -d"
      }
    }
     
     stage('Performance Test') {
      agent{
        docker {
            image 'maven:3-alpine'
            label 'docker'
            args '-v maven-repo:/root/.m2'
        }
      }
      steps {
        sh "mvn verify"
       }
    }

  }
  
}


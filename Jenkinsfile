pipeline {

  environment {
    dockerimagenamecex = "700080035327.dkr.ecr.us-east-1.amazonaws.com/lscp-mscex-poc-01:${BUILD_NUMBER}"
    dockerimagenameeureka = "700080035327.dkr.ecr.us-east-1.amazonaws.com/lscp-mseureka-poc-01:${BUILD_NUMBER}"
    dockerimagenameforex = "700080035327.dkr.ecr.us-east-1.amazonaws.com/lscp-msforex-poc:${BUILD_NUMBER}"
    AWS_ACCESS_KEY_ID     = credentials('accesskey')
    AWS_SECRET_ACCESS_KEY = credentials('secret_access_key')
    dockerImage = ""
    Dev_Emailid = ""
    //DevOps = "saurav.kumar@arisglobal.com, rohith.b@arisglobal.com"
  }

  agent any

  stages {
    stage("Checkout_LSCP_repo") {
        steps {
          sh 'mkdir -p devops'
          dir("devops"){
          checkout([$class: 'GitSCM', branches: [[name: '*/${LSCP_BRANCH}']], extensions: [],
          userRemoteConfigs: [[credentialsId: 'ms_ag_github_rb', url: 'https://github.com/ArisGlobal/lscp-cfw.git']]])
        }
      }
    }
           stage("Checkout_GIT_repo") {
              parallel {
                stage("MSCEX") {
                    when { expression { params.MS_GIT_REPO == "MS-CEX" } }
                    steps {
                      script {
					   sh 'mkdir -p ms'
                       dir("ms"){
        checkout([$class: 'GitSCM', branches: [[name: '*/${MSBRANCH}']], extensions: [],
        userRemoteConfigs: [[credentialsId: 'ms_ag_github_rb', url: 'https://github.com/rohithb-agi/MS-CEX.git']]])                           
                        //checkout([$class: 'GitSCM', branches: [[name: '*/${MSBRANCH}']], extensions: [], userRemoteConfigs: [[credentialsId: 'ms_ag_github_rb', url: 'https://github.com/rohithb-agi/devops-jenkins-currency-exchange-microservice.git']]]) 
                    }
                }
            }
        }
                stage("MSEUR") {
                    when { expression { params.MS_GIT_REPO == "MS-Eureka" } }
                    steps {
                      script {
					   sh 'mkdir -p ms'
                       dir("ms"){
        checkout([$class: 'GitSCM', branches: [[name: '*/${MSBRANCH}']], extensions: [],
        userRemoteConfigs: [[credentialsId: 'ms_ag_github_rb', url: 'https://github.com/rohithb-agi/MS-Eureka.git']]])                           
                       //checkout([$class: 'GitSCM', branches: [[name: '*/${MSBRANCH}']], extensions: [], userRemoteConfigs: [[credentialsId: 'ms_ag_github_rb', url: 'https://github.com/rohithb-agi/MS-Eureka.git']]])
                    }
                }
            }
        }
                stage("MSFOREX") {
                    when { expression { params.MS_GIT_REPO == "MS-Forex" } }
                    steps {
                     script {
					  sh 'mkdir -p ms'
                      dir("ms"){
        checkout([$class: 'GitSCM', branches: [[name: '*/${MSBRANCH}']], extensions: [],
        userRemoteConfigs: [[credentialsId: 'ms_ag_github_rb', url: 'https://github.com/rohithb-agi/MS-Forex.git']]])                           
                      //checkout([$class: 'GitSCM', branches: [[name: '*/${MSBRANCH}']], extensions: [], userRemoteConfigs: [[credentialsId: 'ms_ag_github_rb', url: 'https://github.com/rohithb-agi/MS-Forex.git']]])
                    }
                }
            }
        }
    }
}

  stage("Unit_Test") {
      steps {
        script {
          try {
            dir("ms"){
            echo "Running Unit Test"
            sh '''
            mvn test -DExpectedCurrencyValue="7500"
            '''
          }
            } catch (e) {
              currentBuild.Result = 'FAILURE'
              throw e
            }
          }
        }
        post {
          failure {
            sh 'return'
            emailext attachLog: true, body: "${JOB_NAME} - Unit Test case Failed - ${BUILD_NUMBER}", subject: 'Pipeline Failed', to: "${DevOps}"
          }
        }
      }
      
      stage("Build") {
        steps {
           dir("ms") {
    // some block
           sh "mvn package -DskipTests"
            }

        }
        /*post {
          failure {
            sh 'return'
            emailext attachLog: true, body: "${JOB_NAME} - Build Failed - ${BUILD_NUMBER}", subject: 'Pipeline Failed', to: "${DevOps}"
          }
        }*/
      }  
      stage("Docker_Image_Build") {
        steps {
            dir("ms") {
            script {
                switch(params.MS_GIT_REPO) {
                    case "MS-CEX": dockerImage = docker.build dockerimagenamecex ; break
                    case "MS-Eureka": dockerImage = docker.build dockerimagenameeureka ; break
                    case "MS-Forex": dockerImage = docker.build dockerimagenameforex ; break
                  }
               }    
            }
        } 
    }
    

} 
     
    post {
         always {
           echo "This command runs always"
           //mail bcc: '', body: 'TEST Sending SUCCESS email from jenkins', cc: '', from: '', replyTo: '', subject: 'SUCCESS BUILDING PROJECT $env.JOB_NAME', to: 'rohith.b@arisglobal.com'
           //emailext attachLog: true, body: "${JOB_NAME} - Pipeline Execution - ${BUILD_NUMBER}", subject: 'Pipeline Execution Done', to: "${DevOps}"
           //emailext attachLog: true, body: 'Unit Test case has failed', subject: 'FAILED', to "${DevOps}"
           cleanWs()
         }
         success {
           echo "this command executes only when all stages succeed"
           //mail bcc: '', body: 'TEST Sending SUCCESS email from jenkins', cc: '', from: '', replyTo: '', subject: 'SUCCESS BUILDING PROJECT $env.JOB_NAME', to: 'rohith.b@arisglobal.com'
           cleanWs()
         }
         failure {
           echo "this command executes when one of the stages failed"
           //mail bcc: '', body: 'TEST Sending FAILURE email from jenkins', cc: '', from: '', replyTo: '', subject: 'ERROR BUILDING PROJECT $env.JOB_NAME', to: 'rohith.b@arisglobal.com'
           cleanWs()
         }
       }
  }

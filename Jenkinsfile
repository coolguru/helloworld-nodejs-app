def gitCommit() {
    sh "git rev-parse HEAD > GIT_COMMIT"
    def gitCommit = readFile('GIT_COMMIT').trim()
    sh "rm -f GIT_COMMIT"
    return gitCommit
}

def gitEmail() {
    sh "git --no-pager show -s --format='%ae' ${gitCommit()} > GIT_EMAIL"
    def gitEmail = readFile('GIT_EMAIL').trim()
    sh "rm -f GIT_EMAIL"
    return gitEmail
}

def ipAddress() {
    sh "docker inspect test-container-${env.BUILD_NUMBER} | jq -r '.[0].NetworkSettings.IPAddress' > IP_ADDRESS"
    def ipAddress = readFile('IP_ADDRESS').trim()
    sh "rm -f IP_ADDRESS"
    return ipAddress
}


node {
    // Checkout source code from Git
    stage 'Checkout'
    checkout scm


    // Build Docker image
    stage 'Build'
    sh "docker build -t quay.io/valassis/helloworld-nodejs-app:${gitCommit()} ."


    // Test Docker image
    //stage 'Test'
    //sh "docker run -d --name=test-container-${env.BUILD_NUMBER} quay.io/valassis/helloworld-nodejs-app:${gitCommit()}"
    //sh "docker run mesosphere/linkchecker linkchecker --no-warnings http://${ipAddress()}:4000/"


    // Log in and push image to quay.io
    stage 'Publish'
    if (env.BRANCH_NAME == 'master') {
      sh "ln -sf /mnt/mesos/sandbox/jenkins-config.json /root/.dockercfg"
      sh "docker push quay.io/valassis/helloworld-nodejs-app:${gitCommit()}"
    }

    // Deploy
    stage 'Deploy'
    if (env.BRANCH_NAME == 'master') {
      marathon(
          url: 'http://docker-master.plumlabs.us/service/dev/v2/apps',
          forceUpdate: false,
          credentialsId: 'dcos_token',
          filename: 'marathon.json',
          appid: 'helloworld-nodejs-app',
          docker: "quay.io/valassis/helloworld-nodejs-app:${gitCommit()}".toString(),
          labels: ['lastChangedBy': "${gitEmail()}".toString()]
      )
    }

    // Clean up
    stage 'Clean'
}

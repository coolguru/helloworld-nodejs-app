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
    sh "docker build -t gurulearningxyz/helloworld-nodejs-app:${gitCommit()} ."


    // Test Docker image
    //stage 'Test'
    //sh "docker run -d --name=test-container-${env.BUILD_NUMBER} gurulearningxyz/helloworld-nodejs-app:${gitCommit()}"
    //sh "docker run mesosphere/linkchecker linkchecker --no-warnings http://${ipAddress()}:4000/"


    // Log in and push image to Docker Hub
    stage 'Publish'
    withCredentials(
        [[
            $class: 'UsernamePasswordMultiBinding',
            credentialsId: 'docker-hub-credentials',
            passwordVariable: 'DOCKER_HUB_PASSWORD',
            usernameVariable: 'DOCKER_HUB_USERNAME'
        ]]
    ) {
        sh "docker login -u ${env.DOCKER_HUB_USERNAME} -p ${env.DOCKER_HUB_PASSWORD} -e demo@mesosphere.com"
        sh "docker push gurulearningxyz/helloworld-nodejs-app:${gitCommit()}"
    }


    // Deploy
    stage 'Deploy'
    if (env.BRANCH_NAME == 'master') {
      marathon(
          url: 'http://marathon.mesos:8080',
          forceUpdate: false,
          credentialsId: 'dcos-token',
          filename: 'marathon.json',
          appid: 'helloworld-nodejs-app',
          docker: "gurulearningxyz/helloworld-nodejs-app:${gitCommit()}".toString(),
          labels: ['lastChangedBy': "${gitEmail()}".toString()]
      )
    }

    // Clean up
    stage 'Clean'
}

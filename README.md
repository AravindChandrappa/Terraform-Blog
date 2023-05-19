Steps to perform:
-----------------------

1. Launch ubunt machine in aws with ubuntu LTS 22.04 free tier eligble 
   
  --> install java sudo apt-get install openjdk-11-jdk
  --> add jenkins packages and install jenkins 

    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
    /usr/share/keyrings/jenkins-keyring.asc > /dev/null

    echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null

    sudo apt-get update
    sudo apt-get install fontconfig openjdk-11-jre
    sudo apt-get install jenkins

    once install access jenkins through public ip of ec2 before it edit security group inboind rules and add 8080 and 0.0.0.0 anywhere and save it

   ex: http://3.16.91.190:8080/

    ui showes some path to get initial password cat it in server and proceed further with install suggested plugins

2. add web hook in git repository like http://3.16.91.190:8080/github-webhook/

3. pipeline script 


#!/bin/bash

#Update the system packages
sudo apt update -y

#Download and configure the Jenkins repository
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

#Upgrade the system packages
sudo apt upgrade -y

#Install Java 11 using Amazon Corretto
sudo apt install -y openjdk-11-jdk

#Install Jenkins
sudo apt install -y jenkins

#Enable and start the Jenkins service
sudo systemctl enable jenkins
sudo systemctl start jenkins

#Install Docker
sudo apt install -y docker.io

#Add the current user to the 'docker' group to use Docker without sudo
sudo usermod -aG docker $USER

#Enable and start the Docker service
sudo systemctl enable docker
sudo systemctl start docker

#Check the status of Jenkins service
sudo systemctl status jenkins

#Check the status of Docker service
sudo systemctl status docker

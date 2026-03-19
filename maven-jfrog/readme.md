# Maven and JFrog CI CD Integration Steps

A quick reference guide for integrating Maven, JFrog Artifactory, and Azure DevOps for building and deploying Spring Boot applications.

### Tech Stack
![Java 17](https://img.shields.io/badge/Java_17-orange?style=for-the-badge&logo=java&logoColor=white)
![Maven](https://img.shields.io/badge/Maven-C71A36?style=for-the-badge&logo=apachemaven&logoColor=white)
![Azure DevOps](https://img.shields.io/badge/Azure_DevOps-0078D7?style=for-the-badge&logo=azuredevops&logoColor=white)
![JFrog Artifactory](https://img.shields.io/badge/JFrog_Artifactory-41BF46?style=for-the-badge&logo=jfrog&logoColor=white)
![Spring Boot](https://img.shields.io/badge/Spring_Boot-6DB33F?style=for-the-badge&logo=springboot&logoColor=white)
![Amazon EC2 Ubuntu](https://img.shields.io/badge/Amazon_EC2_Ubuntu-FF9900?style=for-the-badge&logo=amazonec2&logoColor=white)

### Core Concepts
* **Compilation Process:** Source code compiles from .java to .class files.
* **Artifacts:** Packaged executable formats like .jar, .war, or .ear.
* **Maven Lifecycle:** Validate, Compile, Package, Install, Deploy.

### Quick Reference and Commands
#### 1. Environment Setup
Update packages and install Java 17
```bash
sudo apt update && sudo apt install -y openjdk-17-jdk
```
Install Maven
```bash
sudo apt install -y maven
```

#### 2. Source Code Management
Clone Spring Petclinic application
```bash
git clone https://github.com/spring-projects/spring-petclinic.git
```
Add Azure DevOps remote repository
```bash
git remote add origin https://mohdrayees3214@dev.azure.com/mohdrayees3214/maven-jfrog/_git/my-maven-proj
```
Push code to master branch
```bash
git push origin master
```
Generate SSH Key on EC2 for authentication
```bash
ssh-keygen -t rsa
```

#### 3. Maven Build Operations
Check project file and install dependencies
```bash
mvn validate
```
Compile source code
```bash
mvn compile
```
Create executable package
```bash
mvn package
```
Run the application
```bash
java -jar target/*.jar
```
Clean previous builds
```bash
mvn clean
```
Clean and package at the same time
```bash
mvn clean package
```

#### 4. Version Control
Update application version in project file
```bash
mvn versions:set -DnewVersion=1.0.0
```

#### 5. JFrog Artifactory Installation
Download JFrog Debian installer
```bash
wget -O jfrog-deb-installer.tar.gz "https://releases.jfrog.io/artifactory/jfrog-prox/org/artifactory/pro/deb/jfrog-platform-trial-prox/[RELEASE]/jfrog-platform-trial-prox-[RELEASE]-deb.tar.gz"
```
Extract archive
```bash
tar -zxvf jfrog-deb-installer.tar.gz
```
Navigate to extracted folder
```bash
cd jfrog-platform-trial-prox-7.133.12-deb/
```
Install JFrog dependencies
```bash
sudo apt install -y jq && apt install -y net-tools
```
Run installation script
```bash
sudo ./install.sh
```
Start Artifactory and Xray services
```bash
sudo systemctl start artifactory.service
sudo systemctl start xray.service
```

#### 6. JFrog Configuration and Maven Deployment
Configure settings xml in EC2 machine under .m2 directory
Update pom xml to include distributionManagement block
Clean, install, and deploy artifact to JFrog
```bash
mvn clean install && mvn deploy
```

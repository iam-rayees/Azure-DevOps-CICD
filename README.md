# DevSecOps Pipeline — Spring Boot on Azure DevOps

End-to-end CI/CD pipeline for a Spring Boot application featuring SAST, container security scanning, DAST, and multi-cloud artifact delivery wired into a single Azure DevOps pipeline.

---

## Tech Stack
![Java 17](https://img.shields.io/badge/Java_17-007396?style=for-the-badge&logo=openjdk&logoColor=white)
![Maven](https://img.shields.io/badge/Maven-C71A36?style=for-the-badge&logo=apachemaven&logoColor=white)
![Azure DevOps Repos](https://img.shields.io/badge/Azure_Repos-0078D7?style=for-the-badge&logo=azuredevops&logoColor=white)
![Azure Pipelines](https://img.shields.io/badge/Azure_Pipelines-2560E0?style=for-the-badge&logo=azuredevops&logoColor=white)
![SonarQube 9.7](https://img.shields.io/badge/SonarQube_9.7-4E9BCD?style=for-the-badge&logo=sonarqube&logoColor=white)
![JFrog Artifactory](https://img.shields.io/badge/JFrog_Artifactory-41BF47?style=for-the-badge&logo=jfrog&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Trivy](https://img.shields.io/badge/Trivy-1904DA?style=for-the-badge&logo=aquasecurity&logoColor=white)
![Azure Container Registry](https://img.shields.io/badge/Azure_ACR-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Docker Hub](https://img.shields.io/badge/Docker_Hub-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Azure Container Instances](https://img.shields.io/badge/Azure_Container_Instances-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![OWASP ZAP](https://img.shields.io/badge/OWASP_ZAP-000000?style=for-the-badge&logo=owasp&logoColor=white)
![Azure Blob Storage](https://img.shields.io/badge/Azure_Blob_Storage-0089D6?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Amazon S3](https://img.shields.io/badge/Amazon_S3-569A31?style=for-the-badge&logo=amazons3&logoColor=white)
![AWS EC2](https://img.shields.io/badge/AWS_EC2-FF9900?style=for-the-badge&logo=amazonec2&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-5C4EE5?style=for-the-badge&logo=terraform&logoColor=white)
![Packer](https://img.shields.io/badge/Packer-02A8EF?style=for-the-badge&logo=packer&logoColor=white)
![Ansible](https://img.shields.io/badge/Ansible-EE0000?style=for-the-badge&logo=ansible&logoColor=white)

| Layer | Tool |
|---|---|
| Language | Java 17 + Maven |
| SCM | Azure DevOps Repos |
| CI/CD | Azure DevOps Pipelines |
| SAST | SonarQube 9.7 |
| Artifact registry | JFrog Artifactory |
| Container build | Docker |
| Container scan | Trivy |
| Container registry | Azure ACR + Docker Hub |
| Container runtime | Azure Container Instances |
| DAST | OWASP ZAP |
| Artifact storage | Azure Blob + AWS S3 |
| Deployment targets | AWS EC2 Staging + Prod |
| IaC tools on agent | Terraform, Packer, Ansible |

---

## Pipeline Architecture

```
Git Push (development / uat / production)
         |
         v
+-------------------------------------+
|  Stage 1: Agent health check        |  <- dev + prod
|  Terraform, Packer, Ansible, Trivy  |
+----------------+--------------------+
                 |
                 v
+-------------------------------------+
|  Stage 2: SAST with SonarQube       |  <- dev + prod
|  Maven + sonar:sonar, quality gate  |
+----------------+--------------------+
                 |
                 v
+-------------------------------------+
|  Stage 3: Maven build + JFrog       |  <- dev + prod
|  Version, package, deploy artifact  |
+--------+----------------------------+
         |
   +-----+------+
   |            |
isDev        isProd
   |            |
   v            v
+----------+   +--------------------+
| 4: Copy  |   | Deploy to PROD     |
| Blob + S3|   | AWS EC2 VM         |
+----------+   +--------------------+
   |
   v
+---------------------------+
| 5: Docker build           |
| Trivy scan (LOW to CRIT)  |
+---------------------------+
   |
   v
+---------------------------+
| 6: Push image             |
| Azure ACR + Docker Hub    |
+---------------------------+
   |
   v
+---------------------------+
| 7: Deploy to Azure ACI    |
+---------------------------+
   |
   v
+---------------------------+
| 8: Deploy to Staging VM   |
| Stop/start JAR on AWS EC2 |
+---------------------------+
   |
   v
+---------------------------+
| 9: DAST with OWASP ZAP    |
| Baseline scan on staging  |
+---------------------------+
```

---

## Prerequisites

### Agent setup

```bash
sudo apt update && apt install -y openjdk-17-jdk maven
curl https://get.docker.com | bash
usermod -a -G docker adminRay

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip && sudo ./aws/install

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

cd /usr/local/bin
wget https://releases.hashicorp.com/terraform/1.10.3/terraform_1.10.3_linux_amd64.zip && unzip *.zip
wget https://releases.hashicorp.com/packer/1.11.2/packer_1.11.2_linux_amd64.zip && unzip *.zip

sudo add-apt-repository --yes --update ppa:ansible/ansible && sudo apt install ansible

wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | \
  sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | \
  sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update && sudo apt-get install trivy
```

### Register the ADO agent

```bash
tar zxvf vsts-agent-linux-x64-4.270.0.tar.gz
./config.sh
sudo ./svc.sh install adminRay
sudo ./svc.sh start
```

Pool name: `AzureAgentPool`, Agent name: `ProdADO`

### SonarQube

SonarQube runs on a dedicated PostgreSQL 15 instance on port 5433.

```bash
sudo apt install postgresql-15 -y
psql -p 5433 -U postgres -c "CREATE USER sonar WITH ENCRYPTED PASSWORD 'your_password';"
psql -p 5433 -U postgres -c "CREATE DATABASE sonarqube OWNER sonar;"

cd /opt
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.7.1.62043.zip
sudo unzip sonarqube-9.7.1.62043.zip && sudo mv sonarqube-9.7.1.62043 sonarqube
sudo systemctl start sonar && sudo systemctl enable sonar
```

Access at `http://<server>:9000`. Default login is `admin / admin`.

### JFrog Artifactory

```bash
cd /usr/local/bin
wget -O jfrog-deb-installer.tar.gz \
  "https://releases.jfrog.io/artifactory/jfrog-prox/org/artifactory/pro/deb/jfrog-platform-trial-prox/[RELEASE]/jfrog-platform-trial-prox-[RELEASE]-deb.tar.gz"
tar -xvzf jfrog-deb-installer.tar.gz
cd jfrog-platform-trial-pro* && sudo ./install.sh
sudo systemctl start artifactory.service
sudo systemctl start xray.service
```

Access at `http://<server>:8082`. A trial license is required on first setup.

---

## Dockerfile

```dockerfile
FROM openjdk:17-jdk
EXPOSE 8080
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

---

## Maven Quick Reference

```bash
mvn validate                          # check pom.xml and dependencies
mvn compile                           # compile source to .class files
mvn package                           # produce the .jar artifact
mvn clean package install             # full local build
mvn deploy                            # push artifact to JFrog
mvn versions:set -DnewVersion=1.0.0   # update version in pom.xml
java -jar target/*.jar                # run the application locally on port 8080
```

---

## Security Stages

| Stage | Tool | Purpose |
|---|---|---|
| SAST | SonarQube | Code quality, bugs, security hotspots |
| Container scan | Trivy | OS and library CVEs from LOW to CRITICAL |
| DAST | OWASP ZAP | Runtime web vulnerability baseline scan |

Manual SonarQube scan from EC2:

```bash
mvn clean verify sonar:sonar \
  -Dsonar.projectKey=Prod_ADO \
  -Dsonar.host.url=http://sonarqube.yourdomain.com:9000 \
  -Dsonar.login=<your_token>
```

Manual Trivy scan:

```bash
trivy image --severity HIGH,CRITICAL \
  --format template --template "@template/junit.tpl" \
  -o report.xml yourimage:tag
```

---

## Branch Strategy

| Branch | Stages triggered |
|---|---|
| development | All stages 1 through 9, full dev and security pipeline |
| production | Stages 1 through 3 plus prod deployment only |
| uat | Stages 1 through 3, UAT deployment stages planned |
| feature/* | Excluded from all triggers |

---

## ADO Variables Required

Store these as secret pipeline variables or link them to Azure Key Vault.

| Variable | Used in |
|---|---|
| STORAGE_ACCOUNT_KEY | Azure Blob upload |
| acrpassword | ACR login and ACI deployment |
| settings.xml | Secure file holding JFrog Maven credentials |

---

## Repo Structure

```
azure-pipelines.yml       main pipeline with all stages
Dockerfile                container image definition
template/
    junit.tpl             Trivy JUnit report template
pom.xml                   Maven project descriptor
src/                      Spring Boot application source
```

---

Built with Azure DevOps, AWS, JFrog Artifactory, SonarQube, Trivy and OWASP ZAP.

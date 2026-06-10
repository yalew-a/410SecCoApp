# CheckIP Deployment Guide:

## Step 1: Install required software and repo

Install required software:

- Google Cloud SDK
- Terraform CLI
- Docker

Clone the repo to your local machine:

- git clone https://github.com/yalew-a/410SecCoApp.git

---

## Step 2: Auth with GCP and set project

Run these commands in the terminal to authenticate with GCP from your local machine:

- gcloud auth login
- gcloud config set project "GCP_PROJECT_ID"

---

## Step 3: Enable required APIs

Run this command to enable to required APIs:

_gcloud services enable \\
&emsp;compute.googleapis.com \\
&emsp;servicenetworking.googleapis.com \\
&emsp;sqladmin.googleapis.com \\
&emsp;secretmanager.googleapis.com \\
&emsp;artifactregistry.googleapis.com \\
&emsp;run.googleapis.com_

---

## Step 4: Configure the infrastructure variables file

run this command to change directory into terraform/infrastructure:

- cd terraform/infrastructure

Create the terraform.tfvars file and add these lines with the actual values:

- _project_id = "GCP_PROJECT_ID"
  region = "us-central1"
  vt_api_key_value = "your_actual_virustotal_api_key_here"
  ipdb_api_key_value = "your_actual_abuseipdb_api_key_here"
  db_user_value = "checkip_db_admin"
  db_pass_value = "create_a_strong_database_password_here"
  db_name_value = "checkip"
  instance_connection_name_value = "YOUR_PROJECT_ID:us-central1:checkip-mysql"
  app_auth_user = "app_admin_username"
  app_auth_pass = "create_a_strong_web_login_password_here"_

---

## Step 5: Deploy the infrastructure

run these commands in this order and review:

- _terraform init_
- _teraform plan_
- _terraform apply_

Type "yes" when prompted to deploy the infrastructure

---

## Step 6: Configure the app variables file

Cd into the terraform/app directory

- _cd terraform/app_

Create the terraform.tfvars and add these lines:

- _project_id = "GCP_PROJECT_ID"
  region = "us-central1"_

---

## Step 7: Deploy the app infrastructure

run these commands in this order and review:

- _terraform init_
- _teraform plan_
- _terraform apply_

## Step 8: Deploy to cloud run VIA CI/CD pipeline

To deploy the app to Cloud Run via the deploy-cloudrun workflow

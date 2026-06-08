# Captsone Project Milestones

---

---

## CI/CD Pipeline

Assigned to: Yalew (_yalew-a_)

### Tasks:

- OIDC configured for team on GitHub repo\*
- Complete terraform-plan.yml
- Set up code scanning
  - Complete dast-scan.yml
  - Complete scan.yml
- Complete deploy-cloudrun.yml
- Add Secrets to GitHub secrets and Secret Manager

---

## GCP & Terraform

Assigned to: Getahun (_Glode968_)

### Tasks:

- Set up GCP project
  - Add group members and grant Yalew access to edit IAM / Andrea access to view & audit IAM
- \*Add WIF_PROVIDER, SA_EMAIL, TF_VAR_PROJECT_ID to GitHub Variables.
- Wrote terraform code in **terraform/infrastrcture** (Set up infrastructure), **terraform/infrastrcture/modules/network** (set up VPC), and **terraform/app** (set up Cloud Run) to set up infrastructure on GCP
- Set up CloudSQL MySQL database
- Ensure backend and front end work together

---

# Security

Assigned to: Andrea (_andreagalfaro_)

### Tasks:

- Review/audit IAM policies
- Review security scans/PRs
- Make template for deployement guide (Each member will contribute)
- Write security section of README (Write about what security practices we use, for example: Secret Manager and CSP for flask app)
- Lead final compliance check

---

# Frontend/Flask app

Assigned to: Jaiden (_JaidenKemara_)

### Tasks:

- Create flask app that has:
  - Sign in screen
  - DB access/saves to DB
- Create HTML pages for flask to render
- create requirements.txt
- Ensure apps functionality post deployment
- Ensure backend and front end work together

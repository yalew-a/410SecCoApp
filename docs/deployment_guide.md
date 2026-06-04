# Write documentation on deployment

### Roles & Responsibilites

- Project lead - creates/owns architecture diagram, team decisions, manages GitHub repo/branch protection, and runs stand-ups. 

- Backend Engineer - manages Cloud Run/Cloud SQL Terraform config, backend API, app logic

- Frontend Engineer - creates the user interface, intergrates backend API, handles static/assets/UI testing.

- DevSecOps Engineer - integrates SAST/Container scanning, manages IAM/Secret Manager, and owns the CI/CD pipeline in Github Actions.

- Security Reviewer - audits IAM policies, as well as reviewing PRs specifically for security issues, write security section in README, leads final compliance check.

### Deployment Guide

- Company One-Pager - Filling Document that describes the company name, it's mission and actions, team roles w/ names, GitHub usernames, and what will be implemented.

- Create a new GitHub repo for the project, ensuring it's public.

- Add Branch protection to main, additionally add all team members as collaborators.

- Add your variables - WIF_PROVIDER, SA_EMAIL, TF_VAR_PROJECT_ID

- Create a new GCP project, add all team members and grant specific IAM access for each team members respective role.

- Create architecture diagram to show the Cloud Run, Cloud SQL, VPC, Secret Manager, Artifact Registry, and OIDC.

- Add your README file.

- Create your terraform-plan to deploy the GCP.

- Add your terraform folder structure. terraform/infrastructure/ & terraform/app/, (both folders will have main.tf, variables.tf, and outputs.tf)

- Input your code to each file necessary.




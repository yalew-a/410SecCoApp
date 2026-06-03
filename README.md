# 410SecCoApp (CheckIP)

## CIS 410 Capstone Project

### Company

410 Security Co.

### Project Description

CheckIP is a web application designed for Security Operations Center (SOC) analysts and cybersecurity professionals. The application allows users to investigate IP addresses by gathering reputation information from multiple threat intelligence sources in one place.

### Features

- Check the reputation of a single IP address
- Upload a file containing multiple IP addresses
- View threat intelligence results from VirusTotal and AbuseIPDB
- Perform WHOIS lookups
- Store selected IP address in the Cloud SQL database
- User authentication

### Team Members

- Project Lead / Frontend Engineer: Jaiden Jongjitirat (JaidenKemara)
- Backend Engineer: Getahun Lode (Glode968)
- DevSecOps Engineer: Yalew Wakjira (yalew-a)
- Security Reviewer: Andrea G. Alfaro (andreagalfaro)

### Technology Stack

- Python + Flask
- Docker
- Terraform
- GitHub Actions
- Google Cloud Platform (GCP)
- Cloud Run
- Cloud SQL

### Security Controls

- Branch protection enabled
- Pull request approval required
- GitHub Actions CI/CD pipeline
- IAM role-based access control
- Secret management using GitHub Secrets and Secrets Manager (GCP)
- Security/Vulnerability scanning (SNYK - SAST, SCA, Container scan)
- DAST Scan (OWASP ZAP)

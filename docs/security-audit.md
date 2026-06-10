## Security Auditing
- Branch control is enabled.
- Each pull requests requires approval and review by Security Reviewer, which is then merged by Project Lead.
- Github Secrets and GCP's Secrets Manager is used for secrets management.
- Scanning has been completed for vulnerabilites/security, all clear, and no vulnerabilities displayed.
- Security review #1 is set for security scans + fixes to be made. (AS OF 6/07/26, vulnerabilities have now been patched)

## IAM Policies:
- CIS 410 Deployment Service Account	
- Role:
- Compute Network Admin
- Storage Admin
- Viewer

- Should be:
- Cloud Run Admin
- Cloud SQL Admin
- Storage Admin

- Why: Owns the automated CI/CD pipeline deployments; needs full admin rights to modify Cloud Run containers, Cloud SQL instances, and Storage buckets during GitHub Actions workflows.


- Getahun Lode - Backend Engineer
- Role:
- Owner

- Should be:
- Owner
- Cloud SQL Admin

- Why: Owner keeps privileges as the group project creator- requires Cloud SQL Admin to write, test, and execute the backend database Terraform configurations.


- Jaiden Jongjitirat - Project Lead & Frontend Engineer
- Role:
- Browser
- Cloud SQL Admin
- Database Center Admin
- Storage Bucket Viewer (Beta)
- Storage Object Viewer

- Should be:
- Browser
- Storage Object Viewer
- Storage Bucket Viewer (Beta)
- Cloud SQL Viewer

- Why: Manages the frontend assets and hosting environment; needs Storage Bucket and Object viewer roles to access static files while keeping database administration rights securely restricted.


- Yalew Wakjira - DevSecOps
- Role:
- Browser
- Viewer

- Should be:
- Project IAM Admin
- Secret Manager Admin
- Security Admin
- Artifact Registry Reader

- Why: Upgrading from Viewer; requires IAM and Secret Manager administration to manage team permissions, protect API keys, and run pipeline security scans.


- Andrea G Alfaro - Security Reviewer
- Role:
- Security Auditor
- Security Reviewer

- Why: Configured correctly- holds read-only security access to audit IAM policies and lead final compliance checks without the risk of altering infrastructure.
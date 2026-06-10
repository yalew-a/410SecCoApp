# Deployment Guide:

## Notes:

## Component Reference Index: Tech Stack Blueprint

- Frontend: HTML and CSS
- Backend / API: Python Flask integrated with VirusTotal & AbuseIPDB APIs
- Database: Cloud SQL (MySQL)
- Container Registry: Artifact Registry
- Compute / Hosting: Cloud Run
- Infrastructure as Code: Terraform
- CI/CD: GitHub Actions
- Security Scanning: Snyk (SAST + SCA + container scanning)

## Documentation & Manuals

- README.md (Root): Contains the Company One-Pager (company name, mission, and actions), setup instructions, team roles with names, GitHub usernames, implementation goals, and the dedicated security section.
- docs/architecture.md - architecture.png: The architecture diagram and detailed component descriptions.
- docs/deployment-guide.md: This step-by-step technical manual for onboarding new team members.
- INFRASTRUCTURE_README.md: Configuration instructions for building the core network and database foundations.
- APP_README.MD: Deployment steps for provisioning Google Cloud Run hosting for the app container.

## Configuration & Infrastructure Code Files

- main.tf: The core execution file containing instructions to build cloud resources.
- variables.tf: The input configuration file defining variables passed into your scripts to avoid hardcoded values.
- outputs.tf: The handover file that extracts and transfers critical resource details (like database IPs) after a build finishes.

## 1. Repository and Administrative Setup
- The initialization begins with environment administrative setup led by the Project Lead and Project Owner.

- Company One-Pager: The team compiles the mandatory filling document in the root README.md containing the company name, mission, actions, team roles mapped to real names, GitHub usernames, and implementation scope.
- GitHub Creation: Create a new public GitHub repository for the project.
- Task Assignment: The Project Lead creates GitHub Issues for every single assignment and assigns them directly to team members to establish accountability.
- Branch Protection: Configure branch protection rules on the main branch to prevent unreviewed overrides, and adds all team members as explicit collaborators to the repository.
- GCP Project Setup: Create a new standalone GCP project. Add all team members to the project, granting specific, granular IAM access matching each team member's respective operational role to enforce segregation of duties.

## 2. Code Base and Container Blueprinting
- Development starts on local machine with division of work across engineering paths.

- Frontend Execution: The Frontend Engineer creates the web UI using HTML and CSS (app/templates/login.html and checkip.html), organizes design assets (app/static/css and js), connects the user interface to the backend API, and performs UI validation.
- Backend Execution: The Backend Engineer starts writing the API endpoints, models, and application logic using Python Flask. This backend handles the core functions and communicates with the external VirusTotal and AbuseIPDB APIs. Dependencies are saved to app/requirements.txt.
- Secret Strategy: The Security Reviewer audits the architecture to ensure zero hardcoded credentials exist in the source files. The DevSecOps Engineer configures Secret Manager to handle all runtime credentials (such as database credentials and external API keys), eliminating standard hardcoded strings from code or GitHub Secrets.
- Container Design: The Backend Engineer writes the root Dockerfile defining how to compile the production environment. A .dockerignore file and .gitignore file are added to filter out development clutter, local state caches like .terraform.lock.hcl, and sensitive deployment maps like tfplan.binary.

## 3. Identity and Cloud Access Setup
- Before automating, bridging GitHub to GCP securely using OpenID Connect (OIDC) and Workload Identity Federation (WIF) has to occur first.

- GCP Security Setup: The GCP Project Owner configures the identity setup script, passing the team repo name into the attributes condition. The DevSecOps Engineer manages this process to establish a strict least-privilege IAM configuration where pipeline service accounts have only the required roles documented for the run.
- Value Collection: Collect the resulting string outputs for the identity provider and service account email.
- GitHub Variable Configuration: The GitHub Repository Owner configures the repository and adds three specific Actions variables under Settings -> Secrets and variables -> Actions -> Variables tab: WIF_PROVIDER, SA_EMAIL, and TF_VAR_PROJECT_ID. This allows GitHub to log into the cloud project safely without static passwords.

## 4. Manual Infrastructure Initialization
- Before running the automated app pipeline, the cloud environment must exist.

- Execution: The DevSecOps Engineer manually runs the configurations inside terraform/infrastructure/ a single time.
- Impact: This step executes main.tf to build the core foundation components: the isolated Virtual Private Cloud (VPC), the secure Cloud SQL (MySQL) database instance, Secret Manager for credentials, and IAM identity access boundaries.
- Verification: The Security Reviewer verifies that terraform/infrastructure/ applied successfully reflects VPC, Cloud SQL, and Secret Manager services inside the GCP Console.
- Handover: The resulting values are processed by outputs.tf and stored securely to allow subsequent application workflows to bind to this network.

## 5. Pipeline Launch and Static Analysis Verification
- The DevSecOps Engineer creates and commits the initial GitHub Actions pipeline configuration. Pushing the application updates to the main branch triggers the first two automation scripts in parallel:

- Snyk SAST & SCA Scan (scan.yml): This workflow runs integrated Snyk SAST (Static Application Security Testing) and SCA (Software Composition Analysis) scans on the codebase. It inspects the Flask source files (app.py), package dependencies (requirements.txt), and infrastructure files for software vulnerabilities or accidental secrets before deployment. The goal is zero critical vulnerabilities in the final submission.
- Infrastructure Evaluation (terraform-plan.yml): Uses the OIDC log-in variables to connect to GCP, evaluates the terraform/app/ target files against the active state, and outputs a compiled change blueprint to a file named tfplan.binary.
- Check: This workflow must finish successfully and show green in GitHub before proceeding further.

## 6. Automated Pipeline Provisioning and Application Launch
- Once pre-flight checks are verified, the core automated deployment workflow (deploy-cloudrun.yml) activates, stringing the code and hosting layers together:

- Snyk Container Scan: Before the application image is uploaded, GitHub Actions runs an integrated Snyk container scan directly against the built image to intercept operating system dependencies or container vulnerabilities.
- Container Generation: If the image scan is clear, the pipeline pushes the production container image to the newly provisioned GCP Artifact Registry.
- Continuous Deployment Hosting: The pipeline automatically applies terraform/app/ via the pipeline on every single push to the main branch. It runs main.tf using variable inputs from variables.tf to spin up or update Google Cloud Run automatically. This hosting layer safely extracts the fresh application container from the registry, attaches its internal environment variables to the previously established core infrastructure (VPC, Cloud SQL database, and secrets), and sets the app live.

## 7. Runtime Testing
- The moment Cloud Run generates a live public URL for the web app, the automated testing architecture executes its final safety step:

- Active Scan (dast.yml): Takes the live application web address and runs automated simulation attacks against the public endpoints (login.html and checkip.html). This confirms that the active application logic and network database pathways are fortified against real-world execution failures.

## 8. Logging and Audit Verification
- With the build live, the final stage requires manually verifying the deployment details against the design documents:

- System Check: Compare the active GCP architecture against the system layout blueprint (docs/architecture.md).
-  Functionality Test: Open the generated HTTPS .run.app URL in a browser to confirm that the application is functional—the frontend assets (static/css) render correctly, the backend Flask API operations communicate smoothly with VirusTotal and AbuseIPDB, and the system securely connects to Cloud SQL.
- Compliance Audit: The Security Reviewer leads the final compliance check. Navigate to the GitHub Actions tab to confirm that the GitHub Actions CI/CD pipeline is fully green and all stages pass including Snyk scans. Ensure the development pipeline milestones (docs/milestones.md) are logged as complete, and export the final automated scanner outputs directly into the repository security logs (docs/security-audit and docs/security can review).
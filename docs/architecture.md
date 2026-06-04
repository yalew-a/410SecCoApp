# Architecture
## ![alt text](../../../410SecCoApp/docs/Architecture.png)

## Diagram of architecture described

### Local Machine 
(has docker build + test locally)
-- push via Git

### GitHub Repo
(terraform) - creates GCP project (bucket) - configure VPC - configure cloud SQL MySQL DB

(CI/CD pipeline) - trigger on push & approved PR - build + scan - auth with GCP via OIDC / no stored keys - push image to artifact registry

### Artifact Registry
app image w/ commit SHA
- pull app image 

### VPC
- (cloud run subnet) - cloud run hosts app < (secret manager - API keys & DB credentials accessed at runtime)

- saved selected IP to database

- (cloud SQL subnect)
- cloud SQL (MySQL)




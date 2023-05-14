## CI/CD

Pipeline can to build docker image, to pushthen on ECR and to deploy on ECS cluster

## Usage

For using CI/CD have to configure Environment variables and Secrets in repository settings.


### Environments and secrets

| Name                       | Description                                     | Value    |
| ---------------------------| ----------------------------------------------- | ---------|
| `AWS_ROLE_NAME`            | Name of IAM Role that runs GitHub Actions       | `vars`   |
| `AWS_ACCOUNT_ID`           | AWS account ID                                  | `secret` |
| `AWS_DEFAULT_REGION`       | Default region which use resources              | `vars`   |
| `REGISTRY`                 | URL to private/public ECR                       | `vars`   |
| `REPOSITORY`               | Name of repository or/and name of application   | `vars`   |
| `ECS_CLUSTER_NAME`         | Name of ECS Cluster                             | `vars`   |
| `ECS_SERVICE_NAME`         | Name of ECS Service                             | `vars`   |
| `ECS_TASK_DEFINITION_NAME` | Name of ECS Task Definition                     | `vars`   |
| `ECS_CONTAINER_NAME`       | Name of Docker Container                        | `vars`   |


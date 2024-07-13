# spacelift-runner-terraform

clone from [https://github.com/spacelift-io/runner-terraform]

## manual-build

```bash
# Enable Docker Buildx:
docker buildx create --use

# You can specify the targets you want to build directly in the docker buildx bake command:
docker buildx bake aws gcp azure

# Specific to azure
docker buildx bake azure

# Run
docker run -it ghcr.io/masakioui/spacelift-runner-terraform:azure-latest .
```

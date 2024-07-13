target "aws" {
    target = "aws"
    platforms = ["linux/amd64", "linux/arm64"]
    args = {"BASE_IMAGE": "alpine:3.20"}
    output = ["type=image,name=ghcr.io/masakioui/spacelift-runner-terraform:latest,push=true"]
}

target "gcp" {
    target = "gcp"
    platforms = ["linux/amd64", "linux/arm64"]
    args = {"BASE_IMAGE": "gcr.io/google.com/cloudsdktool/google-cloud-cli:alpine"}
    output = ["type=image,name=ghcr.io/masakioui/spacelift-runner-terraform:gcp-latest,push=true"]
}

target "azure" {
    target = "azure"
    platforms = ["linux/amd64", "linux/arm64"]
    args = {"BASE_IMAGE": "mcr.microsoft.com/azure-cli:latest"}
    output = ["type=image,name=ghcr.io/masakioui/spacelift-runner-terraform:azure-latest,push=true"]
}
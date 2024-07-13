FROM public.ecr.aws/spacelift/runner-terraform:latest

WORKDIR /tmp
RUN curl -L https://aka.ms/InstallAzureCli | bash
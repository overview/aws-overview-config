# DEPRECATED

We used to use this repository to write configuration files on Overview server
instances.

Now we simply write the configuration files when the instances start up, using
cloud-init. That's in the `aws-overview-tools` repository.

We store variables we're likely to change in S3, in the
`overview-staging-secrets` and `overview-production-secrets` repositories.

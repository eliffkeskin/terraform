# bootstrap

Creates the S3 bucket that holds the Terraform state of every other project in this repo. Applied once; its own state stays local, because the bucket that stores remote state cannot store its own.

## What it creates

- S3 bucket `elif-tfstate-5247` in eu-central-1
- Versioning enabled, so a corrupted state can be rolled back to a previous version
- All four public access block settings on
- Server-side encryption (AES256) by default

## Usage

```bash
terraform init
terraform apply
```

`terraform.tfstate` for this folder is local and not committed. If it is lost, the bucket still exists; import it back with `terraform import aws_s3_bucket.<name>`.

## How other projects use it

Each project declares the bucket in its `versions.tf` backend block with its own key, so states never overlap:

`use_lockfile = true` writes a `.tflock` object next to the state during apply, so a second concurrent run fails instead of corrupting the file. No DynamoDB table is needed (Terraform 1.10+).

Migrating an existing local state into the bucket: add the backend block, then `terraform init -migrate-state`. An empty state is not written until the first apply.

## Notes

- Never destroy this project while other projects have state in the bucket.
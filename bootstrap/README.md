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

## GitHub Actions access (OIDC)

`github-oidc.tf` lets the repo's workflows run Terraform against this account without any stored access key:

- `aws_iam_openid_connect_provider` registers `token.actions.githubusercontent.com` as an identity provider, audience `sts.amazonaws.com`
- `aws_iam_role` trusts that provider (`Federated` principal) for `sts:AssumeRoleWithWebIdentity` and `sts:TagSession`, restricted by a `StringLike` condition on the token's `sub` claim
- `AdministratorAccess` is attached for the lab; a production role would carry a scoped policy
- Output: the role ARN, stored in the repo as the `AWS_ROLE_ARN` secret and passed to `aws-actions/configure-aws-credentials` as `role-to-assume`

Flow per run: the workflow requests a short-lived OIDC token from GitHub, STS validates it against the provider and the `sub` condition, and returns temporary credentials. Nothing secret lives in the repo; the role ARN is not sensitive.

### Things that broke

- `sub` claim format. GitHub now issues `repo:<owner>@<owner_id>/<repo>@<repo_id>:ref:refs/heads/main` rather than the `repo:<owner>/<repo>:...` shown in most docs. The condition `repo:eliffkeskin/terraform:*` never matched and STS returned "Not authorized to perform sts:AssumeRoleWithWebIdentity". Found by reading the `AssumeRoleWithWebIdentity` event in CloudTrail, whose `userName` shows the real `sub`. Fixed with `repo:eliffkeskin@76158485/terraform@1371463043:*`, which is also rename-proof.
- `configure-aws-credentials` passes session tags by default, so the trust policy must also allow `sts:TagSession`.
- The workflow directory is `.github/workflows` (plural); `.github/workflow` is silently ignored.
- Passing the OIDC provider ARN instead of the role ARN produces "Request ARN is invalid".
- `terraform fmt -check -recursive` only covers the directory it runs in; run it from the repo root.

## Notes

- Never destroy this project while other projects have state in the bucket.
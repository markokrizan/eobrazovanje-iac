## eobrazovanje infrastructure as code via terraform

* Export env vars with credentials (easiest way to deal with multiple sets of credentials)
```
export AWS_ACCESS_KEY_ID=<your access key>
export AWS_SECRET_ACCESS_KEY=<your secret key>
```
* Init with inline credentials: `terraform init`
* Plan and save to a file: `terraform plan --out=terraform.out`
* Apply planned changes: `terraform apply terraform.out`

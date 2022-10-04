## eobrazovanje infrastructure as code via terraform

* Init with inline credentials: `terraform init -backend-config="access_key=<your access key>" -backend-config="secret_key=<your secret key>"`
* Plan and save to a file: `terraform plan --out=terraform.out`
* Apply planned changes: `terraform apply terraform.out`

# Terraform - Deploy a single instance on Oracle Cloud

Deploy a single instance in the Oracle Cloud which can be run in the [Always Free](https://www.oracle.com/cloud/free/#always-free) tier.

For more control over network security, deploy the instance into a custom [Virtual Cloud Network](https://github.com/k3karthic/terraform__oci-vcn).

## Encryption

Sensitive files like the input variables (india.tfvars) and Terraform state files are encrypted before being stored in the repository.

Use the following command to decrypt the files after cloning the repository,

```
./bin/decrypt.sh
```

Use the following command after running terraform to update the encrypted files,

```
./bin/encrypt.sh <gpg key id>
```

## Deployment

### Step 1

Create a Terraform plan by running plan.sh; the script will read input variables from the file india.tfvars

```
./bin/plan.sh
```

To avoid fetching the latest state of resources from OCI, run the following command

```
./bin/plan.sh --refresh=false
```

### Step 2

Review the generated plan

```
./bin/view.sh
```

### Step 3

Run the verified plan

```
./bin/apply.sh
```

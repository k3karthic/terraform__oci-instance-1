# Terraform - Deploy a single instance on Oracle Cloud

Deploy a single instance on Oracle Cloud running in the [Always Free](https://www.oracle.com/cloud/free/#always-free) tier.

For more control over network security, deploy the instance into a custom Virtual Cloud Network using the Terraform script at [https://github.com/k3karthic/terraform__oci-vcn](https://github.com/k3karthic/terraform__oci-vcn).

For basic setup (swap, fail2ban), use the Ansible playbook at [https://github.com/k3karthic/ansible__ubuntu-basic](https://github.com/k3karthic/ansible__ubuntu-basic).

## Input Variables

Create a file to store the input variables using the sample file `india.tfvars.sample`. The file should be called `india.tfvars` or edit `bin/plan.sh` with the appropriate file name.

## Deployment

### Step 1

Create a Terraform plan by running plan.sh; the script will read input variables from the file india.tfvars

```
./bin/plan.sh
```

To avoid fetching the latest state of resources from OCI, run the following command.

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

## Encryption

Sensitive files like the input variables (india.tfvars) and Terraform state files are encrypted before being stored in the repository.

You must add the unencrypted file paths to `.gitignore`.

Use the following command to decrypt the files after cloning the repository,

```
./bin/decrypt.sh
```

Use the following command after running terraform to update the encrypted files,

```
./bin/encrypt.sh <gpg key id>
```

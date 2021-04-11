#!/usr/bin/env bash

terraform plan -var-file=india.tfvars --out=tf.plan $@

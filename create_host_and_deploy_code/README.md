## Ansible Modules

This repo is a source for multiple ansible modules to be used as needed.

### Table of Contents
    . Roles

#### Anatomy of the Role
The roles are created by using `ansible-galaxy` from the `roles/` directory to initialize a new role. Then we go into that initialized role and add in what we need. Here's the basic structure (@ is the root of this project):
    - `@/main.yml`: This is the main driver of the ansible tasks. This is the thing you execute against  
    - `@/hosts.yml`: This is the inventory of hosts that the role will target when it executes.  
    - `@/roles/codedeploy`: This is the name of the role  
    - `@/roles/codedeploy/defaults: This contains the default variables that are used throughout all files in the role directory. **YOU WILL WANT TO CHANGE THIS FILE** to fit your needs  
    - `@/roles/codedeploy/files`: This contains static files that get used by tasks. Add files into here that the tasks will use. There's an example script in here that shows how to execute a nodejs app.  
    - `@/roles/codedeploy/tasks`: This is the main meat of the project. Refer to the `main.yml` in here as entrypoint and then `deploy_code.yml`  
    - `@/roles/codedeploy/templates`: This contains the template files that we can use to create new files in our tasks and fill in certain areas of the templated file with our variables from `defaults/`  


#### Variable File
The file located at `roles/codedeploy/defaults/main.yml` is the primary variables file. You will need to go into this file an replace certain values with the values that fit your circumstance. A list follows of the values you will need to change in order to run the role.
    - name_of_private_key_file
    - git_repo_name
    - git_repo_https_url
    - repo_destination_directory
    - application_dependencies_file_name
    - application_initialization_script_name
    - aws_provider_region
    - aws_ec2_instance_name
    - aws_ec2_instance_type
    - aws_ec2_ami
    - aws_ec2_vpc_security_group_ids
    - aws_ec2_subnet_id
    - aws_ec2_private_key_name
    - aws_ec2_public_key_name

*NOTE*: Changing your `aws_ec2_public_key_name` and `aws_ec2_private_key_name`.
You will need to do a `ssh-keygen -m PEM` to generate the keypair locally OR generate the keypair on AWS console -> download the keys -> put them in the `/roles/codedeploy/files/` -> set the `aws_ec2_public_key_name` and private equivalent to reference your newly downloaded keys

Will require the following ENV Vars set in the host you're running ansible from (probably your own computer):
    - AWS_ACCESS_KEY='someAccessKeyYouGotFromAWS'
    - AWS_SECRET_KEY='somePrivateSecretKeyYouGotFromAWS'
    - ANSIBLE_HOST_KEY_CHECKING=false

#### How Do I Execute this role?
Make sure you're in the root of this project.

Prerequisites:
    - Do the above steps related to setting the [Variable File](#variable-file)
    - Ensure that the security rules for the security group you're referencing allow SSH
    - `ansible-galaxy collection install community.general amazon.aws`  
    - `ansible-galaxy install diodonfrost.terraform`

Exec Command:  
`ansible-playbook -i hosts.yml main.yml`

#### Random Notes
Make sure that your security group rules for the instance allow you to connect to the instance. 

Make sure that your private key is in pem format. `ssh-keygen -m PEM`

Will Want to set `ANSIBLE_HOST_KEY_CHECKING=False` so you can automatically connect to the host for post-provisioning.
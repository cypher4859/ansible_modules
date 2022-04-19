## Ansible Modules

This repo is a source for multiple ansible modules to be used as needed.

## Table of Contents  
- [Code Deploy](#code-deploy-role)
    - [Anatomy of Code Deploy](#anatomy-of-the-role)
    - [Configure Variable File](#variable-file)
    - [Executing the Role](#how-do-i-execute-this-role)

### Code Deploy Role
#### Anatomy of the Role
The roles are created by using `ansible-galaxy` from the `roles/` directory to initialize a new role. Then we go into that initialized role and add in what we need. Here's the basic structure (@ is the root of this project):
- `@/main.yml`: This is the main driver of the ansible tasks. This is the thing you execute against  
- `@/hosts.yml`: This is the inventory of hosts that the role will target when it executes.  
- `@/roles/codedeploy`: This is the name of the role  
- `@/roles/codedeploy/defaults`: This contains the default variables that are used throughout all files in the role directory. **YOU WILL WANT TO CHANGE THIS FILE** to fit your needs  
- `@/roles/codedeploy/files`: This contains static files that get used by tasks. Add files into here that the tasks will use. There's an example script in here that shows how to execute a nodejs app.  
- `@/roles/codedeploy/tasks`: This is the main meat of the project. Refer to the `main.yml` in here as entrypoint and then `deploy_code.yml`  
- `@/roles/codedeploy/templates`: This contains the template files that we can use to create new files in our tasks and fill in certain areas of the templated file with our variables from `defaults/`  


#### Variable File
The file located at `roles/codedeploy/defaults/main.yml` is the primary variables file. You will need to go into this file an replace certain values with the values that fit your circumstance. A list follows of the values you will need to change in order to run the role.  
- **name_of_private_key_file** : This is the private key for key pair you will use to connect to the ec2 instance. Usually a .pem file  
- **git_repo_https_url** : if using git then this is the git repo https url  
- **code_repo_name** : This is either the name of the repo you're grabbing with git or the name of directory that your application will sit  
- **code_repo_destination_directory** : Path to the code repo name  
- **application_dependencies_file_name** : This should be a bash script that installs dependencies. Only needed when resolve_dependencies is set  
- **resolve_dependencies** : When this is set it will execute your app dependencie bash script on the target ec2 instance  
- **application_initialization_script_name** : Should be bash script that executes your main command to execute your code  
- **aws_provider_region** : Whatever region in AWS you'd like to setup the ec2 instance in  
- **aws_ec2_instance_name**  
- **aws_ec2_instance_type**  
- **aws_ec2_ami**  
- **aws_ec2_vpc_security_group_ids**  
- **aws_ec2_subnet_id**  
- **aws_ec2_private_key_name**  
- **aws_ec2_public_key_name**  

*NOTE*: Changing your `aws_ec2_public_key_name` and `aws_ec2_private_key_name`.
You will need to do a `ssh-keygen -m PEM` to generate the keypair locally OR generate the keypair on AWS console -> download the keys -> put them in the `/roles/codedeploy/files/` -> set the `aws_ec2_public_key_name` and private equivalent to reference your newly downloaded keys

Will require the following ENV Vars set in the host you're running ansible from (probably your own computer):
```
export AWS_ACCESS_KEY='someAccessKeyYouGotFromAWS'
export AWS_SECRET_KEY='somePrivateSecretKeyYouGotFromAWS'
export ANSIBLE_HOST_KEY_CHECKING=false
```

#### How Do I Execute this role?
Make sure you're in the root of this project.

Prerequisites:  
- Do the above steps related to setting the [Variable File](#variable-file)  
- Ensure that the security rules for the security group you're referencing allow SSH  
- Run from your ansible host (wherever you're running ansible-playbook from) `ansible-galaxy collection install community.general amazon.aws`  
- Run from your ansible host `ansible-galaxy install diodonfrost.terraform`  

Exec Command:  
```sh
$ ansible-playbook -i hosts.yml main.yml
```

#### Random Notes
- Make sure that your security group rules for the instance allow you to connect to the instance. 
- Make sure that your private key is in pem format. `ssh-keygen -m PEM`
- Will Want to set `ANSIBLE_HOST_KEY_CHECKING=False` so you can automatically connect to the host for post-provisioning.
- If you run this script multiple times it will essentially recreate the ec2 instance rather than create a new one everytime. This is the nature of terraform.
I think we can set a flag on the terraform task to force creating a new one though.
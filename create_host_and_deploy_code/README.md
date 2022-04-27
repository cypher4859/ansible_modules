## Ansible Modules

This repo is a source for multiple ansible modules to be used as needed.

## Table of Contents  
- [Code Deploy](#code-deploy-role)
    - [Anatomy of Code Deploy](#anatomy-of-the-role)
    - [Configure Variable File](#variable-file)
    - [Executing the Role](#how-do-i-execute-this-role)
    - [Examples](#examples)

### Code Deploy Role
**Synopsis**:  
This ansible role is designed to build out a host on either an AWS EC2 instance or a docker container and deploy custom code to the host. You can choose to either build out the host standalone or to build the host and deploy code on it.


#### Anatomy of the Role
The roles are created by using `ansible-galaxy` from the `roles/` directory to initialize a new role. Then we go into that initialized role and add in what we need. Here's the basic structure (@ is the root of this project):
- `@/main.yml`: This is the main driver of the ansible tasks. This is the thing you execute against  
- `@/hosts.yml`: This is the inventory of hosts that the role will target when it executes.  
- `@/roles/<role name>`: This is the name of the role  
- `@/roles/<role name>/defaults`: This contains the default variables that are used throughout all files in the role directory. **YOU WILL WANT TO CHANGE THIS FILE** to fit your needs  
- `@/roles/<role name>/files`: This contains static files that get used by tasks. Add files into here that the tasks will use. There's an example script in here that shows how to execute a nodejs app.  
- `@/roles/<role name>/tasks`: This is the main meat of the project. Refer to the `main.yml` in here as entrypoint and then `deploy_code.yml`  
- `@/roles/<role name>/templates`: This contains the template files that we can use to create new files in our tasks and fill in certain areas of the templated file with our variables from `defaults/`  


#### Variable File
The file located at `roles/<role name>/defaults/main.yml` is the primary variables file. You will need to go into this file an replace certain values with the values that fit your circumstance. 

A list follows of the values you will need to change in order to run the role depending on your use case. For example, if you want to run an EC2 instance then you don't need to set the ***aws*** variables and similarly with the docker variables if you want to run an EC2 instance.

---

### AWS variables
- **name_of_private_key_file** : This is the private key for key pair you will use to connect to the ec2 instance. Usually a .pem file  
- **aws_provider_region** : Whatever region in AWS you'd like to setup the ec2 instance in  
- **aws_ec2_instance_name**  
- **aws_ec2_instance_type**  
- **aws_ec2_ami**  
- **aws_ec2_vpc_security_group_ids**  
- **aws_ec2_subnet_id**  
- **aws_ec2_private_key_name**  
- **aws_ec2_public_key_name**  

### Set AWS Key Pairs  
Here are some notes about setting your `aws_ec2_public_key_name` and `aws_ec2_private_key_name`.

You will need to set your key pairs in order to be able to access the EC2 instance via ansible after creating it. You can perform either the following actions to do so:
- Option 1: Generate the key pair locally and upload to AWS
- Option 2: Generate the key pair in AWS and download them to your repo

#### Option 1 - Generate the key pair locally
```sh
ssh-keygen -m PEM # This will generate the keypair locally. DONT set a passphrase
# Next you need to go to the AWS Dashboard -> select EC2 -> select correct region you want to be in -> select Key Pairs in the left side menu -> upload your public key
```

#### Option 2 - Generate the key pair in AWS
To you need to go to the AWS Dashboard -> select EC2 -> select correct region you want to be in -> select Key Pairs in the left side menu -> Generate new key -> this should download the key .pem file. Move this file to your `roles/create_host/files/` and make sure to add to your .gitignore so you don't accidentally commit them. Be sure to set the variable for `aws_ec2_public_key_name` to reference the name of the keypair you generated in AWS and set the `aws_ec2_private_key_name` to the name of the private key .pem file you downloaded.

### Set AWS Access Keys
You will need to set the following ENV Vars set in the host you're running ansible from (probably your own computer) in order to access AWS programmatically from your laptop:
```sh
export AWS_ACCESS_KEY='someAccessKeyYouGotFromAWS'
export AWS_SECRET_KEY='somePrivateSecretKeyYouGotFromAWS'
export ANSIBLE_HOST_KEY_CHECKING=false
```

#### Random Notes
- Make sure that your security group rules for the instance allow you to connect to the instance. 
- Make sure that your private key is in pem format. `ssh-keygen -m PEM`
- Will Want to set `ANSIBLE_HOST_KEY_CHECKING=False` so you can automatically connect to the host for post-provisioning.
- If you run this script multiple times it will essentially recreate the ec2 instance rather than create a new one everytime. This is the nature of terraform. I think we can set a flag on the terraform task to force creating a new one though.
---
### Docker Variables
**Note:** *This role uses ansible to talk with terraform and by using terraform it will integrate with docker.*
- **terraform_docker_image_registry**: (optional) The registry of the docker image 
- **terraform_docker_container_image**: The name of the image to use
- **terraform_docker_container_name**: Name of the container
- **terraform_docker_container_tag_version**: Tag version of the image, e.g. 'latest'
- **terraform_docker_container_cmd**: (optional) An overriding command, refer to `CMD` in dockerfile reference.
- **terraform_docker_extra_properties**: Extra key=value properties to set to extend on the existing template. Refer to [the examples below](#examples) for some examples of how to set this. 

### Code Deploy Variables
If you would like to deploy code onto the host then you're going to need to set these options.
- **git_repo_https_url** : if using git then this is the git repo https url  
- **code_repo_name** : This is either the name of the repo you're grabbing with git or the name of directory that your application will sit  
- **code_repo_destination_directory** : Path to the code repo name  
- **application_dependencies_file_name** : This should be a bash script that installs dependencies. Only needed when resolve_dependencies is set  
- **resolve_dependencies** : When this is set it will execute your app dependencie bash script on the target ec2 instance  
- **application_initialization_script_name** : Should be bash script that executes your main command to execute your code  

#### How Do I Execute this role?
Make sure you're in the root of this project.

Prerequisites:  
1. Ensure that you are either passing in the right variables or you have changed the defaults set in [Variable File](#variable-file)  
2. (AWS) Ensure that the security rules for the security group you're referencing allow SSH  
3. Execute the prepare script located at `prepare_host.sh`
```sh
chmod +x prepare_host.sh
prepare_host.sh
```
Exec Command:  
```sh
ansible-playbook main.yml
```

### Examples
1. Create a docker container host based on an image from specific repo (using the senaite repo as example):
```sh
ansible-playbook create_host_and_deploy_code/main.yml --extra-vars '{"create_host_mode": "docker", "terraform_docker_image_registry": "senaite", "terraform_docker_container_image": "senaite", "terraform_docker_container_name": "senaite_example", "terraform_docker_container_tag_version": "edge"}'
```
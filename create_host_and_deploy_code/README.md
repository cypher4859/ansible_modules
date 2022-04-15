## Ansible Modules

This repo is a source for multiple ansible modules to be used as needed.

### Table of Contents
    . Roles

#### How the role was created
The roles are created by using `ansible-galaxy` from the `roles/` directory to initialize a new role. Then we go into that initialized role and add in what we need. Here's the basic structure (@ is the root of this project):
    - `@/main.yml`: This is the main driver of the ansible tasks. This is the thing you execute against  
    - `@/hosts.yml`: This is the inventory of hosts that the role will target when it executes.  
    - `@/roles/codedeploy`: This is the name of the role  
    - `@/roles/codedeploy/defaults: This contains the default variables that are used throughout all files in the role directory. **YOU WILL WANT TO CHANGE THIS FILE** to fit your needs  
    - `@/roles/codedeploy/files`: This contains static files that get used by tasks. Add files into here that the tasks will use. There's an example script in here that shows how to execute a nodejs app.  
    - `@/roles/codedeploy/tasks`: This is the main meat of the project. Refer to the `main.yml` in here as entrypoint and then `deploy_code.yml`  
    - `@/roles/codedeploy/templates`: This contains the template files that we can use to create new files in our tasks and fill in certain areas of the templated file with our variables from `defaults/`  


#### How Do I Execute this role?
Make sure you're in the root of this project.

Prerequisites:  
    - `ansible-galaxy collection install community.general`  
    - `ansible-galaxy collection install amazon.aws`  

Exec Command:  
`ansible-playbook -i hosts.yml main.yml`

#### Random Notes
Make sure that your security group rules for the instance allow you to connect to the instance.

Make sure that your private key is in pem format. `ssh-keygen -m PEM`

Will Want to set `ANSIBLE_HOST_KEY_CHECKING=False` so you can automatically connect to the host for post-provisioning.
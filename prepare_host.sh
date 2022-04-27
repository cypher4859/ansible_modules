# Install pip
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py --user

# Use pip to install ansible
python3 -m pip install --user ansible

# Use ansible-galaxy to install prerequisite roles/collections
ansible-galaxy collection install community.general amazon.aws
ansible-galaxy install diodonfrost.terraform

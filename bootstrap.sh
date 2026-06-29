#!/bin/bash
set -e

yum install git -y
yum install ansible -y
git clone https://github.com/meghashyam-singh/catalogue-ansible-playbook.git
cd catalogue-ansible-playbook
ansible-playbook -i "localhost," -c local catalogue.yaml
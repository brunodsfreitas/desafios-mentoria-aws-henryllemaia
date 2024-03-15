FROM alpinelinux/ansible

COPY playbook.yml /ansible/playbook.yml
COPY inventory.ini /ansible/inventory.ini

WORKDIR /ansible

CMD ["ansible-playbook", "-u","root","-k","-i","inventory.ini","playbook.yml"]

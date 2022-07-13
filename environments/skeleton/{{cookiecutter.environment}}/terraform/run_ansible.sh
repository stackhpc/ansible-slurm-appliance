#!/usr/bin/bash
ANSIBLE_STDOUT_CALLBACK=community.general.diy ansible-playbook $1

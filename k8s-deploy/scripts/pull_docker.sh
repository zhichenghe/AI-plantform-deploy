#!/bin/bash
set -e #uxo pipefail

ansible-playbook pull_docker.yml -i inventory.ini -u devops -b
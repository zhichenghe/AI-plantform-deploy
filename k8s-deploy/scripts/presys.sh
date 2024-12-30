#!/bin/bash
set -e #uxo pipefail

ansible-playbook main.yaml -i inventory.ini -u $1 -b -kK
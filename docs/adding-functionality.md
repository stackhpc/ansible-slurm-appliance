# Adding new functionality

Please contact us for specific advice, but this generally involves:
- Adding a role.
- Adding a play calling that role into an existing playbook in `ansible/`, or adding a new playbook there and updating `site.yml`.
- Adding a new (empty) group named after the role into `environments/common/inventory/groups` and a non-empty example group into `environments/common/layouts/everything`.
- Adding new default group vars into `environments/common/inventory/group_vars/all/<rolename>/`.
- Updating the default Packer build variables in `environments/common/inventory/group_vars/builder/defaults.yml`.
- Updating READMEs.

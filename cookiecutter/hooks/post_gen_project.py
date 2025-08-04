import os
import sys

{% if cookiecutter.is_site_env == False %}
os.symlink("../../../tofu/layouts/main.tf", "tofu/main.tf")
os.symlink("../../../tofu/variables.tf", "tofu/variables.tf")
{% endif %}
{% if cookiecutter.parent_site_env != 'None' %}
if not os.path.isdir("../{{ cookiecutter.parent_site_env }}"):
    print("ERROR: Parent environment {{ cookiecutter.parent_site_env }} does not exist")
    sys.exit(1)
os.symlink("../../{{ cookiecutter.parent_site_env }}/tofu/{{ cookiecutter.parent_site_env }}.auto.tfvars","tofu/{{ cookiecutter.parent_site_env }}.auto.tfvars")
{% endif %}

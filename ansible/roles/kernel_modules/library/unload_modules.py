import re
import subprocess

from ansible.module_utils.basic import AnsibleModule

DOCUMENTATION = r"""
---
module: unload_modules
short_description: fast rmmod + modprobe
version_added: "1.0.0"
description: >
    With a growing list of modules to denylist, the mitigations playbook
    can take minutes to run, which is not acceptable.
    This modules applies the rmmod and tries the modbprobe and returns changes.
author:
    - Eric Le Lay
"""

EXAMPLES = r"""
- name: Ensure forbidden modules are not loaded
  unload_modules:
    denylist: "{{ kernel_modules_denylist }}"
"""

RETURN = r"""
unloaded:
    description: List of unloaded modules (might be empty)
    type: str[]
    returned: always
"""


DEFAULT_TIMEOUT = 10  # how long to wait for a module to unload


def rmmod(m, timeout=DEFAULT_TIMEOUT):
    """returns True if the module was unloaded, false if it wasn't loaded, raise otherwise"""
    cmd = ["rmmod", m]
    res = subprocess.run(  # noqa: UP022
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        encoding="utf-8",
        timeout=timeout,
        check=False,
    )
    if res.returncode == 0:
        return True
    elif f"ERROR: Module {m} is not currently loaded" in res.stderr:
        return False
    else:
        res.check_returncode()


def unload_modules(module, denylist, result):
    """(pretend to) call rmmod on all denylist modules.
    By calling rmmod on all modules there can be no race condition between an lsmod and rmmod.
    """
    if module.check_mode:
        # in check mode just compute the list from loaded modules and denylist
        loaded_modules = set()
        with open("/proc/modules", encoding="utf-8") as f:
            for ln in f:
                m = re.match(r"""^([a-zA-Z0-9_]+)\s+.*$""", ln)
                if m:
                    loaded_modules.add(m.group(1))
        for m in denylist:
            if m in loaded_modules:
                result["unloaded"].append(m)
    else:
        # really run rmmod
        try:
            processed = []
            for m in denylist:
                # could also model diff as loaded modules, before and after...
                if rmmod(m):
                    result["unloaded"].append(m)
                processed.append(m)
        except subprocess.CalledProcessError as e:
            module.fail_json(
                msg=f"Failed calling rmmod: {e!r}",
                unloaded=result["unloaded"],
                processed=processed,
            )
        except subprocess.TimeoutExpired as e:
            module.fail_json(
                msg=f"Timeout calling rmmod: {e!r}",
                unloaded=result["unloaded"],
                processed=processed,
            )

    result["diff"]["after"] = "\n".join(result["unloaded"]) + "\n"
    result["changed"] = bool(result["unloaded"])


def try_loading_modules(module, denylist, result):
    """modprobe all denylisted modules and fail if modprobe succeeds"""
    # try modprobe and fail if any succeeds
    try:
        for m in denylist:
            cmd = ["modprobe", m]
            res = subprocess.run(  # noqa: UP022
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                encoding="utf-8",
                timeout=DEFAULT_TIMEOUT,
                check=False,
            )
            if res.returncode == 0:
                module.fail_json(
                    msg=f"Should not have been able to modprobe {m}: stdout={res.stdout} stderr={res.stderr}"
                )
    except subprocess.TimeoutExpired as e:
        module.fail_json(msg=f"Timeout calling modprobe {m}: {e!r}")


def run_module():
    module_args = {
        "denylist": {
            "type": "list",
            "required": True,
        },
    }

    result = {
        "changed": False,
        "unloaded": [],
        "diff": {
            "before": "\n",
            "after": "\n",
        },
    }

    module = AnsibleModule(argument_spec=module_args, supports_check_mode=True)
    denylist = module.params["denylist"]

    unload_modules(module, denylist, result)
    if not module.check_mode:
        try_loading_modules(module, denylist, result)
    module.exit_json(**result)


def main():
    run_module()


if __name__ == "__main__":
    main()

#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, StackHPC
# Apache 2 License
import glob
import os
import re

from ansible.module_utils.basic import AnsibleModule

ANSIBLE_METADATA = {
    "metadata_version": "0.1",
    "status": ["preview"],
    "supported_by": "community",
}

DOCUMENTATION = """
---
module: infiniband_facts
short_description: Get information about infiniband ports via the /sys/class/infiniband pseudo-fs
version_added: "0.0"
description: >
    Get some information about infiniband ports, to feed to the nhc.conf.
    The returned `ansible_facts.infiniband_ports` property is a list of objects for easy use by nhc
requirements:
    - "python >= 3.6"
author:
    - Eric Le Lay, StackHPC
"""


RETURN = r"""
infiniband_ports:
    description: Information about infiniband ports.
    returned: always
    type: list
    elements: dict
        contains:
            name:
                description: "device_name:port"
                returned: success
                type: str
                sample: mlnx5_0:1
            num:
                description: port number inside parent device (1..n)
                returned: success
                type: str
                sample: "1"
            dev:
                description: parent device name
                returned: success
                type: str
                sample: mlnx5_0
            state:
                description: port state (DOWN, INIT, ARMED, ACTIVE or ACTIVE_DEFER)
                returned: success
                type: str
                sample: ACTIVE
            phys_state
                description: link state (Sleep, Polling, LinkUp, etc)
                returned: success
                type: str
                sample: LinkUp
            rate:
                description: port data rate (=speed) in Gb/s
                returned: success
                type: str
                sample: "200"
            net_device:
                description: if possible, the corresponding net device (ib0, ...), or "" if not found
                returned: success
                type: str
                sample: "ib0"
            net_device_gid_index:
                description index N in /sys/class/infiniband/<net_device>/ports/<num>/gids/N with GID matching the net device's MAC address
                returned: success
                type: str
                sample: "1"
"""

EXAMPLES = """
    - name: Gather infiniband facts
      infiniband_facts:
    - debug:
        var: infiniband_ports
"""


def run_module():  # pylint: disable=missing-function-docstring
    module_args = {}

    module = AnsibleModule(argument_spec=module_args, supports_check_mode=True)
    port_info_list = []
    ib_mac_addresses = {}
    result = {
        "changed": False,
        "ansible_facts": {
            "infiniband_ports": port_info_list,
            "ib_mac_addresses": ib_mac_addresses,
        },
    }
    # if module.check_mode:
    #    module.exit_json(**result)

    # See https://docs.kernel.org/admin-guide/abi-stable-files.html#abi-file-stable-sysfs-class-infiniband
    ports = glob.glob("/sys/class/infiniband/*/ports/*")
    if module._debug:
        module.log("Found following IB ports: %r", " ".join(ports))

    # To map ibX to ports, we compare the mac address.
    # The mac address contains a prefix before the port's GID, that we remove.
    if ports:
        mac_addr_paths = glob.glob("/sys/class/net/ib*/address")
        for a in mac_addr_paths:
            ibdev = os.path.basename(os.path.dirname(a))
            try:
                with open(a, encoding="utf-8") as f:
                    ib_mac = f.read().strip()
                    # eg 00:00:10:47:fe:80:00:00:00:00:00:00:38:25:f3:03:00:47:2f:ec
                    # remove leading 00:00:10:47: to get the port gid
                    if len(ib_mac) == 59:
                        if module._debug:
                            module.log(
                                "Removing %s from %s mac address to get gid=%s"
                                % (ib_mac[:12], ibdev, ib_mac[12:])
                            )
                        ib_mac = ib_mac[12:]
                    # remove ':' because they are packed differently in port gids
                    ib_mac_addresses[ib_mac.replace(":", "")] = ibdev
            except Exception as e:
                module.log("%s: exception reading/parsing: %r" % (a, e))
    for port_path in ports:
        port_num = os.path.basename(port_path)
        port_device = os.path.basename(os.path.dirname(os.path.dirname(port_path)))
        port_info = {
            "name": "%s:%s" % (port_device, port_num),
            "num": port_num,
            "dev": port_device,
            "net_device": "",
            # "gids": [],
        }
        port_info_list.append(port_info)
        info_extract = {
            # of the form "1: DOWN" or "4: ACTIVE"
            "state": re.compile(r"""^[0-9]+: (.+)"""),
            # of the form "200 Gb/sec (2X NDR)" or "25 Gb/sec (1X EDR)" or "40 Gb/sec (4X QDR)"
            "rate": re.compile(r"""^([0-9]+) Gb/sec .+"""),
            # of the form "5: LinkUp" or "3: Disabled"
            "phys_state": re.compile(r"""^[0-9]+: (.+)"""),
        }
        port_info.update({x: "" for x in info_extract})
        for info, extract in info_extract.items():
            try:
                with open(os.path.join(port_path, info), encoding="utf-8") as f:
                    raw = f.read().strip()
                    if module._debug:
                        module.log(
                            "Port %s:%s %s=%r" % (port_device, port_num, info, raw)
                        )
                    m = extract.fullmatch(raw)
                    if m:
                        port_info[info] = m.group(1)
                    else:
                        module.log(
                            "Port %s:%s unexpected %s=%r"
                            % (port_device, port_num, info, raw)
                        )
            except Exception as e:
                module.log(
                    "Port %s:%s unable to read %s: %r"
                    % (port_device, port_num, info, e)
                )
        gids = glob.glob(os.path.join(port_path, "gids", "*"))
        for gid in gids:
            try:
                with open(gid, encoding="utf-8") as f:
                    raw = f.read().strip()
                    gid_packed = raw.replace(":", "")
                    # port_info["gids"].append(raw)
                    if gid_packed in ib_mac_addresses:
                        if module._debug:
                            module.log(
                                "GID %s=%s matches ib net device %s",
                                gid,
                                raw,
                                ib_mac_addresses[gid_packed],
                            )
                        port_info["net_device_gid_index"] = os.path.basename(gid)
                        port_info["net_device"] = ib_mac_addresses[gid_packed]
            except Exception as e:
                module.log(
                    "GID %s unable to read: %r"
                    % (
                        gid,
                        e,
                    )
                )
    module.exit_json(**result)


def main():
    run_module()


if __name__ == "__main__":
    main()

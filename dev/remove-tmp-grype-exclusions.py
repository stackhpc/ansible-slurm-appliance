#!/usr/bin/env python3
"""
Remove identified sections from .grype.yaml
"""

import argparse
import logging
import re
import sys

IGNORED_SECTIONS = set(
    [
        "VULNERABILITIES WE ARE STILL MONITORING",
        "TEMPORARY EXCLUSIONS",
    ]
)


def main():
    parser = argparse.ArgumentParser(
        description="Remove identified sections from .grype.yaml",
        epilog="Redirect output to a new file, like .grype.clean.yaml and call grype with it...",
    )
    parser.add_argument(
        "grype_yaml",
        type=argparse.FileType("r", encoding="utf-8"),
        help=".grype.yaml to modify",
    )
    parser.add_argument("-v", "--verbose", action="store_true", help="verbose output")

    args = parser.parse_args()
    logging.basicConfig(
        level=logging.DEBUG if args.verbose else logging.INFO, stream=sys.stderr
    )

    section = None
    ignore = False
    for line in args.grype_yaml:
        if section is None:
            if m := re.fullmatch(r"""# \{\{\{ BEGIN (.+)\n""", line):
                section = m.group(1)
                if ignore := section in IGNORED_SECTIONS:
                    logging.debug(
                        "Found starting line for section %s, ignoring until end",
                        section,
                    )
                else:
                    logging.debug(
                        "Found starting line for section %s, not ignoring", section
                    )
            else:
                sys.stdout.write(line)
        elif m := re.fullmatch(r"""# \}\}\} END %s\n""" % re.escape(section), line):
            logging.debug(
                "Found ending line for section %s, will output next lines", section
            )
            section = None
            ignore = False
        elif not ignore:
            logging.debug(
                "In non-ignored section %s, outputting line %s", section, line
            )
            sys.stdout.write(line)
        else:
            logging.debug("In section %s. Ignoring line %s", section, line)
    return 0


if __name__ == "__main__":
    sys.exit(main())

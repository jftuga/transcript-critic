#!/usr/bin/env python3

"""Add a permission rule to ~/.claude/settings.json.

Usage: add_permission.py <settings_file> <rule>

If the settings file does not exist, it is created with the rule.
If the file exists, the rule is added to permissions.allow (if not already present).
"""

import json
import os
import sys


def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <settings_file> <rule>", file=sys.stderr)
        sys.exit(1)

    path = sys.argv[1]
    rule = sys.argv[2]

    if not os.path.isfile(path):
        data = {}
    else:
        with open(path) as f:
            data = json.load(f)

    perms = data.setdefault("permissions", {})
    allow = perms.setdefault("allow", [])

    if rule in allow:
        print(f"  Rule already present: {rule}")
    else:
        allow.append(rule)
        print(f"  Added: {rule}")

    with open(path, "w") as f:
        json.dump(data, f, indent=2)
        f.write("\n")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3

"""Add permission rules to ~/.claude/settings.json.

Usage: add_permission.py <settings_file> <rule> [<rule> ...]

If the settings file does not exist, it is created with the rules.
If the file exists, each rule is added to permissions.allow (if not already
present). Before an existing file is modified, a backup is written to
<settings_file>.bak. The file is only rewritten when something changed.
"""

import json
import os
import shutil
import sys
import tempfile


def main():
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <settings_file> <rule> [<rule> ...]", file=sys.stderr)
        sys.exit(1)

    path = sys.argv[1]
    rules = sys.argv[2:]
    exists = os.path.isfile(path)

    if exists:
        try:
            with open(path) as f:
                data = json.load(f)
        except json.JSONDecodeError as e:
            print(f"Error: {path} is not valid JSON ({e}); not modifying it.", file=sys.stderr)
            sys.exit(1)
    else:
        data = {}

    if not isinstance(data, dict):
        print(f"Error: {path} does not contain a JSON object; not modifying it.", file=sys.stderr)
        sys.exit(1)

    perms = data.setdefault("permissions", {})
    if not isinstance(perms, dict):
        print(f"Error: 'permissions' in {path} is not an object; not modifying it.", file=sys.stderr)
        sys.exit(1)

    allow = perms.setdefault("allow", [])
    if not isinstance(allow, list):
        print(f"Error: 'permissions.allow' in {path} is not a list; not modifying it.", file=sys.stderr)
        sys.exit(1)

    changed = False
    for rule in rules:
        if rule in allow:
            print(f"  Rule already present: {rule}")
        else:
            allow.append(rule)
            changed = True
            print(f"  Added: {rule}")

    if not changed:
        return

    if exists:
        shutil.copy2(path, path + ".bak")
        print(f"  Backup of previous settings: {path}.bak")
    else:
        os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)

    # Write atomically so an interrupted run never leaves a truncated file.
    dir_name = os.path.dirname(os.path.abspath(path))
    fd, tmp = tempfile.mkstemp(dir=dir_name, prefix=".settings.", suffix=".json")
    try:
        with os.fdopen(fd, "w") as f:
            json.dump(data, f, indent=2)
            f.write("\n")
        if exists:
            shutil.copymode(path, tmp)
        os.replace(tmp, path)
    except BaseException:
        os.unlink(tmp)
        raise


if __name__ == "__main__":
    main()

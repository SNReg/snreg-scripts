#!/usr/bin/env bash
# Sets PermitRootLogin no by prepending it (sshd uses the first occurrence).
# Idempotent: exits without changes when it is already the first directive.
set -euo pipefail

cfg=/etc/ssh/sshd_config
first=$(grep -iE '^\s*PermitRootLogin\s' "$cfg" | head -n1 | awk '{print tolower($2)}' || true)
[[ "$first" == "no" ]] && exit 0

cp -p "$cfg" "$cfg.snreg.bak"
{ echo "PermitRootLogin no  # managed by SNReg"; cat "$cfg.snreg.bak"; } > "$cfg"
if ! sshd -t; then
  cp -p "$cfg.snreg.bak" "$cfg"
  echo "sshd -t rejected the change; restored original config" >&2
  exit 1
fi
systemctl reload ssh 2>/dev/null || systemctl reload sshd

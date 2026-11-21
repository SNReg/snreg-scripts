-- Passes only when sshd's effective PermitRootLogin is "no".
-- sshd uses the first occurrence of a keyword; unset means prohibit-password.
-- ponytail: reads sshd_config only, not Include'd drop-ins; use `sshd -T` once
-- sshd is on the agent's exec allow-list.
local cfg = snreg.read_file("/etc/ssh/sshd_config")
if cfg == nil then
  return { status = "error", message = "cannot read /etc/ssh/sshd_config" }
end

local value = "prohibit-password"
for line in cfg:gmatch("[^\n]+") do
  local v = line:match("^%s*[Pp][Ee][Rr][Mm][Ii][Tt][Rr][Oo][Oo][Tt][Ll][Oo][Gg][Ii][Nn]%s+(%S+)")
  if v then
    value = v:lower()
    break
  end
end

if value == "no" then
  return { status = "pass", message = "root login disabled", data = { permit_root_login = value } }
end
return { status = "fail", message = "PermitRootLogin is " .. value, data = { permit_root_login = value } }

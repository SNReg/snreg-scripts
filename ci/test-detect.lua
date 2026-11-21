-- Runs a detect script against fixture files with a stubbed sandbox API.
-- Stand-in until `snreg-agentd lua-run` exists (spec §9 P8).
-- usage: lua ci/test-detect.lua   (from the repo root)
local function run(script, files)
  snreg = {
    read_file = function(p) return files[p] end,
    log = function() end,
  }
  return dofile(script)
end

local cases = {
  { nil, "error" },
  { "", "fail" },
  { "PermitRootLogin no\n", "pass" },
  { "  permitrootlogin NO\n", "pass" },
  { "#PermitRootLogin no\n", "fail" },
  { "PermitRootLogin yes\nPermitRootLogin no\n", "fail" },
  { "PermitRootLogin no\nPermitRootLogin yes\n", "pass" },
}
local failed = 0
for i, c in ipairs(cases) do
  local r = run("detect/ssh-root-login/script.lua", { ["/etc/ssh/sshd_config"] = c[1] })
  if r.status ~= c[2] then
    failed = failed + 1
    print(("case %d: want %s, got %s (%s)"):format(i, c[2], r.status, r.message))
  end
end
print(("%d/%d passed"):format(#cases - failed, #cases))
os.exit(failed == 0)

std = "lua51"
read_globals = { "snreg" }
allow_defined_top = false
files["ci/*.lua"] = { globals = { "snreg" } }

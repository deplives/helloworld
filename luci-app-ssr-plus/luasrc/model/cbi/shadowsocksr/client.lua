local m, s, sec, o
local uci = luci.model.uci.cursor()
m = Map("shadowsocksr")

m:section(SimpleSection).template = "shadowsocksr/status"

local server_table = {}
uci:foreach("shadowsocksr", "servers", function(s)
    if s.alias then
        server_table[s[".name"]] = "[%s] %s" % {
            string.upper(s.v2ray_protocol or s.type),
            s.alias
        }
    elseif s.server and s.server_port then
        server_table[s[".name"]] = "[%s] %s:%s" % {
            string.upper(s.v2ray_protocol or s.type),
            s.server,
            s.server_port
        }
    end
end)

local key_table = {}
for key, _ in pairs(server_table) do
    table.insert(key_table, key)
end

table.sort(key_table)

-- [[ Global Setting ]]--
s = m:section(TypedSection, "global")
s.anonymous = true

o = s:option(ListValue, "global_server", translate("Main Server"))
o:value("nil", translate("Disable"))
for _, key in pairs(key_table) do
    o:value(key, server_table[key])
end
o.default = "nil"
o.rmempty = false

o = s:option(ListValue, "udp_relay_server", translate("UDP Server"))
o:value("", translate("Disable"))
o:value("same", translate("Same as Global Server"))
for _, key in pairs(key_table) do
    o:value(key, server_table[key])
end

o = s:option(ListValue, "threads", translate("Multi Threads Option"))
o:value("0", translate("Auto Threads"))
o:value("1", translate("1 Thread"))
o:value("2", translate("2 Threads"))
o:value("4", translate("4 Threads"))
o:value("8", translate("8 Threads"))
o:value("16", translate("16 Threads"))
o:value("32", translate("32 Threads"))
o:value("64", translate("64 Threads"))
o:value("128", translate("128 Threads"))
o.default = "0"
o.rmempty = false

o = s:option(ListValue, "run_mode", translate("Running Mode"))
o:value("gfw", translate("GFW List Mode"))
o:value("router", translate("IP Route Mode"))
o:value("all", translate("Global Mode"))
o:value("oversea", translate("Oversea Mode"))
o.default = "gfw"

o = s:option(ListValue, "dports", translate("Proxy Ports"))
o:value("1", translate("All Ports"))
o:value("2", translate("Only Common Ports"))
o.default = "1"

o = s:option(ListValue, "dns_mode", translate("Resolve DNS Mode"))
o:value("1", translate("Use DNS2TCP query"))
o:value("2", translate("Use DNS2SOCKS query and cache"))
o:value("0", translate("Use Local DNS Service listen port 5335"))
o.default = "1"

o = s:option(Value, "tunnel_forward", translate("Anti-pollution DNS Server"))
o:value("8.8.8.8:53", translate("Google Public DNS (8.8.8.8)"))
o:value("1.1.1.1:53", translate("Cloudflare DNS (1.1.1.1)"))
o:depends("dns_mode", "1")
o:depends("dns_mode", "2")
o.description = translate("Custom DNS Server format as IP:PORT")
o.datatype = "hostport"

return m

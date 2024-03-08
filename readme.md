# Wireshark Lua dissectors for GivEnergy Inverter

## Using the Dissector

Either copy `giv_dissector.lua` to your Wireshark plugins folder, or start wireshark (e.g. from Powershell) like this:
`& "c:\program files\wireshark\wireshark.exe" -X lua_script:giv_dissector.lua`


Protocol documented here: https://github.com/GivEnergy/giv_tcp/blob/main/givenergy_modbus/framer.py
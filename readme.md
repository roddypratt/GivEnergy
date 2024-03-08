# Wireshark Lua dissector for GivEnergy Inverter

A very basic dissector that decodes some of the GivEnergy Inverter protocol. Given the lack of propoer docs, It's a work in progress, and only decodes the protocol headers.

There's no attempt to decode register indices. 

By default traffic on ports 8899 (local) and 7654 (to AWS portal) is decoded.

## Using the Dissector

Either copy `giv_dissector.lua` to your Wireshark plugins folder, or start wireshark (e.g. from Powershell) like this:
`& "c:\program files\wireshark\wireshark.exe" -X lua_script:giv_dissector.lua`


Protocol 'documented' here: https://github.com/GivEnergy/giv_tcp/blob/main/givenergy_modbus/framer.py

![Example screenshot](/screenshot.png)
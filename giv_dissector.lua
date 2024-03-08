-- Create a new dissector
local GivEnergy = Proto("GivEnergy", "GivEnergy Modbus")


local f_tid = ProtoField.uint16("GivEnergy.tid", "tid", base.HEX);
local f_pid = ProtoField.uint16("GivEnergy.pid", "pid");
local f_uid = ProtoField.uint8("GivEnergy.uid", "uid");
local f_fid = ProtoField.uint8("GivEnergy.fid", "fid");

local f_len = ProtoField.uint16("GivEnergy.len", "len");
local f_serial = ProtoField.string("GivEnergy.serial", "Serial");
local f_pad = ProtoField.bytes("GivEnergy.pad", "Pad");
local f_addr = ProtoField.uint8("GivEnergy.addr", "addr");
local f_func = ProtoField.uint8("GivEnergy.func", "Func", base.HEX,
    {
        [3] = "Read Holding Registers",
        [4] = "Read Input Registers",
        [6] = "Write Single Register"
    });
local f_data = ProtoField.bytes("GivEnergy.data", "data");

local f_start = ProtoField.uint16("GivEnergy.start", "Start Reg.");
local f_count = ProtoField.uint16("GivEnergy.count", "Count");
local f_reg = ProtoField.uint16("GivEnergy.register", "Register");
local f_value = ProtoField.uint16("GivEnergy.value", "Value");

local f_crc = ProtoField.uint16("GivEnergy.crc", "crc");


local f_body = ProtoField.bytes("GivEnergy.body", "Body");

GivEnergy.fields = { f_tid, f_pid, f_len, f_uid, f_fid, f_serial, f_pad, f_addr, f_func, f_data, f_crc, f_body, f_start,
    f_count, f_reg, f_value };

function rangeChar(range, i)
    local r = range:range(i, 1)
    return r, r:uint()
end

function rangeWord(range, i)
    local r = range:range(i, 2)
    return r, r:uint()
end

local function starts_with(str, start) return str:sub(1, #start) == start end

function processPacket(tree, range)
    local hdr = tree:add(range(0, 8), "Header")

    hdr:add(f_tid, rangeWord(range, 0))
    hdr:add(f_pid, rangeWord(range, 2))
    hdr:add(f_len, rangeWord(range, 4))
    hdr:add(f_uid, rangeChar(range, 6))
    hdr:add(f_fid, rangeChar(range, 7))

    local main = tree:add(range(8, range:len() - 8), "Body")
    main:add(f_serial, range:range(8, 10))
    main:add(f_pad, range:range(18, 8))
    main:add(f_addr, rangeChar(range, 26))


    local func, val = rangeChar(range, 27)
    main:add(f_func, func, val)

    local data = range:range(28, range:len() - 30)
    main:add(f_data, data)

    local fLen = range(24, 2):uint()
    local base = 28
    if (val == 3 or val == 4) then
        if fLen >= 18 then
            main:add(f_serial, range:range(base, 10))
            base = base + 10
        end
        main:add(f_start, rangeWord(range, base))
        main:add(f_count, rangeWord(range, base + 2))
    elseif (val == 6) then
        if fLen == 18 then
            main:add(f_serial, range:range(base, 10))
            base = base + 10
        end
        main:add(f_reg, rangeWord(range, base))
        main:add(f_value, rangeWord(range, base + 2))
    else
    end
    main:add(f_crc, rangeWord(range, range:len() - 2))


    -- local body = range:range(8, range:len() - 8)
    -- tree:add(f_body, body)
end

-- Create the dissector function
function GivEnergy.dissector(tvb, pinfo, tree)
    -- Add protocol to the info column
    pinfo.cols.protocol = GivEnergy.name

    local p = 0
    while p < tvb:len() do
        local st, l = lookForPacket(tvb, tree, p)
        if l then
            p = st + l;
        else
            pinfo.desegment_offset = st
            pinfo.desegment_len = DESEGMENT_ONE_MORE_SEGMENT
            return
        end
    end
end

function lookForPacket(tvb, root_tree, startpos)
    local bytes = tvb:bytes();
    local len = bytes:len()

    local pktLen = tvb(4, 2):uint() + 6

    if (pktLen <= len) then
        local range = tvb:range(startpos, pktLen)
        processPacket(root_tree, range)
        return startpos, pktLen
    end
    return startpos -- end not found - keep looking
end

local tcp_port = DissectorTable.get("tcp.port")
tcp_port:add(8899, GivEnergy)
tcp_port:add(7654, GivEnergy)

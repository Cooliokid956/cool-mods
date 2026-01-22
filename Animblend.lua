local val = 0
local currOp = "add"
local ops = {
    ["inc"] = function(x) return x + val end,
    ["dec"] = function(x) return x - val end,
    ["mul"] = function(x) return x * val end,
    ["div"] = function(x) return x / val end
}
local OP = ops["inc"]
local noOp = {}

local function UNKNOWN(node)
    return "???"
end
local NONE
local function DRAW_LAYER(node)
    return ((node.flags >> 8) & 0xFF)
end
local function DRAW_LAYER_CAST(node)
    return DRAW_LAYER(node.node)
end
local function FROM_VEC3F(key)
    return function (node)
        local v = node[key]
        if v.x then v.x = OP(v.x) end
        if v.y then v.y = OP(v.y) end
        if v.z then v.z = OP(v.z) end
        return v.x..", "
             ..v.y..", "
             ..v.z
    end
end
local function FROM_VEC3S(key)
    return function (node)
        local v = node[key]
        if v.x then v.x = OP(v.x) end
        if v.y then v.y = OP(v.y) end
        if v.z then v.z = OP(v.z) end
        -- djui_chat_message_create(tostring(v._pointer)..":"..tostring(v._lot))
        return tonumber(string.format("%.0f", ((v.x or 0) * 180/32768)))..", "
             ..tonumber(string.format("%.0f", ((v.y or 0) * 180/32768)))..", "
             ..tonumber(string.format("%.0f", ((v.z or 0) * 180/32768)))
    end
end

local types = {
    [GRAPH_NODE_TYPE_ROOT                ] = { name = "NODE_SCREEN_AREA", fields = { "numEntries", "x", "y", "width", "height" } },
    [GRAPH_NODE_TYPE_ORTHO_PROJECTION    ] = { name = "NODE_ORTHO",       fields = { "scale" } },
    [GRAPH_NODE_TYPE_PERSPECTIVE         ] = { name = "CAMERA_FRUSTUM",   fields = { "fov", "near", "far" } },
    [GRAPH_NODE_TYPE_MASTER_LIST         ] = { name = "ZBUFFER",          fields = { function(node) return node.flags & GRAPH_RENDER_Z_BUFFER end } },
    [GRAPH_NODE_TYPE_START               ] = { name = "NODE_START",       fields = { NONE } },
    [GRAPH_NODE_TYPE_LEVEL_OF_DETAIL     ] = { name = "RENDER_RANGE",     fields = { "minDistance", "maxDistance" } },
    [GRAPH_NODE_TYPE_SWITCH_CASE         ] = { name = "SWITCH_CASE",      fields = { "numCases", UNKNOWN } },
    [GRAPH_NODE_TYPE_CAMERA              ] = { name = "CAMERA",           fields = { UNKNOWN, FROM_VEC3F("pos"), FROM_VEC3F("focus"), UNKNOWN } },
    [GRAPH_NODE_TYPE_TRANSLATION_ROTATION] = { name = "TRANSLATE_ROTATE", fields = { DRAW_LAYER_CAST, FROM_VEC3F("translation"), FROM_VEC3S("rotation") } },
    [GRAPH_NODE_TYPE_TRANSLATION         ] = { name = "TRANSLATE_NODE",   fields = { DRAW_LAYER_CAST, FROM_VEC3F("translation") } },
    [GRAPH_NODE_TYPE_ROTATION            ] = { name = "ROTATION_NODE",    fields = { DRAW_LAYER_CAST, FROM_VEC3S("rotation") } },
    [GRAPH_NODE_TYPE_OBJECT              ] = { name = "OBJECT",           fields = { NONE } }, -- is this even needed?
    [GRAPH_NODE_TYPE_ANIMATED_PART       ] = { name = "ANIMATED_PART",    fields = { DRAW_LAYER_CAST, FROM_VEC3F("translation"), UNKNOWN } },
    [GRAPH_NODE_TYPE_BILLBOARD           ] = { name = "BILLBOARD",        fields = { NONE } },
    [GRAPH_NODE_TYPE_DISPLAY_LIST        ] = { name = "DISPLAY_LIST",     fields = { DRAW_LAYER_CAST, UNKNOWN } },
    [GRAPH_NODE_TYPE_SCALE               ] = { name = "SCALE",            fields = { DRAW_LAYER_CAST, "scale" } },
    [GRAPH_NODE_TYPE_SHADOW              ] = { name = "SHADOW",           fields = { "shadowScale", "shadowSolidity", "shadowType" } },
    [GRAPH_NODE_TYPE_OBJECT_PARENT       ] = { name = "RENDER_OBJ",       fields = { NONE } }, -- is this even needed?
    [GRAPH_NODE_TYPE_GENERATED_LIST      ] = { name = "ASM",              fields = { "parameter", UNKNOWN } },
    [GRAPH_NODE_TYPE_BACKGROUND          ] = { name = "BACKGROUND",       fields = { "background", UNKNOWN  } },
    [GRAPH_NODE_TYPE_HELD_OBJ            ] = { name = "HELD_OBJECT",      fields = { "playerIndex", FROM_VEC3F("translation"), UNKNOWN } },
    [GRAPH_NODE_TYPE_CULLING_RADIUS      ] = { name = "CULLING_RADIUS",   fields = { "cullingRadius" } },
}

local immutable = {
    ["parameter"] = 1,
    ["numCases"] = 1,
    ["shadowScale"] = 1,
    ["shadowSolidity"] = 1,
    ["shadowType"] = 1,
    ["playerIndex"] = 1,
    ["scale"] = 1
}

local real = djui_chat_message_create
local t = 0
local indent = ""
djui_chat_message_create = function (msg)
    -- real(indent..msg)
    -- print(indent..msg)

    -- real(string.sub(indent..msg,17+4))
    -- print(string.sub(indent..msg,17+4))

    -- t = t + 1
    -- if t > 60 then return e..nil end
end

---@type GraphNode
local mnode

local currIndex
local animParts = {}
---@param m MarioState
hook_event(HOOK_MARIO_UPDATE, function (m)
    if m.playerIndex ~= 0 then return end
    if mnode ~= m.marioObj.header.gfx.sharedChild then
        djui_chat_message_create("new model!")
        mnode = m.marioObj.header.gfx.sharedChild

        currIndex = m.playerIndex
        animParts[currIndex] = {}
        traverse_node(mnode)
    end
end)

function traverse_children(node)
    ---@type GraphNode
    local child = node.children
    local firstChild = child
    if child then
        djui_chat_message_create("GEO_OPEN_NODE(),")
        indent = indent.."    "
    else return end
    local c = 1
    repeat
        local nodeType = types[child.type]
        local nodeCast = cast_graph_node(child)

        local s = "GEO_"..nodeType.name.."("
        for i, field in ipairs(nodeType.fields) do
            local value

            if type(field) == "function" then
                value = field(nodeCast)
            else value = nodeCast[field]
                if not noOp[nodeType.name] and not immutable[field] then
                    djui_chat_message_create(""..nodeCast[field])
                    nodeCast[field] = OP(nodeCast[field])
                    djui_chat_message_create(""..nodeCast[field])
                end
            end

            s = s..(value or "nil")
            if i ~= #nodeType.fields then
                s = s..", "
            end
        end
        s = s.."),"

        -- s = s.."                                                                                                                                                                                                                                                                                                                                    "
        -- s = s:sub(1, math.max(128-#indent, 0))
        -- s = s.." (child #"..c..", "..tostring(child._pointer)..":"..tostring(child._lot)..", "..tostring(nodeCast._pointer)..":"..tostring(nodeCast._lot)..")"

        -- for this mod
        if child.type == GRAPH_NODE_TYPE_ANIMATED_PART then
            table.insert(animParts[currIndex], nodeCast)
        end
        -- for this mod

        djui_chat_message_create(s)
        c = c + 1

        traverse_children(child)
        child = child.next
    until child == firstChild

    indent = indent:sub(5)
    djui_chat_message_create("GEO_CLOSE_NODE(),")
end

function traverse_node(node)
    djui_chat_message_create("GEO_"..types[node.type].name.."(),")
    traverse_children(node)
    djui_chat_message_create("GEO_END(),")
    val = 0
end

hook_chat_command("op", "set", function (msg)
    OP = ops[msg] or ops["add"]
    return true
end)
hook_chat_command("pop", "everything", function (msg)
    t = 0
    indent = ""
    val = tonumber(msg) or 0
    traverse_node(mnode)
    return true
end)

hook_chat_command("noop", "a type", function (msg)
    msg = msg:upper()
    local real
    for i, type in pairs(types) do
        if msg == type.name then
            real = 1
        end
    end
    if real then
        noOp[msg] = 1
    else djui_chat_message_create("doesn't exist!") end
    return true
end)

hook_chat_command("noop", "a type", function (msg)
    msg = msg:upper()
    noOp[msg] = nil
    return true
end)

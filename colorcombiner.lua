-- name: Color Combiner
-- description: Author: Cooliokid 956\n\nAllows multiple lighting mods to be used simultaneously. (You may need to remove incompatibility tags first)

local funcNames = {
    "lighting_dir",
    "lighting_color",
    "lighting_color_ambient",
    "vertex_color",
    "fog_color",
    "skybox_color"
}

local colorCache = {}

local function generate_set(i, name)
    local func = _G["set_"..name]
    local colors = { [0] = {}, {}, {} }
    colorCache[i] = { [0] = 255, 255, 255 }
    return function (index, value)
        if index < 0 or 2 < index then return end

        local channel = colors[index]
        channel[get_active_mod()] = value

        local calc = 255
        for _, color in pairs(channel) do
            calc = calc * color/255
        end
        func(index, calc)
        colorCache[i][index] = calc
    end
end

local function generate_get(i)
    return function (index)
        return colorCache[i][index]
    end
end

for i, name in ipairs(funcNames) do
    _G["set_"..name] = generate_set(i, name)
    _G["get_"..name] = generate_get(i)
end

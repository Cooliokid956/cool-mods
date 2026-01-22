-- name: Color Combiner (Old)
-- description: Author: Cooliokid 956\n\nUse when multiple mods you have enabled change lighting color.

local modLighting = { [0] = {}, {}, {} }

local real_lighting_color = set_lighting_color
function set_mod_lighting_color(index, value)
    if index < 0 or 2 < index then return end

    smlua_text_utils_course_name_replace(1, smlua_text_utils_course_name_get(1))
    local modIndex = smlua_text_utils_course_name_mod_index(1)

    modLighting[index][modIndex] = value

    local calc = 255
    for _, color in pairs(modLighting[index]) do
        calc = calc * color/255
    end
    real_lighting_color(index, calc)
end
_G.set_lighting_color = set_mod_lighting_color
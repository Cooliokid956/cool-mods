-- name: Uno

-- NOTES --
-- Deck: Cards are ordered like so (value face up):
-- [1] ->[[[[[[[]<- [#deck]

--- @class Card
--- @field color integer
--- @field type integer

-- Colors
local RED    = 1
local YELLOW = 2
local BLUE   = 3
local GREEN  = 4
-- local COLORS = 4
local colors = {
    "Red",
    "Yellow",
    "Blue",
    "Green"
}

-- Types
-- [0-9]              -- pairs, colored --
local SKIP      = 0xA
local REVERSE   = 0xB
local DRAW_TWO  = 0xC
local WILD      = 0xD -- lone, uncolored --
local DRAW_FOUR = 0xE
local types = {
[0]="Zero",
    "One",
    "Two",
    "Three",
    "Four",
    "Five",
    "Six",
    "Seven",
    "Eight",
    "Nine",
    "Skip",
    "Reverse",
    "Draw Two",
    "Wildcard",
    "Draw Four",
}

---@param t table
---@param c integer?
function table.shuffle(t,c)
    for _ = 1, c or 1 do
        for i = #t, 1, -1 do
            table.insert(t, math.random(i), table.remove(t))
        end
    end
end

--- @return Card[]
function new_deck()
    local deck = {}
    for type = 0, DRAW_TWO do
        for color = RED, GREEN do
            for i = 1, (type == 0) and 1 or 2 do
                table.insert(deck, { type = type, color = color })
                print("Generated a "..colors[color].." "..types[type]..".")
            end
        end
    end
    for type = WILD, DRAW_FOUR do
        for i = 1, 4 do
            table.insert(deck, { type = type, color = 0 })
            print("Generated a "..types[type]..".")
        end
    end

    return deck
end

local deck = new_deck()--; table.shuffle(deck, 3)
local discard = {}

local gPlayerHands = {}
for i = 0, MAX_PLAYERS-1 do
    gPlayerHands[i] = {}
end

--- @param deck table
--- @param hand table
--- @param c integer?
function draw_cards(deck, hand, c)
    for i = 1, c or 7 do
        table.insert(hand, table.remove(deck))
    end
end

function return_cards(deck, hand)
    for i = 1, #hand do
        table.insert(deck, 1, table.remove(hand, 1))
    end
end

--- @type Color[]
local color = {
[0]={ r =   0, g =   0, b =   0 },
    { r = 215, g =  38, b =   0 },
    { r = 236, g = 212, b =   7 },
    { r =   9, g =  86, b = 191 },
    { r =  55, g = 151, b =  17 }
}
local repl = {
[0xA]="S",
[0xB]="R",
[0xC]="+2",
[0xD]="W",
[0xE]="+4"
}

local cardWidth = 22*1.5
local cardHeight = 35*1.5
function render_card(card, x, y, s)
    local w = cardWidth*s
    local h = cardHeight*s
    local border = 3*s
    local color = color[card.color]

    djui_hud_set_color(color.r, color.g, color.b, 255)
    djui_hud_render_rect(x, y, w, h)

    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_render_rect(x+border, y+border, w-border*2, h-border*2)

    djui_hud_set_color(color.r, color.g, color.b, 255)
    djui_hud_set_font(FONT_SPECIAL)
    local t = repl[card.type] or (""..card.type)
    djui_hud_print_text(t, x+(w-djui_hud_measure_text(t)*s)/2, y+8*s, s)
end

function render_deck(deck, x, y, s, rowCards, padding)
    for i, card in ipairs(deck) do
        s = s or 1.5
        rowCards = rowCards or 7
        padding = padding or 3
        local subX = x + ((i-1) %rowCards)*(cardWidth-8)*s
        local subY = y + ((i-1)//rowCards)*(cardHeight+padding)*s

        render_card(card, subX, subY, s)
    end
end

local deckX
local deckY
hook_event(HOOK_ON_HUD_RENDER, function ()
    local c = gControllers[0]
    local hand = gPlayerHands[0]
    djui_hud_set_resolution(RESOLUTION_DJUI)
    if djui_hud_get_mouse_scroll_y() + (c.buttonDown & X_BUTTON) ~= 0 then
        table.shuffle(deck)
    end
    local x = djui_hud_get_mouse_x()
    local y = djui_hud_get_mouse_y()
    if c.buttonPressed & Z_TRIG ~= 0 then
        if #hand > 0 then
            return_cards(deck, hand)
            deckX = nil
            deckY = nil
        else
            draw_cards(deck, hand)
            deckX = x
            deckY = y
        end
    end
    render_deck(deck, (deckX or x), (deckY or y), 1.5, 16, 3)
    -- for i, card in ipairs(deck) do
    --     local s = 1.5
    --     local padding = 3
    --     local subX = (deckX or x) + ((i-1) %16)*(cardWidth-8)*s
    --     local subY = (deckY or y) + ((i-1)//16)*(cardHeight+padding)*s

    --     render_card(card, subX, subY, s)
    -- end

    render_deck(hand, x, y, 1.5, 7, 3)
    -- for i, card in ipairs(hand) do
    --     local s = 1.5
    --     local padding = 3
    --     local subX = x + ((i-1) %7)*(cardWidth-8)*s
    --     local subY = y + ((i-1)//7)*(cardHeight+padding)*s

    --     render_card(card, subX, subY, s)
    -- end
end)
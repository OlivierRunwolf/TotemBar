print("|cffffff00TotemBar:|r loading (v1.2)...")

local ELEMENTS = { "Fire", "Earth", "Air", "Water" }

local TOTEMS = {
    Fire = {
        "Searing Totem", "Magma Totem", "Fire Nova Totem",
        "Flametongue Totem", "Frost Resistance Totem", "Totem of Wrath",
    },
    Earth = {
        "Stoneskin Totem", "Stoneclaw Totem", "Strength of Earth Totem",
        "Tremor Totem", "Earthbind Totem", "Earth Elemental Totem",
    },
    Air = {
        "Windfury Totem", "Grace of Air Totem", "Grounding Totem",
        "Nature Resistance Totem", "Wrath of Air Totem", "Sentry Totem",
        "Tranquil Air Totem",
    },
    Water = {
        "Healing Stream Totem", "Mana Spring Totem", "Poison Cleansing Totem",
        "Disease Cleansing Totem", "Fire Resistance Totem", "Mana Tide Totem",
    },
}

local ELEMENT_COLOR = {
    Fire  = {1.0, 0.3, 0.1},
    Earth = {0.6, 0.4, 0.1},
    Air   = {0.7, 0.9, 1.0},
    Water = {0.1, 0.5, 1.0},
}

BINDING_HEADER_TOTEMBAR = "Totem Bar"
_G["BINDING_NAME_CLICK TotemBarButtonFire:LeftButton"]  = "Cast Fire totem"
_G["BINDING_NAME_CLICK TotemBarButtonEarth:LeftButton"] = "Cast Earth totem"
_G["BINDING_NAME_CLICK TotemBarButtonAir:LeftButton"]   = "Cast Air totem"
_G["BINDING_NAME_CLICK TotemBarButtonWater:LeftButton"] = "Cast Water totem"

local buttons = {}
local pendingAssign = {}
local menu

local Masque = LibStub and LibStub("Masque", true)
local masqueGroup = Masque and Masque:Group("TotemBar")

local function EnsureDB()
    TotemBarDB = TotemBarDB or {}
    TotemBarDB.assigned = TotemBarDB.assigned or {}
    for _, e in ipairs(ELEMENTS) do
        if not TotemBarDB.assigned[e] then
            TotemBarDB.assigned[e] = TOTEMS[e][1]
        end
    end
    TotemBarDB.point = TotemBarDB.point or { "CENTER", "UIParent", "CENTER", 0, -150 }
    TotemBarDB.templates = TotemBarDB.templates or {}
    TotemBarDB.scale = TotemBarDB.scale or 1.0
end

local SCALE_MIN, SCALE_MAX, SCALE_STEP = 0.4, 2.5, 0.05

local function ApplyScale(scale)
    scale = math.max(SCALE_MIN, math.min(SCALE_MAX, scale))
    TotemBarDB.scale = scale
    if TotemBarFrame then TotemBarFrame:SetScale(scale) end
    return scale
end

local function ApplySpell(btn, spell)
    btn:SetAttribute("type1", "spell")
    btn:SetAttribute("spell", spell)
    local _, _, icon = GetSpellInfo(spell)
    btn.icon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
end

local function AssignSpell(element, spell)
    TotemBarDB.assigned[element] = spell
    if InCombatLockdown() then
        pendingAssign[element] = spell
        print("|cffffff00TotemBar:|r will assign " .. spell .. " to " .. element .. " after combat.")
    else
        ApplySpell(buttons[element], spell)
    end
end

local function FlushPending()
    for element, spell in pairs(pendingAssign) do
        ApplySpell(buttons[element], spell)
    end
    wipe(pendingAssign)
end

local function SaveTemplate(name)
    local tpl = {}
    for _, e in ipairs(ELEMENTS) do
        tpl[e] = TotemBarDB.assigned[e]
    end
    TotemBarDB.templates[name] = tpl
    print("|cffffff00TotemBar:|r saved template '" .. name .. "'.")
end

local function LoadTemplate(name)
    local tpl = TotemBarDB.templates[name]
    if not tpl then
        print("|cffffff00TotemBar:|r no template named '" .. name .. "'. Try /tb list.")
        return
    end
    for _, e in ipairs(ELEMENTS) do
        if tpl[e] then AssignSpell(e, tpl[e]) end
    end
    print("|cffffff00TotemBar:|r loaded template '" .. name .. "'.")
end

local function DeleteTemplate(name)
    if TotemBarDB.templates[name] then
        TotemBarDB.templates[name] = nil
        print("|cffffff00TotemBar:|r deleted template '" .. name .. "'.")
    else
        print("|cffffff00TotemBar:|r no template named '" .. name .. "'.")
    end
end

local function ListTemplates()
    if not next(TotemBarDB.templates) then
        print("|cffffff00TotemBar:|r no templates saved. Use /tb save <name> to save the current set.")
        return
    end
    print("|cffffff00TotemBar templates:|r")
    for name, tpl in pairs(TotemBarDB.templates) do
        print(string.format("  %s - F:%s  E:%s  A:%s  W:%s",
            name, tpl.Fire or "-", tpl.Earth or "-", tpl.Air or "-", tpl.Water or "-"))
    end
end

local function HideMenu()
    if menu then menu:Hide() end
end

local function ShowMenu(element, anchorBtn)
    if not menu then
        menu = CreateFrame("Frame", "TotemBarMenu", UIParent, "BackdropTemplate")
        menu:SetFrameStrata("DIALOG")
        menu:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 16,
            insets = { left = 6, right = 6, top = 6, bottom = 6 },
        })
        menu:SetBackdropColor(0, 0, 0, 0.9)
        menu.items = {}
        menu.header = menu:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        menu.header:SetPoint("TOP", 0, -10)
        menu:SetScript("OnKeyDown", function(self, key)
            if key == "ESCAPE" then self:Hide() end
        end)
        menu:SetScript("OnShow", function(self) self:EnableKeyboard(true) end)
        menu:SetScript("OnHide", function(self) self:EnableKeyboard(false) end)
    end

    for _, item in ipairs(menu.items) do item:Hide() end

    local items = TOTEMS[element]
    local rowH, width = 32, 240
    local headerH = 26
    menu:SetSize(width, headerH + rowH * #items + 12)
    menu:ClearAllPoints()
    menu:SetPoint("BOTTOMLEFT", anchorBtn, "TOPLEFT", 0, 4)

    local r, g, b = unpack(ELEMENT_COLOR[element])
    menu.header:SetText(element .. " Totems")
    menu.header:SetTextColor(r, g, b)

    for i, spell in ipairs(items) do
        local item = menu.items[i]
        if not item then
            item = CreateFrame("Button", nil, menu)
            item:SetHeight(rowH)
            item.icon = item:CreateTexture(nil, "ARTWORK")
            item.icon:SetSize(28, 28)
            item.icon:SetPoint("LEFT", 4, 0)
            item.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            item.iconBorder = item:CreateTexture(nil, "BORDER")
            item.iconBorder:SetPoint("TOPLEFT", item.icon, "TOPLEFT", -1, 1)
            item.iconBorder:SetPoint("BOTTOMRIGHT", item.icon, "BOTTOMRIGHT", 1, -1)
            item.iconBorder:SetColorTexture(0, 0, 0, 1)
            item.text = item:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            item.text:SetPoint("LEFT", item.icon, "RIGHT", 8, 0)
            item.text:SetJustifyH("LEFT")
            item.hl = item:CreateTexture(nil, "HIGHLIGHT")
            item.hl:SetAllPoints()
            item.hl:SetColorTexture(1, 1, 1, 0.15)
            item.check = item:CreateTexture(nil, "OVERLAY")
            item.check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
            item.check:SetSize(20, 20)
            item.check:SetPoint("RIGHT", -6, 0)
            menu.items[i] = item
        end
        item:ClearAllPoints()
        item:SetPoint("TOPLEFT", menu, "TOPLEFT", 6, -headerH - (i - 1) * rowH)
        item:SetPoint("RIGHT", menu, "RIGHT", -6, 0)
        item.text:SetText(spell)

        local _, _, iconPath = GetSpellInfo(spell)
        item.icon:SetTexture(iconPath or "Interface\\Icons\\INV_Misc_QuestionMark")

        local known = GetSpellInfo(spell) ~= nil
        if known then
            item.text:SetTextColor(1, 1, 1)
            item.icon:SetDesaturated(false)
            item.icon:SetVertexColor(1, 1, 1)
        else
            item.text:SetTextColor(0.5, 0.5, 0.5)
            item.icon:SetDesaturated(true)
            item.icon:SetVertexColor(0.6, 0.6, 0.6)
        end

        if spell == TotemBarDB.assigned[element] then
            item.text:SetTextColor(1, 0.82, 0)
            item.check:Show()
        else
            item.check:Hide()
        end

        item:SetScript("OnClick", function()
            if not GetSpellInfo(spell) then
                print("|cffffff00TotemBar:|r You haven't learned " .. spell .. " yet.")
                return
            end
            AssignSpell(element, spell)
            HideMenu()
        end)
        item:Show()
    end
    menu:Show()
end

local function CreateBar()
    local frame = CreateFrame("Frame", "TotemBarFrame", UIParent, "BackdropTemplate")
    frame:SetSize(44 * 4 + 8, 48)
    frame:SetPoint(unpack(TotemBarDB.point))
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    frame:SetBackdropColor(0, 0, 0, 0.6)
    frame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    frame:SetScript("OnDragStart", function(self)
        if IsShiftKeyDown() then self:StartMoving() end
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local p, _, rp, x, y = self:GetPoint()
        TotemBarDB.point = { p, "UIParent", rp, x, y }
    end)

    frame:SetScale(TotemBarDB.scale)
    frame:EnableMouseWheel(true)
    frame:SetScript("OnMouseWheel", function(self, delta)
        if not IsShiftKeyDown() then return end
        ApplyScale((TotemBarDB.scale or 1.0) + delta * SCALE_STEP)
    end)

    for i, element in ipairs(ELEMENTS) do
        local btn = CreateFrame(
            "Button",
            "TotemBarButton" .. element,
            frame,
            "SecureActionButtonTemplate"
        )
        btn:SetSize(40, 40)
        btn:SetPoint("LEFT", frame, "LEFT", (i - 1) * 44 + 4, 0)
        btn:RegisterForClicks("AnyDown", "AnyUp")

        local r, g, b = unpack(ELEMENT_COLOR[element])
        local border = btn:CreateTexture(nil, "BACKGROUND")
        border:SetPoint("TOPLEFT", -2, 2)
        border:SetPoint("BOTTOMRIGHT", 2, -2)
        border:SetColorTexture(r, g, b, 1)

        btn.icon = btn:CreateTexture(nil, "ARTWORK")
        btn.icon:SetAllPoints()
        btn.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

        local pushed = btn:CreateTexture(nil, "ARTWORK")
        pushed:SetAllPoints()
        pushed:SetColorTexture(1, 1, 1, 0.25)
        btn:SetPushedTexture(pushed)

        local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetAllPoints()
        highlight:SetColorTexture(1, 1, 1, 0.2)
        btn:SetHighlightTexture(highlight)

        if masqueGroup then
            masqueGroup:AddButton(btn, {
                Icon = btn.icon,
                Pushed = pushed,
                Highlight = highlight,
            })
        end

        ApplySpell(btn, TotemBarDB.assigned[element])

        btn:HookScript("OnMouseUp", function(self, click)
            if click == "RightButton" then
                if menu and menu:IsShown() then HideMenu() else ShowMenu(element, self) end
            end
        end)

        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(TotemBarDB.assigned[element], 1, 1, 1)
            GameTooltip:AddLine(element .. " totem slot", 0.8, 0.8, 0.8)
            GameTooltip:AddLine("Right-click: change totem", 0.6, 0.6, 0.6)
            GameTooltip:AddLine("Shift-drag bar: move", 0.6, 0.6, 0.6)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

        buttons[element] = btn
    end

    return frame
end

-- Register slash commands FIRST so they always work even if something later errors.
SLASH_TOTEMBAR1 = "/totembar"
SLASH_TOTEMBAR2 = "/tbar"
SLASH_TOTEMBAR3 = "/tb"
SlashCmdList["TOTEMBAR"] = function(msg)
    msg = (msg or ""):match("^%s*(.-)%s*$")
    local cmd, arg = msg:match("^(%S+)%s+(.+)$")
    if cmd then
        arg = arg:match("^%s*(.-)%s*$")
    else
        cmd = msg
        arg = nil
    end
    cmd = cmd:lower()

    if cmd == "reset" then
        TotemBarDB.point = { "CENTER", "UIParent", "CENTER", 0, -150 }
        TotemBarFrame:ClearAllPoints()
        TotemBarFrame:SetPoint(unpack(TotemBarDB.point))
        print("|cffffff00TotemBar:|r position reset.")
    elseif cmd == "save" then
        if not arg or arg == "" then
            print("|cffffff00TotemBar:|r usage: /tb save <name>")
        else
            SaveTemplate(arg)
        end
    elseif cmd == "load" then
        if not arg or arg == "" then
            print("|cffffff00TotemBar:|r usage: /tb load <name>")
        else
            LoadTemplate(arg)
        end
    elseif cmd == "delete" or cmd == "del" or cmd == "rm" then
        if not arg or arg == "" then
            print("|cffffff00TotemBar:|r usage: /tb delete <name>")
        else
            DeleteTemplate(arg)
        end
    elseif cmd == "list" or cmd == "ls" then
        ListTemplates()
    elseif cmd == "scale" then
        local n = tonumber(arg)
        if not n then
            print(string.format("|cffffff00TotemBar:|r scale = %.2f (usage: /tb scale 0.4-2.5)", TotemBarDB.scale or 1.0))
        else
            local applied = ApplyScale(n)
            print(string.format("|cffffff00TotemBar:|r scale set to %.2f", applied))
        end
    else
        print("|cffffff00TotemBar|r commands (try /totembar, /tbar, or /tb):")
        print("  reset           - reset bar position to center")
        print("  scale <n>       - set scale (e.g. 0.8). Also Shift+mousewheel over the bar.")
        print("  save <name>     - save current 4 totems as a template")
        print("  load <name>     - apply a saved template")
        print("  list            - list saved templates")
        print("  delete <name>   - delete a saved template")
        print("Shift-drag the bar to move it. Right-click a slot to change totem.")
        print("Bind keys via Esc -> Key Bindings -> Totem Bar.")
        if Masque then
            print("Masque detected: theme the bar via /masque.")
        end
    end
end
print("|cffffff00TotemBar:|r slash commands registered: /totembar, /tbar, /tb")

local ok, err = pcall(function()
    EnsureDB()
    CreateBar()
end)
if ok then
    print("|cff00ff00TotemBar:|r ready. Bar is at center-screen. Type /tb for help.")
else
    print("|cffff0000TotemBar ERROR:|r " .. tostring(err))
end

local function ReapplyFromDB(reason)
    if not TotemBarFrame then
        print("|cffff9999TotemBar DBG:|r ReapplyFromDB(" .. tostring(reason) .. ") skipped - TotemBarFrame nil")
        return
    end
    EnsureDB()
    local count = 0
    for _ in pairs(buttons) do count = count + 1 end
    print(string.format(
        "|cffff9999TotemBar DBG:|r Reapply(%s) buttons=%d Earth=%s Fire=%s Water=%s Air=%s",
        tostring(reason), count,
        tostring(TotemBarDB.assigned.Earth),
        tostring(TotemBarDB.assigned.Fire),
        tostring(TotemBarDB.assigned.Water),
        tostring(TotemBarDB.assigned.Air)
    ))
    TotemBarFrame:ClearAllPoints()
    TotemBarFrame:SetPoint(unpack(TotemBarDB.point))
    TotemBarFrame:SetScale(TotemBarDB.scale or 1.0)
    for element, btn in pairs(buttons) do
        ApplySpell(btn, TotemBarDB.assigned[element])
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("LEARNED_SPELL_IN_TAB")
f:RegisterEvent("SPELLS_CHANGED")
f:SetScript("OnEvent", function(_, event, arg1)
    if event == "PLAYER_REGEN_ENABLED" then
        FlushPending()
    elseif event == "ADDON_LOADED" then
        if arg1 == "TotemBar" then ReapplyFromDB("ADDON_LOADED") end
    else
        ReapplyFromDB(event)
    end
end)

print("|cffff9999TotemBar DBG:|r reached event setup; C_Timer type = " .. type(C_Timer))

if C_Timer and C_Timer.After then
    C_Timer.After(2, function() ReapplyFromDB("timer-2s") end)
    print("|cffff9999TotemBar DBG:|r scheduled C_Timer.After(2)")
end

print("|cffff9999TotemBar DBG:|r module load complete")

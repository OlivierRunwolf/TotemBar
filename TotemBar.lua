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

local function EnsureDB()
    TotemBarDB = TotemBarDB or {}
    TotemBarDB.assigned = TotemBarDB.assigned or {}
    for _, e in ipairs(ELEMENTS) do
        if not TotemBarDB.assigned[e] then
            TotemBarDB.assigned[e] = TOTEMS[e][1]
        end
    end
    TotemBarDB.point = TotemBarDB.point or { "CENTER", "UIParent", "CENTER", 0, -150 }
end

local function ApplySpell(btn, spell)
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

    for i, element in ipairs(ELEMENTS) do
        local btn = CreateFrame(
            "Button",
            "TotemBarButton" .. element,
            frame,
            "SecureActionButtonTemplate,ActionButtonTemplate"
        )
        btn:SetSize(40, 40)
        btn:SetPoint("LEFT", frame, "LEFT", (i - 1) * 44 + 4, 0)
        btn:RegisterForClicks("AnyDown", "AnyUp")
        btn:SetAttribute("type1", "spell")
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

        local r, g, b = unpack(ELEMENT_COLOR[element])
        if btn.NormalTexture then btn.NormalTexture:SetVertexColor(r, g, b) end

        buttons[element] = btn
    end

    return frame
end

local ok, err = pcall(function()
    EnsureDB()
    CreateBar()
end)
if ok then
    print("|cff00ff00TotemBar:|r ready. Bar is at center-screen. Type /tb for help.")
else
    print("|cffff0000TotemBar ERROR:|r " .. tostring(err))
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("LEARNED_SPELL_IN_TAB")
f:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_ENABLED" then
        FlushPending()
    elseif event == "LEARNED_SPELL_IN_TAB" then
        for element, btn in pairs(buttons) do
            ApplySpell(btn, TotemBarDB.assigned[element])
        end
    end
end)

SLASH_TOTEMBAR1 = "/totembar"
SLASH_TOTEMBAR2 = "/tbar"
SLASH_TOTEMBAR3 = "/tb"
SlashCmdList["TOTEMBAR"] = function(msg)
    msg = (msg or ""):lower():match("^%s*(.-)%s*$")
    if msg == "reset" then
        TotemBarDB.point = { "CENTER", "UIParent", "CENTER", 0, -150 }
        TotemBarFrame:ClearAllPoints()
        TotemBarFrame:SetPoint(unpack(TotemBarDB.point))
        print("|cffffff00TotemBar:|r position reset.")
    else
        print("|cffffff00TotemBar|r commands (try /totembar, /tbar, or /tb):")
        print("  reset - reset bar position to center")
        print("Shift-drag the bar to move it. Right-click a slot to change totem.")
        print("Bind keys via Esc -> Key Bindings -> Totem Bar.")
    end
end
print("|cffffff00TotemBar:|r slash commands registered: /totembar, /tbar, /tb")

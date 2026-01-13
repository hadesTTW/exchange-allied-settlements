local eas_mod = {}
local cm = get_cm()
local core = get_core()

-- Constants
local PANEL_PATH = "ui/campaign ui/ally_exchange_panel.twui.xml"
local PANEL_NAME = "ally_exchange_panel"
local DROPDOWN_TEMPLATE = "ui/templates/ally_dropdown_context.twui.xml"
local BUTTON_TEMPLATE = "ui/templates/round_small_button.twui.xml"

-- Localization (Fallback table, primary is .loc file)
local L = {
    title = "Exchange Allied Settlements",
    giver_label = "Giver:",
    region_label = "Region:",
    receiver_label = "Receiver:",
    select_ally = "Select Ally...",
    select_region = "Select Settlement...",
    select_receiver = "Select Receiver...",
    confirm = "Confirm",
    cancel = "Cancel",
    tooltip_open = "Exchange Allied Settlements||Open the Allied Settlement Exchange Menu"
}

-- Helper: Get Localised String with Fallback
local function get_loc(key)
    local loc_key = "ally_exchange_" .. key
    local text = common.get_localised_string(loc_key)
    if text == "" then
        return L[key] or key
    end
    return text
end

-- State
local selected_giver_key = nil
local selected_region_cqi = nil
local selected_receiver_key = nil

-- UI Component References
local uic_panel = nil
local uic_giver_btn = nil
local uic_giver_txt = nil
local uic_region_btn = nil
local uic_region_txt = nil
local uic_receiver_btn = nil
local uic_receiver_txt = nil
local uic_ok_btn = nil

-- Helper: Check if two factions are allies (Defensive, Military, or Vassal)
local function are_allies(faction1, faction2)
    if faction1:name() == faction2:name() then return false end
    
    if faction1:allied_with(faction2) then return true end
    if faction1:is_vassal_of(faction2) then return true end
    if faction2:is_vassal_of(faction1) then return true end
    
    return false
end

-- Helper: Get list of allies for the player
local function get_player_allies()
    local player_faction = cm:get_faction(cm:get_local_faction_name(true))
    local allies = {}
    local faction_list = cm:model():world():faction_list()
    
    for i = 0, faction_list:num_items() - 1 do
        local current_faction = faction_list:item_at(i)
        if not current_faction:is_dead() and are_allies(player_faction, current_faction) then
            table.insert(allies, current_faction)
        end
    end
    
    -- Sort by name
    table.sort(allies, function(a, b) return a:name() < b:name() end)
    return allies
end

-- Function: Init
function eas_mod:init()
    -- Initial setup if needed
end

-- Function: Create Top Left Button
local function create_top_button()
    local ui_root = core:get_ui_root()
    local buttongroup = find_uicomponent(ui_root, "menu_bar", "buttongroup")
    if not buttongroup then return end

    local eas_button = find_uicomponent(buttongroup, "eas_panel_button")
    if not eas_button then
        eas_button = core:get_or_create_component("eas_panel_button", BUTTON_TEMPLATE, buttongroup)
        -- Use a generic diplomacy icon
        eas_button:SetImagePath("ui/campaign ui/diplomacy_icons/diplomatic_option_military_alliance.png", 0, false)
        eas_button:SetVisible(true)
        eas_button:Resize(38, 38)
        eas_button:SetTooltipText(get_loc("title"), get_loc("tooltip_open"), true)
    end

    -- Listener for Top Button
    core:remove_listener("eas_button_click")
    core:add_listener(
        "eas_button_click",
        "ComponentLClickUp",
        function(context) return context.string == "eas_panel_button" end,
        function() eas_mod:toggle_panel() end,
        true
    )
end

-- Function: Toggle Panel
function eas_mod:toggle_panel()
    local ui_root = core:get_ui_root()
    uic_panel = find_uicomponent(ui_root, PANEL_NAME)
    
    if uic_panel then
        if uic_panel:Visible() then
            uic_panel:SetVisible(false)
            eas_mod:close_all_dropdowns()
        else
            eas_mod:reset_state()
            uic_panel:SetVisible(true)
            eas_mod:refresh_ui()
        end
    else
        eas_mod:create_panel()
    end
end

-- Function: Reset State
function eas_mod:reset_state()
    selected_giver_key = nil
    selected_region_cqi = nil
    selected_receiver_key = nil
end

-- Function: Create Panel
function eas_mod:create_panel()
    local ui_root = core:get_ui_root()
    uic_panel = core:get_or_create_component(PANEL_NAME, PANEL_PATH, ui_root)
    uic_panel:SetVisible(true)
    
    -- Find references
    local panel_frame = find_uicomponent(uic_panel, "panel_frame")
    uic_giver_btn = find_uicomponent(panel_frame, "button_select_giver")
    uic_giver_txt = find_uicomponent(uic_giver_btn, "tx_select_giver")
    
    uic_region_btn = find_uicomponent(panel_frame, "button_select_region")
    uic_region_txt = find_uicomponent(uic_region_btn, "tx_select_region")
    
    uic_receiver_btn = find_uicomponent(panel_frame, "button_select_receiver")
    uic_receiver_txt = find_uicomponent(uic_receiver_btn, "tx_select_receiver")
    
    local btn_ok_frame = find_uicomponent(panel_frame, "button_ok_frame")
    uic_ok_btn = find_uicomponent(btn_ok_frame, "button_ok")
    
    -- Set static labels
    local header = find_uicomponent(panel_frame, "header")
    if header then
        local tx_header = find_uicomponent(header, "tx_header")
        if tx_header then tx_header:SetStateText(get_loc("title")) end
    end
    
    local tx_giver = find_uicomponent(panel_frame, "tx_giver_label")
    if tx_giver then tx_giver:SetStateText(get_loc("giver_label")) end
    
    local tx_region = find_uicomponent(panel_frame, "tx_region_label")
    if tx_region then tx_region:SetStateText(get_loc("region_label")) end
    
    local tx_receiver = find_uicomponent(panel_frame, "tx_receiver_label")
    if tx_receiver then tx_receiver:SetStateText(get_loc("receiver_label")) end
    
    -- Setup Listeners for Panel Buttons
    core:add_listener(
        "eas_panel_buttons",
        "ComponentLClickUp",
        function(context) return true end,
        function(context)
            local id = context.string
            if id == "button_select_giver" then
                eas_mod:show_dropdown("giver")
            elseif id == "button_select_region" then
                if selected_giver_key then
                    eas_mod:show_dropdown("region")
                end
            elseif id == "button_select_receiver" then
                if selected_giver_key and selected_region_cqi then
                    eas_mod:show_dropdown("receiver")
                end
            elseif id == "button_ok" then
                eas_mod:attempt_transfer()
            elseif id == "button_cancel" then
                uic_panel:SetVisible(false)
                eas_mod:close_all_dropdowns()
            end
        end,
        true
    )
    
    eas_mod:refresh_ui()
end

-- Function: Refresh UI Texts
function eas_mod:refresh_ui()
    if not uic_giver_txt then return end
    
    if selected_giver_key then
        uic_giver_txt:SetStateText(common.get_localised_string("factions_screen_name_" .. selected_giver_key))
    else
        uic_giver_txt:SetStateText(get_loc("select_ally"))
    end
    
    if selected_region_cqi then
        local region = cm:get_region_by_cqi(selected_region_cqi)
        if region then
            uic_region_txt:SetStateText(common.get_localised_string("regions_onscreen_" .. region:name()))
        else
            uic_region_txt:SetStateText(get_loc("select_region"))
        end
    else
        uic_region_txt:SetStateText(get_loc("select_region"))
    end
    
    if selected_receiver_key then
        uic_receiver_txt:SetStateText(common.get_localised_string("factions_screen_name_" .. selected_receiver_key))
    else
        uic_receiver_txt:SetStateText(get_loc("select_receiver"))
    end
    
    -- Update Confirm Button State
    if uic_ok_btn then
        if selected_giver_key and selected_region_cqi and selected_receiver_key then
            uic_ok_btn:SetState("active")
        else
            uic_ok_btn:SetState("inactive")
        end
    end
end

-- Function: Close all dropdowns
function eas_mod:close_all_dropdowns()
    local ui_root = core:get_ui_root()
    local dd = find_uicomponent(ui_root, "eas_dropdown_menu")
    if dd then
        dd:Destroy()
    end
end

-- Function: Show Dropdown
function eas_mod:show_dropdown(type)
    eas_mod:close_all_dropdowns()
    
    local parent = nil
    if type == "giver" then parent = uic_giver_btn
    elseif type == "region" then parent = uic_region_btn
    elseif type == "receiver" then parent = uic_receiver_btn
    end
    
    if not parent then return end
    
    local panel_frame = find_uicomponent(uic_panel, "panel_frame")
    -- We attach to panel_frame so it draws on top of panel, but we might need to handle z-order.
    -- Actually, if we attach to root it's safer for z-order.
    local ui_root = core:get_ui_root()
    local dropdown = core:get_or_create_component("eas_dropdown_menu", DROPDOWN_TEMPLATE, ui_root)
    
    -- Position it relative to the button
    local bx, by = parent:Position()
    dropdown:MoveTo(bx, by + 40) -- Just below the button
    dropdown:SetVisible(true)
    
    -- Traverse to find list_box (Nested in Template)
    local context_up = find_uicomponent(dropdown, "dropdown_context_up")
    local listview = find_uicomponent(context_up, "listview")
    local list_clip = find_uicomponent(listview, "list_clip")
    local list_box = find_uicomponent(list_clip, "list_box")
    
    if not list_box then
        -- Error handling
        out("EAS Mod: Could not find list_box in dropdown template")
        return
    end
    
    local template_entry = find_uicomponent(list_box, "template_dropdown_entry")
    if not template_entry then
        out("EAS Mod: Could not find template_dropdown_entry")
        return
    end
    template_entry:SetVisible(false)
    
    if type == "giver" then
        local allies = get_player_allies()
        for i, ally in ipairs(allies) do
            local entry = template_entry:CopyComponent("entry_giver_" .. ally:name())
            entry:SetVisible(true)
            local tx = find_uicomponent(entry, "row_tx")
            tx:SetStateText(common.get_localised_string("factions_screen_name_" .. ally:name()))
        end
    elseif type == "region" then
        local giver = cm:get_faction(selected_giver_key)
        local region_list = giver:region_list()
        local regions = {}
        for i = 0, region_list:num_items() - 1 do
            local region = region_list:item_at(i)
            table.insert(regions, region)
        end
        -- Sort regions by name
        table.sort(regions, function(a, b) return a:name() < b:name() end)
        
        for _, region in ipairs(regions) do
            local entry = template_entry:CopyComponent("entry_region_" .. region:cqi())
            entry:SetVisible(true)
            local tx = find_uicomponent(entry, "row_tx")
            tx:SetStateText(common.get_localised_string("regions_onscreen_" .. region:name()))
        end
    elseif type == "receiver" then
        local allies = get_player_allies()
        for i, ally in ipairs(allies) do
            if ally:name() ~= selected_giver_key then
                local entry = template_entry:CopyComponent("entry_receiver_" .. ally:name())
                entry:SetVisible(true)
                local tx = find_uicomponent(entry, "row_tx")
                tx:SetStateText(common.get_localised_string("factions_screen_name_" .. ally:name()))
            end
        end
    end
    
    -- Listener for Dropdown Entries
    core:remove_listener("eas_dropdown_select")
    core:add_listener(
        "eas_dropdown_select",
        "ComponentLClickUp",
        function(context) 
            return string.find(context.string, "entry_") ~= nil 
        end,
        function(context)
            local id = context.string
            if string.find(id, "entry_giver_") then
                local key = string.sub(id, 13)
                selected_giver_key = key
                selected_region_cqi = nil
                selected_receiver_key = nil
            elseif string.find(id, "entry_region_") then
                local cqi = string.sub(id, 14)
                selected_region_cqi = tonumber(cqi)
            elseif string.find(id, "entry_receiver_") then
                local key = string.sub(id, 16)
                selected_receiver_key = key
            end
            
            eas_mod:refresh_ui()
            eas_mod:close_all_dropdowns()
        end,
        true
    )
end

-- Function: Attempt Transfer
function eas_mod:attempt_transfer()
    if selected_giver_key and selected_region_cqi and selected_receiver_key then
        local giver_faction = cm:get_faction(selected_giver_key)
        local receiver_faction = cm:get_faction(selected_receiver_key)
        local player_faction = cm:get_faction(cm:get_local_faction_name(true))
        
        -- Validate alliances (User Requirement: Both must be player allies. Their relationship to each other is irrelevant.)
        if not are_allies(player_faction, giver_faction) or not are_allies(player_faction, receiver_faction) then
             -- Alliance broken while menu was open
             return
        end

        -- Execute Transfer
        local region = cm:get_region_by_cqi(selected_region_cqi)
        if region then
            -- Verify ownership didn't change while menu was open
            if region:owning_faction():name() == selected_giver_key then
                cm:transfer_region_to_faction(region:name(), selected_receiver_key)
                
                -- Close panel
                uic_panel:SetVisible(false)
                eas_mod:close_all_dropdowns()
                eas_mod:reset_state()
            else
                -- Error: Region owner changed
            end
        end
    end
end

-- Initialization
cm:add_first_tick_callback(function()
    eas_mod:init()
    create_top_button()
end)

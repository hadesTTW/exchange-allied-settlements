local eas_mod = {}

local PANEL_NAME = "ally_exchange_panel"
local PANEL_PATH = "ui/campaign ui/ally_exchange_panel.twui.xml"
local BUTTON_TEMPLATE = "ui/templates/round_small_button.twui.xml"

-- Helper for logging
local function log(text)
    out("EAS_MOD: " .. tostring(text))
end

-- Helper to find component safely
local function find_uicomponent_safe(parent, name)
    if not parent then return nil end
    local comp = find_uicomponent(parent, name)
    return comp
end

-------------------------------------------------------------------------------------------------
-- INITIALIZATION
-------------------------------------------------------------------------------------------------

function eas_mod:init()
    log("init called")
    
    -- Create the top-left menu button
    eas_mod:create_top_button()
    
    -- Pre-load the panel (hidden)
    eas_mod:create_panel()
end

-------------------------------------------------------------------------------------------------
-- TOP BUTTON CREATION
-------------------------------------------------------------------------------------------------

function eas_mod:create_top_button()
    log("Creating top button...")
    local ui_root = core:get_ui_root()
    if not ui_root then return end

    -- Find the button group in the top menu bar
    local buttongroup = find_uicomponent(ui_root, "menu_bar", "buttongroup")
    if not buttongroup then 
        log("menu_bar > buttongroup not found")
        return 
    end

    -- Check if button already exists
    local eas_button = find_uicomponent(buttongroup, "eas_panel_button")
    
    if not eas_button then
        -- Create the button using a template
        eas_button = core:get_or_create_component("eas_panel_button", BUTTON_TEMPLATE, buttongroup)
        
        if eas_button then
            -- Set icon (using a generic trade/diplomacy icon)
            eas_button:SetImagePath("ui/campaign ui/diplomacy_icons/diplomatic_option_military_alliance.png", 0, false)
            eas_button:SetVisible(true)
            eas_button:Resize(38, 38)
            eas_button:SetTooltipText("Exchange Allied Settlements", "Open the Settlement Exchange panel", true)
            log("Button created successfully")
        else
            log("Failed to create button component")
            return
        end
    end

    -- Add listener for click
    core:remove_listener("eas_button_click")
    core:add_listener(
        "eas_button_click",
        "ComponentLClickUp",
        function(context) return context.string == "eas_panel_button" end,
        function() eas_mod:toggle_panel() end,
        true
    )
end

-------------------------------------------------------------------------------------------------
-- PANEL CREATION & MANAGEMENT
-------------------------------------------------------------------------------------------------

function eas_mod:create_panel()
    log("Creating panel...")
    local ui_root = core:get_ui_root()
    
    -- Create the main panel component from the XML file
    local uic_panel = core:get_or_create_component(PANEL_NAME, PANEL_PATH, ui_root)
    
    if not uic_panel then
        log("Failed to create uic_panel from " .. PANEL_PATH)
        return
    end
    
    -- Ensure it starts hidden
    uic_panel:SetVisible(false)
    
    -- Try to find the inner frame to verify XML loaded correctly
    local panel_frame = find_uicomponent_safe(uic_panel, "panel_frame")
    
    if not panel_frame then
        -- Fallback: try finding it by path if uic_panel is just a wrapper
        panel_frame = find_uicomponent(uic_panel, "ally_exchange_panel", "panel_frame")
    end
    
    if panel_frame then
        log("Panel frame found. XML structure seems valid.")
        
        -- Try to find and hook up the Cancel/Close button if it exists
        -- Note: We check both 'button_cancel' and 'button_ok' as potential close candidates for this dummy version
        local btn_cancel = find_uicomponent_safe(panel_frame, "button_cancel")
        if not btn_cancel then
             -- Try inside a frame if it exists
             btn_cancel = find_uicomponent(panel_frame, "button_cancel_frame", "button_cancel")
        end
        
        if btn_cancel then
            core:remove_listener("eas_panel_close")
            core:add_listener(
                "eas_panel_close",
                "ComponentLClickUp",
                function(context) return context.string == "button_cancel" end,
                function() 
                    uic_panel:SetVisible(false) 
                end,
                true
            )
        end
    else
        log("WARNING: panel_frame not found. The panel might appear blank.")
    end
    
    eas_mod.uic_panel = uic_panel
end

function eas_mod:toggle_panel()
    if not eas_mod.uic_panel then
        eas_mod:create_panel()
    end
    
    if eas_mod.uic_panel then
        local is_visible = eas_mod.uic_panel:Visible()
        eas_mod.uic_panel:SetVisible(not is_visible)
        log("Panel visibility toggled to: " .. tostring(not is_visible))
    end
end

-------------------------------------------------------------------------------------------------
-- MAIN ENTRY POINT
-------------------------------------------------------------------------------------------------

cm:add_first_tick_callback(function() 
    eas_mod:init() 
end)

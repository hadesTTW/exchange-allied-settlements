local EASMod = {}
local root = EASMod.root

local EAS_selected_faction = nil
local EAS_find_factions = false
local EAS_ai_min_region = nil
local EAS_trade_current_player = nil
local EAS_giver_faction = nil
local EAS_receiver_faction = nil
local EAS_selected_region = nil
local EAS_allow_player_cities = false


local function EAS_read_mct_settings()
    EAS_allow_player_cities = false
    if get_mct ~= nil then
        local ok, mct_obj = pcall(get_mct)
        if ok and mct_obj then
            local mct_mod = mct_obj:get_mod_by_key("exchange_allied_settlements")
            if mct_mod then
                local option = mct_mod:get_option_by_key("allow_player_cities")
                if option then
                    local value = option:get_finalized_setting()
                    if type(value) == "boolean" then
                        EAS_allow_player_cities = value
                    end
                end
            end
        end
    end
end


-- Create the trade settlements menu
local function EAS_trade_menu_creation_initiate()
	local EAS_factions_var = {}
	EAS_selected_faction = nil
	EAS_find_factions = false
	EAS_trade_current_player = cm:get_local_faction(true)
    
    EAS_read_mct_settings()
	
    
    -- Set default modifiers
    EAS_ai_min_region = "0"
    
    -- Create the core of the menu from an existing xml
    EASMod.EAS_trade_panel = core:get_or_create_component("EAS_trade_panel","ui/campaign ui/EAS_main_trade_screen.twui.xml", root)
    
    EASMod.EAS_trade_panel_frame = find_child_uicomponent(EASMod.EAS_trade_panel,"panel_frame")
    --local EAS_trade_panel_frame_width = EASMod.EAS_trade_panel_frame:Width()
    EASMod.EAS_trade_panel_frame:SetCanResizeWidth(true)
    EASMod.EAS_trade_panel_frame:SetCanResizeHeight(true)
    EASMod.EAS_trade_panel_frame:Resize(1100, 600)
    EASMod.EAS_trade_panel_frame:SetDockingPoint(5)

    -- Destroy unused elements of the menu
	EASMod.EAS_trade_panel_frame_fullscreen_underlay = find_child_uicomponent(EASMod.EAS_trade_panel,"fullscreen_underlay")
	EASMod.EAS_trade_panel_frame_fullscreen_underlay:Destroy()

	EASMod.EAS_trade_panel_frame_fullscreen_overlay = find_child_uicomponent(EASMod.EAS_trade_panel_frame,"fullscreen_overlay")
	EASMod.EAS_trade_panel_frame_fullscreen_overlay:Destroy()

	EASMod.EAS_trade_panel_frame_temples_list = find_child_uicomponent(EASMod.EAS_trade_panel_frame,"temples_list")
	EASMod.EAS_trade_panel_frame_temples_list:Destroy()

	EASMod.EAS_trade_panel_frame_prestige_holder = find_child_uicomponent(EASMod.EAS_trade_panel_frame,"prestige_holder")
	EASMod.EAS_trade_panel_frame_prestige_holder:Destroy()

	EASMod.EAS_trade_panel_frame_info_button = find_child_uicomponent(EASMod.EAS_trade_panel_frame,"button_info")
	EASMod.EAS_trade_panel_frame_info_button:SetVisible(false)

	EASMod.EAS_trade_panel_frame_ok_button = find_child_uicomponent(EASMod.EAS_trade_panel_frame,"button_ok_frame")
	EASMod.EAS_trade_panel_frame_ok_button:SetVisible(false)
    
    -- Create each elements of the interface
	EASMod.EAS_trade_panel_header = find_child_uicomponent(EASMod.EAS_trade_panel_frame,"header")
	EASMod.EAS_trade_panel_title_text = find_child_uicomponent(EASMod.EAS_trade_panel_header,"tx_header")
    EASMod.EAS_trade_panel_title_text:SetTextHAlign("centre")
    EASMod.EAS_trade_panel_title_text:SetTextXOffset(0,0)
	EASMod.EAS_trade_panel_title_text:SetTextYOffset(0,0)
	EASMod.EAS_trade_panel_title_text:SetDockOffset(0,0)
    EASMod.EAS_trade_panel_title_text:SetCanResizeWidth(true)
    EASMod.EAS_trade_panel_title_text:SetCanResizeHeight(true)
    EASMod.EAS_trade_panel_title_text:Resize(650,65)
	EASMod.EAS_trade_panel_title_text:SetStateText(common.get_localised_string("EAS_trade_panel_title_text_loc"))

    EASMod.EAS_trade_panel_title_text:CopyComponent("EAS_trade_panel_desc")
    EASMod.EAS_trade_panel_desc = find_child_uicomponent(EASMod.EAS_trade_panel_header,"EAS_trade_panel_desc")
    EASMod.EAS_trade_panel_desc:SetDockOffset(-400,250)
    EASMod.EAS_trade_panel_desc:Resize(150,150)
    EASMod.EAS_trade_panel_desc:SetVisible(false)
    EASMod.EAS_trade_panel_desc:SetCurrentStateImageOpacity(0, 0)
	
	EASMod.EAS_trade_panel_title_text:CopyComponent("EAS_trade_their_settlements")
    EASMod.EAS_trade_their_settlements = find_child_uicomponent(EASMod.EAS_trade_panel_header,"EAS_trade_their_settlements")
    EASMod.EAS_trade_their_settlements:SetDockOffset(400,250)
    EASMod.EAS_trade_their_settlements:Resize(150,150)
    EASMod.EAS_trade_their_settlements:SetVisible(false)
    EASMod.EAS_trade_their_settlements:SetStateText("")
    EASMod.EAS_trade_their_settlements:SetCurrentStateImageOpacity(0, 0)
	
	EASMod.EAS_trade_panel_title_text:CopyComponent("EAS_trade_deal")
    EASMod.EAS_trade_deal = find_child_uicomponent(EASMod.EAS_trade_panel_header,"EAS_trade_deal")
    EASMod.EAS_trade_deal:SetDockOffset(0,50)
    EASMod.EAS_trade_deal:Resize(150,150)
    EASMod.EAS_trade_deal:SetVisible(false)
    EASMod.EAS_trade_deal:SetStateText(common.get_localised_string("EAS_trade_deal_loc"))
    EASMod.EAS_trade_deal:SetCurrentStateImageOpacity(0, 0)

    EASMod.EAS_trade_panel_title_text:CopyComponent("EAS_trade_deal_details_desc")
    EASMod.EAS_trade_deal_details_desc = find_child_uicomponent(EASMod.EAS_trade_panel_header,"EAS_trade_deal_details_desc")
    EASMod.EAS_trade_deal_details_desc:SetDockOffset(0,200)
    EASMod.EAS_trade_deal_details_desc:Resize(500,100)
    EASMod.EAS_trade_deal_details_desc:SetVisible(false)
    EASMod.EAS_trade_deal_details_desc:SetCurrentStateImageOpacity(0, 0)
    EASMod.EAS_trade_deal_details_desc:SetStateText("")
    
    EASMod.EAS_trade_panel_title_text:CopyComponent("EAS_trade_giving_ally_label")
    EASMod.EAS_trade_giving_ally_label = find_child_uicomponent(EASMod.EAS_trade_panel_header,"EAS_trade_giving_ally_label")
    EASMod.EAS_trade_giving_ally_label:SetDockingPoint(5)
    EASMod.EAS_trade_giving_ally_label:SetDockOffset(-350,50)
    EASMod.EAS_trade_giving_ally_label:SetCanResizeWidth(true)
    EASMod.EAS_trade_giving_ally_label:SetCanResizeHeight(true)
    EASMod.EAS_trade_giving_ally_label:Resize(200,50)
    EASMod.EAS_trade_giving_ally_label:SetTextHAlign("centre")
    EASMod.EAS_trade_giving_ally_label:SetCurrentStateImageOpacity(0, 0)
    EASMod.EAS_trade_giving_ally_label:SetStateText(common.get_localised_string("EAS_trade_panel_giving_ally_loc"))

    EASMod.EAS_trade_panel_title_text:CopyComponent("EAS_trade_receiving_ally_label")
    EASMod.EAS_trade_receiving_ally_label = find_child_uicomponent(EASMod.EAS_trade_panel_header,"EAS_trade_receiving_ally_label")
    EASMod.EAS_trade_receiving_ally_label:SetDockingPoint(5)
    EASMod.EAS_trade_receiving_ally_label:SetDockOffset(350,50)
    EASMod.EAS_trade_receiving_ally_label:SetCanResizeWidth(true)
    EASMod.EAS_trade_receiving_ally_label:SetCanResizeHeight(true)
    EASMod.EAS_trade_receiving_ally_label:Resize(200,50)
    EASMod.EAS_trade_receiving_ally_label:SetTextHAlign("centre")
    EASMod.EAS_trade_receiving_ally_label:SetCurrentStateImageOpacity(0, 0)
    EASMod.EAS_trade_receiving_ally_label:SetStateText(common.get_localised_string("EAS_trade_panel_receiving_ally_loc"))
    
    -- Manage multiplayer by creating a list of all players factions
    function EAS_trade_multiplayer_compat()
        local EAS_mpfactions_var = {}
        
        -- Create the player faction listbox from the custom xml to have dropdown list with a scroll bar
        EASMod.EAS_trade_mpfactions_dropdown = core:get_or_create_component("EAS_trade_mpfactions_dropdown","UI/templates/EAS_dropdown_context.twui.xml",EASMod.EAS_trade_panel_frame)
        EASMod.EAS_trade_mpfactions_dropdown:SetDockingPoint(5)
        EASMod.EAS_trade_mpfactions_dropdown:SetDockOffset(0,-350)
        
        EASMod.EAS_trade_mpfactions_popup_menu = find_child_uicomponent(EASMod.EAS_trade_mpfactions_dropdown,"popup_menu")
        EASMod.EAS_trade_mpfactions_listview = find_child_uicomponent(EASMod.EAS_trade_mpfactions_popup_menu,"listview")
        EASMod.EAS_trade_mpfactions_list_clip = find_child_uicomponent(EASMod.EAS_trade_mpfactions_listview,"list_clip")
        EASMod.EAS_trade_mpfactions_list_box = find_child_uicomponent(EASMod.EAS_trade_mpfactions_list_clip,"list_box")
        EASMod.EAS_trade_mpfactions_template_dropdown_entry = find_child_uicomponent(EASMod.EAS_trade_mpfactions_list_box,"template_dropdown_entry")
        EASMod.EAS_trade_mpfactions_template_dropdown_entry:SetVisible(false)	
            
        EASMod.EAS_trade_mpfactions_selected_context_display = find_child_uicomponent(EASMod.EAS_trade_mpfactions_dropdown,"selected_context_display")

        EASMod.EAS_trade_mpfactions_selected_context_display:CopyComponent("EAS_trade_mpfactions_desc_label")
        EASMod.EAS_trade_mpfactions_desc_label = find_child_uicomponent(EASMod.EAS_trade_mpfactions_dropdown,"EAS_trade_mpfactions_desc_label")
        EASMod.EAS_trade_panel_header:Adopt(EASMod.EAS_trade_mpfactions_desc_label:Address())
        EASMod.EAS_trade_mpfactions_desc_label:SetCanResizeWidth(true)
        EASMod.EAS_trade_mpfactions_desc_label:SetCanResizeHeight(true)
        EASMod.EAS_trade_mpfactions_desc_label:Resize(500,500)
        EASMod.EAS_trade_mpfactions_desc_label:SetTextVAlign("top")
        EASMod.EAS_trade_mpfactions_desc_label:SetTextHAlign("centre")
        EASMod.EAS_trade_mpfactions_desc_label:SetDockingPoint(2)
        EASMod.EAS_trade_mpfactions_desc_label:SetDockOffset(0,20)
        EASMod.EAS_trade_mpfactions_desc_label:SetStateText(common.get_localised_string("EAS_trade_mpfactions_desc_label_loc"))
        
        -- List all player factions
        local EAS_trade_mpfactions = {}

        local all_factions = cm:model():world():faction_list()
        for i = 0, all_factions:num_items() - 1 do
            local current_faction = all_factions:item_at(i)
            
            --if current_faction:is_human() == true and current_faction:region_list():num_items() >= tonumber(EAS_ai_min_region) then
            if current_faction:is_human() then
                local loc_faction_name = common.get_localised_string("factions_screen_name_" .. current_faction:name())
                if loc_faction_name ~= "" then
                    table.insert(EAS_trade_mpfactions, { loc_faction_name, current_faction:name() } )
                end
            end
        end

        -- Sort the player factions table
        if #EAS_trade_mpfactions > 0 then
            table.sort(EAS_trade_mpfactions, function (left, right) return left[1] < right[1] end)
        else
            EASMod.EAS_trade_mpfactions_template_dropdown_entry:CopyComponent("no_mpfaction_var")
            EASMod.no_mpfaction_var = find_child_uicomponent(EASMod.EAS_trade_mpfactions_list_box, "no_mpfaction_var")
            EASMod.no_mpfaction_label = find_child_uicomponent(EASMod.no_mpfaction_var, "label_context_name")
            
            EASMod.no_mpfaction_label:SetStateText(common.get_localised_string("EAS_trade_factions_selected_context_display_loc"))
            EASMod.EAS_trade_mpfactions_selected_context_display:SetStateText(common.get_localised_string("EAS_trade_factions_selected_context_display_loc"))
            
            EASMod.no_mpfaction_var:SetVisible(true)
            return
        end
        
        -- Create an entry in the list box for each player faction
        for i = 1, #EAS_trade_mpfactions do
            EASMod.EAS_trade_mpfactions_template_dropdown_entry:CopyComponent(EAS_trade_mpfactions[i][2] .. "mp")
            EAS_mpfactions_var[EAS_trade_mpfactions[i][2] .. "mp"] = find_child_uicomponent(EASMod.EAS_trade_mpfactions_list_box, EAS_trade_mpfactions[i][2] .. "mp")
            find_child_uicomponent(EAS_mpfactions_var[EAS_trade_mpfactions[i][2] .. "mp"],"label_context_name"):SetStateText(EAS_trade_mpfactions[i][1])
            
            EAS_mpfactions_var[EAS_trade_mpfactions[i][2] .. "mp"]:SetVisible(true)
        end
        
        EAS_selected_mpfaction = EAS_trade_mpfactions[1][2]
        EASMod.EAS_trade_mpfactions_selected_context_display:SetStateText(EAS_trade_mpfactions[1][1])
        
        -- Add the faction flags to the panel
        local EAS_trade_flag_path = ""
        EASMod.EAS_trade_faction_our_flag = core:get_or_create_component("EAS_trade_faction_our_flag","ui/templates/panel_frame.twui.xml", EASMod.EAS_trade_panel_frame)
        EAS_trade_flag_path = common.get_context_value("CcoCampaignFaction", cm:get_faction(EAS_selected_mpfaction):command_queue_index(), "FactionFlagDir")
        EASMod.EAS_trade_faction_our_flag:SetDockingPoint(5)
        EASMod.EAS_trade_faction_our_flag:Resize(44, 44, true)
        EASMod.EAS_trade_faction_our_flag:SetDockOffset(-350,-100)
        EASMod.EAS_trade_faction_our_flag:SetCurrentStateImageDockOffset(0,11,3)
        EASMod.EAS_trade_faction_our_flag:SetImagePath(EAS_trade_flag_path .. "/mon_64.png", 0, true)
        
        EAS_trade_current_player = cm:get_faction(EAS_selected_mpfaction)
        
        core:remove_listener("EAS_trade_mpfaction_pressed_listener")
        
        -- Add the listeners to update the interface when selecting another faction in the list
        core:add_listener(
            "EAS_trade_mpfaction_pressed_listener",
            "ComponentLClickUp",
            function(context)
                for k, v in pairs(EAS_mpfactions_var) do
                    if context.string == k then
                        return true
                    end
                end
            end,
            function(context)
                CampaignUI.TriggerCampaignScriptEvent(0, context.string)
            end,
            true
        )
        
        core:add_listener(
            "EAS_trade_mpfaction_pressed_listener",
            "UITrigger",
            function(context)
                for k, v in pairs(EAS_mpfactions_var) do
                    if context:trigger() == k then
                        return true
                    end
                end
            end,
            function(context)
                for k, v in pairs(EAS_mpfactions_var) do
                    if context:trigger() == k then
                        EAS_selected_mpfaction = k:sub(1, -3)
                        EASMod.EAS_trade_mpfactions_selected_context_display:SetStateText(common.get_localised_string("factions_screen_name_" .. k:sub(1, -3)))
                        
                        EAS_trade_current_player = cm:get_faction(EAS_selected_mpfaction)
                        
                        local EAS_trade_our_flag_path = common.get_context_value("CcoCampaignFaction", cm:get_faction(EAS_selected_mpfaction):command_queue_index(), "FactionFlagDir")
                        EASMod.EAS_trade_faction_our_flag:SetImagePath(EAS_trade_our_flag_path .. "/mon_64.png", 0, true)
                        
                        if EASMod.EAS_trade_factions_dropdown and EASMod.EAS_trade_factions_dropdown:IsValid() then
                            EASMod.EAS_trade_factions_dropdown:Destroy()
                        end
                        if EASMod.EAS_trade_factions_desc_label and EASMod.EAS_trade_factions_desc_label:IsValid() then
                            EASMod.EAS_trade_factions_desc_label:Destroy()
                        end
                        if EASMod.EAS_trade_receiver_dropdown and EASMod.EAS_trade_receiver_dropdown:IsValid() then
                            EASMod.EAS_trade_receiver_dropdown:Destroy()
                        end
                        if EASMod.EAS_trade_their_dropdown and EASMod.EAS_trade_their_dropdown:IsValid() then
                            EASMod.EAS_trade_their_dropdown:Destroy()
                        end
                        
                        EAS_trade_factions_list()
                        if EAS_find_factions then
                            EASMod.EAS_trade_their_dropdown_preparation()
                        end
                        
                        return
                    end
                end
            end,
            true
        )
    end
    
    function EAS_trade_factions_list()
        local EAS_receiver_var = {}
        
        -- Create the factions listbox from the custom xml to have dropdown list with a scroll bar

        EASMod.EAS_trade_factions_dropdown = core:get_or_create_component("EAS_trade_factions_dropdown","UI/templates/EAS_dropdown_context.twui.xml",EASMod.EAS_trade_panel_frame)
        EASMod.EAS_trade_factions_dropdown:SetDockingPoint(5)
        EASMod.EAS_trade_factions_dropdown:SetDockOffset(-350,-150)
        
        EASMod.EAS_trade_factions_popup_menu = find_child_uicomponent(EASMod.EAS_trade_factions_dropdown,"popup_menu")
        EASMod.EAS_trade_factions_listview = find_child_uicomponent(EASMod.EAS_trade_factions_popup_menu,"listview")
        EASMod.EAS_trade_factions_list_clip = find_child_uicomponent(EASMod.EAS_trade_factions_listview,"list_clip")
        EASMod.EAS_trade_factions_list_box = find_child_uicomponent(EASMod.EAS_trade_factions_list_clip,"list_box")
        EASMod.EAS_trade_factions_template_dropdown_entry = find_child_uicomponent(EASMod.EAS_trade_factions_list_box,"template_dropdown_entry")
        EASMod.EAS_trade_factions_template_dropdown_entry:SetVisible(false)	
            
        EASMod.EAS_trade_factions_selected_context_display = find_child_uicomponent(EASMod.EAS_trade_factions_dropdown,"selected_context_display")
        
        EASMod.EAS_trade_factions_selected_context_display:CopyComponent("EAS_trade_factions_desc_label")
        EASMod.EAS_trade_factions_desc_label = find_child_uicomponent(EASMod.EAS_trade_factions_dropdown,"EAS_trade_factions_desc_label")
        EASMod.EAS_trade_panel_header:Adopt(EASMod.EAS_trade_factions_desc_label:Address())
        EASMod.EAS_trade_factions_desc_label:SetCanResizeWidth(true)
        EASMod.EAS_trade_factions_desc_label:SetCanResizeHeight(true)
        EASMod.EAS_trade_factions_desc_label:Resize(500,500)
        EASMod.EAS_trade_factions_desc_label:SetTextVAlign("top")
        EASMod.EAS_trade_factions_desc_label:SetTextHAlign("centre")
        EASMod.EAS_trade_factions_desc_label:SetDockingPoint(2)
        EASMod.EAS_trade_factions_desc_label:SetDockOffset(-350,-300)
        EASMod.EAS_trade_factions_desc_label:SetStateText("Giver Faction")

        EASMod.EAS_trade_receiver_dropdown = core:get_or_create_component("EAS_trade_receiver_dropdown","UI/templates/EAS_dropdown_context.twui.xml",EASMod.EAS_trade_panel_frame)
        EASMod.EAS_trade_receiver_dropdown:SetDockingPoint(5)
        EASMod.EAS_trade_receiver_dropdown:SetDockOffset(350,-150)
        
        EASMod.EAS_trade_receiver_popup_menu = find_child_uicomponent(EASMod.EAS_trade_receiver_dropdown,"popup_menu")
        EASMod.EAS_trade_receiver_listview = find_child_uicomponent(EASMod.EAS_trade_receiver_popup_menu,"listview")
        EASMod.EAS_trade_receiver_list_clip = find_child_uicomponent(EASMod.EAS_trade_receiver_listview,"list_clip")
        EASMod.EAS_trade_receiver_list_box = find_child_uicomponent(EASMod.EAS_trade_receiver_list_clip,"list_box")
        EASMod.EAS_trade_receiver_template_dropdown_entry = find_child_uicomponent(EASMod.EAS_trade_receiver_list_box,"template_dropdown_entry")
        EASMod.EAS_trade_receiver_template_dropdown_entry:SetVisible(false)
        
        EASMod.EAS_trade_receiver_selected_context_display = find_child_uicomponent(EASMod.EAS_trade_receiver_dropdown,"selected_context_display")
        
        EASMod.EAS_trade_receiver_selected_context_display:CopyComponent("EAS_trade_receiver_desc_label")
        EASMod.EAS_trade_receiver_desc_label = find_child_uicomponent(EASMod.EAS_trade_receiver_dropdown,"EAS_trade_receiver_desc_label")
        EASMod.EAS_trade_panel_header:Adopt(EASMod.EAS_trade_receiver_desc_label:Address())
        EASMod.EAS_trade_receiver_desc_label:SetCanResizeWidth(true)
        EASMod.EAS_trade_receiver_desc_label:SetCanResizeHeight(true)
        EASMod.EAS_trade_receiver_desc_label:Resize(500,500)
        EASMod.EAS_trade_receiver_desc_label:SetTextVAlign("top")
        EASMod.EAS_trade_receiver_desc_label:SetTextHAlign("centre")
        EASMod.EAS_trade_receiver_desc_label:SetDockingPoint(2)
        EASMod.EAS_trade_receiver_desc_label:SetDockOffset(350,-300)
        EASMod.EAS_trade_receiver_desc_label:SetStateText("Receiver Faction")
        
        local EAS_trade_factions = {}

        if EAS_allow_player_cities then
            local loc_player_name = common.get_localised_string("factions_screen_name_" .. EAS_trade_current_player:name())
            table.insert(EAS_trade_factions, { loc_player_name, EAS_trade_current_player:name() } )
        end

        local all_factions = cm:model():world():faction_list()
        for i = 0, all_factions:num_items() - 1 do
            local current_faction = all_factions:item_at(i)
            if EAS_trade_current_player ~= current_faction
                and EAS_trade_current_player:is_ally_vassal_or_client_state_of(current_faction)
                and current_faction:region_list():num_items() >= tonumber(EAS_ai_min_region) then
                local loc_faction_name = common.get_localised_string("factions_screen_name_" .. current_faction:name())
                if loc_faction_name ~= "" then
                    table.insert(EAS_trade_factions, { loc_faction_name, current_faction:name() } )
                end
            end
        end
        
        if #EAS_trade_factions > 0 then
            EAS_find_factions = true
            table.sort(EAS_trade_factions, function (left, right) return left[1] < right[1] end)
        else
            EAS_find_factions = false
            EASMod.EAS_trade_factions_template_dropdown_entry:CopyComponent("no_faction_var")
            EASMod.no_faction_var = find_child_uicomponent(EASMod.EAS_trade_factions_list_box, "no_faction_var")
            EASMod.no_faction_label = find_child_uicomponent(EASMod.no_faction_var, "label_context_name")
            
            EASMod.no_faction_label:SetStateText(common.get_localised_string("EAS_trade_factions_selected_context_display_loc"))
            EASMod.EAS_trade_factions_selected_context_display:SetStateText(common.get_localised_string("EAS_trade_factions_selected_context_display_loc"))
            EASMod.EAS_trade_receiver_selected_context_display:SetStateText(common.get_localised_string("EAS_trade_receiver_selected_context_display_loc"))
            
            EASMod.no_faction_var:SetVisible(true)
            EASMod.EAS_trade_panel_desc:SetVisible(false)
            EASMod.EAS_trade_their_settlements:SetVisible(false)
            EASMod.EAS_trade_deal:SetVisible(false)
            EASMod.EAS_trade_factions_desc_label:SetVisible(false)
            return
        end
        
        for i = 1, #EAS_trade_factions do
            local faction_key = EAS_trade_factions[i][2]
            local display_name = EAS_trade_factions[i][1]

            EASMod.EAS_trade_factions_template_dropdown_entry:CopyComponent(faction_key)
            EAS_factions_var[faction_key] = find_child_uicomponent(EASMod.EAS_trade_factions_list_box, faction_key)
            find_child_uicomponent(EAS_factions_var[faction_key],"label_context_name"):SetStateText(display_name)
            EAS_factions_var[faction_key]:SetVisible(true)

            EASMod.EAS_trade_receiver_template_dropdown_entry:CopyComponent(faction_key .. "_receiver")
            EAS_receiver_var[faction_key .. "_receiver"] = find_child_uicomponent(EASMod.EAS_trade_receiver_list_box, faction_key .. "_receiver")
            find_child_uicomponent(EAS_receiver_var[faction_key .. "_receiver"],"label_context_name"):SetStateText(display_name)
            EAS_receiver_var[faction_key .. "_receiver"]:SetVisible(true)
        end
        
        EAS_selected_faction = EAS_trade_factions[1][2]
        EAS_giver_faction = EAS_selected_faction
        EASMod.EAS_trade_factions_selected_context_display:SetStateText(EAS_trade_factions[1][1])

        if #EAS_trade_factions > 1 then
            EAS_receiver_faction = EAS_trade_factions[2][2]
            EASMod.EAS_trade_receiver_selected_context_display:SetStateText(EAS_trade_factions[2][1])
        else
            EAS_receiver_faction = EAS_trade_factions[1][2]
            EASMod.EAS_trade_receiver_selected_context_display:SetStateText(EAS_trade_factions[1][1])
        end
        
        local EAS_trade_flag_path = ""
        EASMod.EAS_trade_faction_our_flag = core:get_or_create_component("EAS_trade_faction_our_flag","ui/templates/panel_frame.twui.xml", EASMod.EAS_trade_panel_frame)
        EAS_trade_flag_path = common.get_context_value("CcoCampaignFaction", cm:get_faction(EAS_giver_faction):command_queue_index(), "FactionFlagDir")
        EASMod.EAS_trade_faction_our_flag:SetDockingPoint(5)
        EASMod.EAS_trade_faction_our_flag:Resize(44, 44, true)
        EASMod.EAS_trade_faction_our_flag:SetDockOffset(-350,-100)
        EASMod.EAS_trade_faction_our_flag:SetCurrentStateImageDockOffset(0,11,3)
        EASMod.EAS_trade_faction_our_flag:SetImagePath(EAS_trade_flag_path .. "/mon_64.png", 0, true)
        
        EASMod.EAS_trade_faction_their_flag = core:get_or_create_component("EAS_trade_faction_their_flag","ui/templates/panel_frame.twui.xml", EASMod.EAS_trade_panel_frame)
        EAS_trade_flag_path = common.get_context_value("CcoCampaignFaction", cm:get_faction(EAS_receiver_faction):command_queue_index(), "FactionFlagDir")
        EASMod.EAS_trade_faction_their_flag:SetDockingPoint(5)
        EASMod.EAS_trade_faction_their_flag:Resize(44, 44, true)
        EASMod.EAS_trade_faction_their_flag:SetDockOffset(350,-100)
        EASMod.EAS_trade_faction_their_flag:SetCurrentStateImageDockOffset(0,11,3)
        EASMod.EAS_trade_faction_their_flag:SetImagePath(EAS_trade_flag_path .. "/mon_64.png", 0, true)
        
        core:remove_listener("EAS_trade_faction_pressed_listener")
        core:add_listener(
            "EAS_trade_faction_pressed_listener",
            "ComponentLClickUp",
            function(context)
                for k, v in pairs(EAS_factions_var) do
                    if context.string == k then
                        return true
                    end
                end
            end,
            function(context)
                CampaignUI.TriggerCampaignScriptEvent(0, context.string)
            end,
            true
        )
        
        core:add_listener(
            "EAS_trade_faction_pressed_listener",
            "UITrigger",
            function(context)
                for k, v in pairs(EAS_factions_var) do
                    if context:trigger() == k then
                        return true
                    end
                end
            end,
            function(context)
                for k, v in pairs(EAS_factions_var) do
                    if context:trigger() == k then
                        if k == EAS_receiver_faction then
                            local old_giver = EAS_giver_faction
                            EAS_receiver_faction = old_giver
                            EAS_giver_faction = k
                            EAS_selected_faction = k
                            
                            EASMod.EAS_trade_receiver_selected_context_display:SetStateText(common.get_localised_string("factions_screen_name_" .. EAS_receiver_faction))
                            local EAS_trade_receiver_flag_path = common.get_context_value("CcoCampaignFaction", cm:get_faction(EAS_receiver_faction):command_queue_index(), "FactionFlagDir")
                            EASMod.EAS_trade_faction_their_flag:SetImagePath(EAS_trade_receiver_flag_path .. "/mon_64.png", 0, true)
                        else
                            EAS_selected_faction = k
                            EAS_giver_faction = k
                        end
                        
                        EASMod.EAS_trade_factions_selected_context_display:SetStateText(common.get_localised_string("factions_screen_name_" .. EAS_giver_faction))
                        
                        if EASMod.EAS_trade_their_dropdown and EASMod.EAS_trade_their_dropdown:IsValid() then
                            EASMod.EAS_trade_their_dropdown:Destroy()
                        end

                        EAS_selected_region = nil
                        EASMod.EAS_trade_their_dropdown_preparation()
        
                        local EAS_trade_giver_flag_path = common.get_context_value("CcoCampaignFaction", cm:get_faction(EAS_giver_faction):command_queue_index(), "FactionFlagDir")
                        EASMod.EAS_trade_faction_our_flag:SetImagePath(EAS_trade_giver_flag_path .. "/mon_64.png", 0, true)
                        
                        if EAS_receiver_faction == EAS_giver_faction then
                            for rk, rv in pairs(EAS_receiver_var) do
                                local rk_faction = rk:sub(1, -10)
                                if rk_faction ~= EAS_giver_faction then
                                    EAS_receiver_faction = rk_faction
                                    EASMod.EAS_trade_receiver_selected_context_display:SetStateText(common.get_localised_string("factions_screen_name_" .. rk_faction))
                                    local EAS_trade_receiver_flag_path = common.get_context_value("CcoCampaignFaction", cm:get_faction(EAS_receiver_faction):command_queue_index(), "FactionFlagDir")
                                    EASMod.EAS_trade_faction_their_flag:SetImagePath(EAS_trade_receiver_flag_path .. "/mon_64.png", 0, true)
                                    break
                                end
                            end
                        end
                        
                        if EASMod.EAS_update_confirm_state then
                            EASMod.EAS_update_confirm_state()
                        end
                        
                        return
                    end
                end
            end,
            true
        )

        core:remove_listener("EAS_trade_receiver_faction_pressed_listener")
        core:add_listener(
            "EAS_trade_receiver_faction_pressed_listener",
            "ComponentLClickUp",
            function(context)
                for k, v in pairs(EAS_receiver_var) do
                    if context.string == k then
                        return true
                    end
                end
            end,
            function(context)
                CampaignUI.TriggerCampaignScriptEvent(0, context.string)
            end,
            true
        )
        
        core:add_listener(
            "EAS_trade_receiver_faction_pressed_listener",
            "UITrigger",
            function(context)
                for k, v in pairs(EAS_receiver_var) do
                    if context:trigger() == k then
                        return true
                    end
                end
            end,
            function(context)
                for k, v in pairs(EAS_receiver_var) do
                    if context:trigger() == k then
                        local faction_key = k:sub(1, -10)
                        if faction_key == EAS_giver_faction then
                             local old_receiver = EAS_receiver_faction
                             EAS_giver_faction = old_receiver
                             EAS_selected_faction = old_receiver
                             
                             EASMod.EAS_trade_factions_selected_context_display:SetStateText(common.get_localised_string("factions_screen_name_" .. EAS_giver_faction))
                             local EAS_trade_giver_flag_path = common.get_context_value("CcoCampaignFaction", cm:get_faction(EAS_giver_faction):command_queue_index(), "FactionFlagDir")
                             EASMod.EAS_trade_faction_our_flag:SetImagePath(EAS_trade_giver_flag_path .. "/mon_64.png", 0, true)
                             
                             if EASMod.EAS_trade_their_dropdown and EASMod.EAS_trade_their_dropdown:IsValid() then
                                EASMod.EAS_trade_their_dropdown:Destroy()
                             end
                             EAS_selected_region = nil
                             EASMod.EAS_trade_their_dropdown_preparation()
                        end
                        EAS_receiver_faction = faction_key
                        EASMod.EAS_trade_receiver_selected_context_display:SetStateText(common.get_localised_string("factions_screen_name_" .. faction_key))

                        local EAS_trade_receiver_flag_path = common.get_context_value("CcoCampaignFaction", cm:get_faction(EAS_receiver_faction):command_queue_index(), "FactionFlagDir")
                        EASMod.EAS_trade_faction_their_flag:SetImagePath(EAS_trade_receiver_flag_path .. "/mon_64.png", 0, true)

                        if EASMod.EAS_update_confirm_state then
                            EASMod.EAS_update_confirm_state()
                        end

                        return
                    end
                end
            end,
            true
        )
        
        if EAS_find_factions then
            EAS_factions_var[EAS_trade_factions[1][2]]:SimulateLClick()
        else
            EASMod.no_faction_var:SimulateLClick()
        end
	end
	
	
    -- Create the factions list of players if it's a multiplayer game
    if cm:is_multiplayer() then
        EAS_trade_multiplayer_compat()
    end
    EAS_trade_factions_list()  
	
	

	
	
	-- Create the region listbox of the Giver's faction
    function EASMod.EAS_trade_their_dropdown_preparation()
		local EAS_their_regions_var = {}
		
        EASMod.EAS_trade_their_dropdown = core:get_or_create_component("EAS_trade_settings_their_dropdown","UI/templates/EAS_dropdown_context.twui.xml", EASMod.EAS_trade_panel_frame)
        EASMod.EAS_trade_their_dropdown:SetDockingPoint(5)
        EASMod.EAS_trade_their_dropdown:SetDockOffset(-350,50)

        EASMod.EAS_trade_their_popup_menu = find_child_uicomponent(EASMod.EAS_trade_their_dropdown,"popup_menu")
        EASMod.EAS_trade_their_popup_menu:RegisterTopMost()
		EASMod.EAS_trade_their_listview = find_child_uicomponent(EASMod.EAS_trade_their_popup_menu,"listview")
		EASMod.EAS_trade_their_list_clip = find_child_uicomponent(EASMod.EAS_trade_their_listview,"list_clip")
        EASMod.EAS_trade_their_list_box = find_child_uicomponent(EASMod.EAS_trade_their_list_clip,"list_box")
		
        EASMod.EAS_trade_their_template_dropdown_entry = find_child_uicomponent(EASMod.EAS_trade_their_list_box,"template_dropdown_entry")
        EASMod.EAS_trade_their_template_dropdown_entry:SetVisible(false)

        EASMod.EAS_trade_their_selected_context_display = find_child_uicomponent(EASMod.EAS_trade_their_dropdown,"selected_context_display")

		-- Create the label showing their selected region information
		EASMod.EAS_trade_their_selected_context_display:CopyComponent("EAS_trade_their_desc_label")
		EASMod.EAS_trade_their_desc_label = find_child_uicomponent(EASMod.EAS_trade_their_dropdown,"EAS_trade_their_desc_label")
		EASMod.EAS_trade_panel_header:Adopt(EASMod.EAS_trade_their_desc_label:Address())
		EASMod.EAS_trade_their_desc_label:SetCanResizeWidth(true)
		EASMod.EAS_trade_their_desc_label:SetCanResizeHeight(true)
		EASMod.EAS_trade_their_desc_label:Resize(500,500)
		EASMod.EAS_trade_their_desc_label:SetDockingPoint(2)
		EASMod.EAS_trade_their_desc_label:SetTextHAlign("left")
		EASMod.EAS_trade_their_desc_label:SetTextVAlign("top")
		EASMod.EAS_trade_their_desc_label:SetDockOffset(400,345)
        
		-- Create an entry in the list box for each region of the AI's faction
		local EAS_trade_their_regions = {}
		local their_region_list = cm:get_faction(EAS_selected_faction):region_list()
		for i = 0, their_region_list:num_items() - 1 do
			local current_their_region = their_region_list:item_at(i)
			local loc_their_region_name = common.get_localised_string("regions_onscreen_" .. current_their_region:name())
			table.insert(EAS_trade_their_regions, { loc_their_region_name, current_their_region:name() });
		end
		
		table.sort(EAS_trade_their_regions, function (left, right) return left[1] < right[1] end)
		
		-- Create an entry in the list box for each region of the AI's faction
		for i = 1, #EAS_trade_their_regions do
			EASMod.EAS_trade_their_template_dropdown_entry:CopyComponent(EAS_trade_their_regions[i][2])
			EAS_their_regions_var[EAS_trade_their_regions[i][2]] = find_child_uicomponent(EASMod.EAS_trade_their_list_box, EAS_trade_their_regions[i][2])
			find_child_uicomponent(EAS_their_regions_var[EAS_trade_their_regions[i][2]],"label_context_name"):SetStateText(EAS_trade_their_regions[i][1])
			EAS_their_regions_var[EAS_trade_their_regions[i][2]]:SetVisible(true)
		end

        EASMod.EAS_trade_their_selected_context_display:SetStateText(common.get_localised_string("EAS_trade_their_selected_context_display_loc"))
		
		EASMod.EAS_trade_their_desc_label:SetStateText("")
		
		core:remove_listener("EAS_trade_their_regions_pressed_listener")
		
		-- Add the listeners to update the interface when selecting any entry in the AI's faction list
        core:add_listener(
		   "EAS_trade_their_regions_pressed_listener",
		   "ComponentLClickUp",
			function(context)
				for k, v in pairs(EAS_their_regions_var) do
					if context.string == k then
						return true
					end
				end
			end,
            function(context)
                CampaignUI.TriggerCampaignScriptEvent(0, context.string)
            end,
        true
		)
                
		core:add_listener(
		   "EAS_trade_their_regions_pressed_listener",
		   "UITrigger",
			function(context)
				for k, v in pairs(EAS_their_regions_var) do
					if context:trigger() == k then
						return true
					end
				end
			end,
			function(context)
				for k, v in pairs(EAS_their_regions_var) do
					if context:trigger() == k then
                        EAS_selected_region = k
						EASMod.EAS_trade_their_selected_context_display:SetStateText(common.get_localised_string("regions_onscreen_" .. k))
						
						EASMod.EAS_update_confirm_state()
						break
					end
				end
			end,
			true
		)

    end
	
	if EAS_find_factions then
		EASMod.EAS_trade_their_dropdown_preparation()
	end
	
    
    -- Update the interface when clicking on any of the region list boxes
    function EASMod.EAS_update_confirm_state()
        if EAS_selected_region ~= nil and EAS_giver_faction ~= EAS_receiver_faction then
            EASMod.EAS_trade_deal:SetVisible(true)
            EASMod.EAS_trade_deal_details_desc:SetVisible(true)
            
            local region_name = common.get_localised_string("regions_onscreen_" .. EAS_selected_region)
            local giver_name = common.get_localised_string("factions_screen_name_" .. EAS_giver_faction)
            local receiver_name = common.get_localised_string("factions_screen_name_" .. EAS_receiver_faction)
            
            EASMod.EAS_trade_deal_details_desc:SetStateText("Transfer " .. region_name .. " from " .. giver_name .. " to " .. receiver_name)
            
            EASMod.EAS_trade_panel_confirm:SetDisabled(false)
            EASMod.EAS_trade_panel_confirm:SetImagePath("ui/campaign ui/message_icons/event_diplomacy_positive.png", 0, false)
            EASMod.EAS_trade_panel_confirm:SetTooltipText(common.get_localised_string("EAS_trade_panel_confirmb_loc"), common.get_localised_string("EAS_trade_panel_confirmb_loc"), true)
        else
             EASMod.EAS_trade_deal:SetVisible(false)
             EASMod.EAS_trade_deal_details_desc:SetVisible(false)
             EASMod.EAS_trade_panel_confirm:SetDisabled(true)
             EASMod.EAS_trade_panel_confirm:SetImagePath("ui/campaign ui/message_icons/event_diplomacy_negative.png", 0, false)
        end

        if EAS_giver_faction and EAS_receiver_faction and EAS_giver_faction ~= EAS_receiver_faction then
             local giver_culture = cm:get_faction(EAS_giver_faction):culture()
             local receiver_culture = cm:get_faction(EAS_receiver_faction):culture()
             
             local giver_name = common.get_localised_string("factions_screen_name_" .. EAS_giver_faction)
             local receiver_name = common.get_localised_string("factions_screen_name_" .. EAS_receiver_faction)
             local tooltip_text = string.format(common.get_localised_string("EAS_trade_panel_confederate_tooltip_loc"), giver_name, receiver_name, giver_name)
             EASMod.EAS_trade_panel_confederate:SetTooltipText(tooltip_text, tooltip_text, true)

             local is_player_involved = (EAS_giver_faction == EAS_trade_current_player:name()) or (EAS_receiver_faction == EAS_trade_current_player:name())

             if giver_culture == receiver_culture and not is_player_involved then
                EASMod.EAS_trade_panel_confederate:SetVisible(true)
                EASMod.EAS_trade_panel_confederate:SetDisabled(false)
             else
                EASMod.EAS_trade_panel_confederate:SetVisible(false)
                EASMod.EAS_trade_panel_confederate:SetDisabled(true)
             end
        else
             EASMod.EAS_trade_panel_confederate:SetVisible(false)
             EASMod.EAS_trade_panel_confederate:SetDisabled(true)
        end
    end
    
    -- Create the confirm button
	EASMod.EAS_trade_panel_confirm = core:get_or_create_component("EAS_trade_panel_confirm","UI/templates/round_medium_button.twui.xml", EASMod.EAS_trade_panel_frame)
	EASMod.EAS_trade_panel_confirm:SetImagePath("ui/campaign ui/message_icons/event_mission_negative.png", 0,false)
	EASMod.EAS_trade_panel_confirm:SetDockingPoint(8)
	EASMod.EAS_trade_panel_confirm:SetDockOffset(-150,-10)
	EASMod.EAS_trade_panel_confirm:SetTooltipText(common.get_localised_string("EAS_trade_panel_confirma_loc"), common.get_localised_string("EAS_trade_panel_confirma_loc"), true)
	EASMod.EAS_trade_panel_confirm:SetDisabled(true)

    -- Create the confederate button
    EASMod.EAS_trade_panel_confederate = core:get_or_create_component("EAS_trade_panel_confederate","UI/templates/round_medium_button.twui.xml", EASMod.EAS_trade_panel_frame)
    EASMod.EAS_trade_panel_confederate:SetImagePath("ui/campaign ui/diplomacy_icons/diplomatic_option_confederation.png", 0,false)
    EASMod.EAS_trade_panel_confederate:SetDockingPoint(8)
    EASMod.EAS_trade_panel_confederate:SetDockOffset(0,-10)
    EASMod.EAS_trade_panel_confederate:SetTooltipText(common.get_localised_string("EAS_trade_panel_confederate_tooltip_loc"), common.get_localised_string("EAS_trade_panel_confederate_tooltip_loc"), true)
    EASMod.EAS_trade_panel_confederate:SetDisabled(true)
    EASMod.EAS_trade_panel_confederate:SetVisible(false)

    -- Create the cancel button
	EASMod.EAS_trade_panel_cancel = core:get_or_create_component("EAS_trade_panel_cancel","UI/templates/round_medium_button.twui.xml", EASMod.EAS_trade_panel_frame)
	EASMod.EAS_trade_panel_cancel:SetImagePath("ui/skins/default/icon_cross.png", 0,false)
	EASMod.EAS_trade_panel_cancel:SetDockingPoint(8)
	EASMod.EAS_trade_panel_cancel:SetDockOffset(150,-10)
	EASMod.EAS_trade_panel_cancel:SetTooltipText(common.get_localised_string("EAS_trade_panel_cancel_loc"), common.get_localised_string("EAS_trade_panel_cancel_loc"), true)
    -- End of EAS_trade_menu_creation_initiate
end
local function EAS_trade_panel_button_creation()
	--cm:callback(function()
    local ui_root = core:get_ui_root()
    local menu_bar = find_child_uicomponent(ui_root,"menu_bar")
    local buttongroup = find_child_uicomponent(menu_bar,"buttongroup")
    local EAS_trade_panel_button = find_uicomponent(buttongroup,"EAS_trade_panel_button")
        
    if not EAS_trade_panel_button then
        EASMod.EAS_trade_panel_button = core:get_or_create_component("EAS_trade_panel_button","UI/templates/round_small_button.twui.xml", buttongroup)
        EASMod.EAS_trade_panel_button:SetImagePath("ui/campaign ui/diplomacy_icons/diplomatic_option_military_alliance.png", 0,false)
        EASMod.EAS_trade_panel_button:SetVisible(true)
        EASMod.EAS_trade_panel_button:Resize(38, 38)
        EASMod.EAS_trade_panel_button:SetTooltipText(common.get_localised_string("EAS_trade_panel_button_loc"), common.get_localised_string("EAS_trade_panel_button_loc"), true)
    end
	--end, 0.1)

    
    -- Create the listeners that open the trade menu when clicking on the small button on the top-left corner of the screen
    core:add_listener(
    "EAS_trade_button_pressed_listener",
    "ComponentLClickUp",
        function(context)
            return context.string == EASMod.EAS_trade_panel_button:Id()
        end,
        function(context)
            CampaignUI.TriggerCampaignScriptEvent(0, context.string)
        end,
        true
    )
    
    core:add_listener(
    "EAS_trade_button_pressed_listener",
    "UITrigger",
        function(context)
            return context:trigger() == EASMod.EAS_trade_panel_button:Id()
        end,
        function(context)
            if EASMod.EAS_trade_panel == nil or EASMod.EAS_trade_panel:IsValid() == false then
                EAS_trade_menu_creation_initiate()
                EASMod.EAS_trade_panel:SetVisible(true)
                EAS_trade_create_listeners()
            end
        end,
        true
    )
end


-- Create the listeners that cancels and confirms the trade and switches settlements, give gold or reputation
function EAS_trade_create_listeners()
    core:add_listener(
        "EAS_trade_buttons_pressed_listener",
        "ComponentLClickUp",
        function(context)
			return context.string == EASMod.EAS_trade_panel_confirm:Id() or
            context.string == EASMod.EAS_trade_panel_cancel:Id() or
            context.string == EASMod.EAS_trade_panel_confederate:Id()
		end,
		function(context)
            CampaignUI.TriggerCampaignScriptEvent(0, context.string)     
        end,
        true
	)
    
	core:add_listener(
        "EAS_trade_buttons_pressed_listener",
        "UITrigger",
		function(context)
            return context:trigger() == EASMod.EAS_trade_panel_confirm:Id() or
            context:trigger() == EASMod.EAS_trade_panel_cancel:Id() or
            context:trigger() == EASMod.EAS_trade_panel_confederate:Id()
		end,
		function(context)
            if context:trigger() == EASMod.EAS_trade_panel_confirm:Id() then
                if EAS_selected_region and EAS_receiver_faction and EAS_giver_faction ~= EAS_receiver_faction then
                    cm:transfer_region_to_faction(EAS_selected_region, EAS_receiver_faction)
                    
                    if EASMod.EAS_trade_their_dropdown and EASMod.EAS_trade_their_dropdown:IsValid() then
                        EASMod.EAS_trade_their_dropdown:Destroy()
                    end
                    EAS_selected_region = nil
                    EASMod.EAS_trade_their_dropdown_preparation()
                    
                    EASMod.EAS_trade_their_selected_context_display:SetStateText(common.get_localised_string("EAS_trade_their_selected_context_display_loc"))
                    EASMod.EAS_update_confirm_state()
                end

            elseif context:trigger() == EASMod.EAS_trade_panel_confederate:Id() then
                if EAS_giver_faction and EAS_receiver_faction and EAS_giver_faction ~= EAS_receiver_faction then
                    cm:force_confederation(EAS_receiver_faction, EAS_giver_faction)
                end
        
                -- Destroy the trade menu
        
                EASMod.EAS_trade_panel:SetVisible(false)
                EASMod.EAS_trade_panel:Destroy()
                core:remove_listener("EAS_trade_mpfaction_pressed_listener")
                core:remove_listener("EAS_trade_faction_pressed_listener")
                core:remove_listener("EAS_trade_our_regions_pressed_listener")
                core:remove_listener("EAS_trade_their_regions_pressed_listener")
                core:remove_listener("EAS_trade_buttons_pressed_listener")
    
            elseif context:trigger() == EASMod.EAS_trade_panel_cancel:Id() then
                EASMod.EAS_trade_panel:SetVisible(false)
                EASMod.EAS_trade_panel:Destroy()
                core:remove_listener("EAS_trade_mpfaction_pressed_listener")
                core:remove_listener("EAS_trade_faction_pressed_listener")
                core:remove_listener("EAS_trade_our_regions_pressed_listener")
                core:remove_listener("EAS_trade_their_regions_pressed_listener")
                core:remove_listener("EAS_trade_buttons_pressed_listener")
            end
                
		end,
		true
	)
	
end


cm:add_first_tick_callback(function() EAS_trade_panel_button_creation() end);

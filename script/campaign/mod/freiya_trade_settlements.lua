local FreiyaTMod = {}
local root = FreiyaTMod.root

local freiya_selected_faction = nil
local freiya_find_factions = false
local freiya_selected_our_deal = {}
local freiya_selected_their_deal = {}
local freiya_trade_total_cost = 0
local attitude_not_enough_cash = 0
local freiya_our_gold_value = 0
local freiya_our_attitude_value = 0
local freiya_their_gold_cost = 0
local freiya_their_attitude_value = 0
        
local freiya_our_selected_region = nil
local freiya_their_selected_region = nil
local freiya_count_our_buildings = 0
local freiya_count_their_buildings = 0


local freiya_available_factions = nil 
local freiya_player_benefit = nil
local freiya_ai_min_region = nil
local freiya_whole_province_bonus = nil
local freiya_capital_bonus = nil
local freiya_turn_modifier = nil
local freiya_gold_per_buildings_modifier = nil
local freiya_attitude_per_buildings_modifier = nil
local freiya_region_level_gold = {}
local freiya_region_level_attitude = {}
local freiya_relation_discount = nil
local freiya_relation_cap = nil
local freiya_vassal_discount = nil
local freiya_ally_discount = nil

local freiya_trade_current_player = nil
local freiya_trade_current_player_name = nil


-- Create the trade settlements menu
local function freiya_trade_menu_creation_initiate()
	local freiya_factions_var = {}
	local freiya_factions_label = {}
	freiya_selected_faction = nil
	freiya_find_factions = false
	freiya_selected_our_deal = {}
	freiya_selected_their_deal = {}
	freiya_trade_total_cost = 0
	freiya_our_selected_region = nil
	freiya_their_selected_region = nil
	freiya_count_our_buildings = 0
	freiya_count_their_buildings = 0
	freiya_trade_current_player = cm:get_local_faction(true)
	freiya_trade_current_player_name = cm:get_local_faction_name(true)
	
    
    -- Set default modifiers
    freiya_available_factions = "Met Factions (No War)"
    freiya_player_benefit = "Diplomatic Gains"
    freiya_ai_min_region = "1"
    freiya_whole_province_bonus = "10000"
    freiya_capital_bonus = "10000"
    freiya_turn_modifier = "0.005"
    freiya_gold_per_buildings_modifier = "0.01"
    freiya_attitude_per_buildings_modifier = "0.05"
    freiya_region_level_gold = {"3000", "7000", "11000", "15000", "19000", "23000"}
    freiya_region_level_attitude = {"5", "15", "25", "35", "45", "55"}
    freiya_relation_discount = "0.001"
    freiya_relation_cap = "35"
    freiya_vassal_discount = "0.3"
    freiya_ally_discount = "0.15"
    
    -- Create the core of the menu from an existing xml
    FreiyaTMod.freiya_trade_panel = core:get_or_create_component("freiya_trade_panel","ui/campaign ui/freiya_main_temples_of_the_old_ones.twui.xml", root)
    
    FreiyaTMod.freiya_trade_panel_frame = find_child_uicomponent(FreiyaTMod.freiya_trade_panel,"panel_frame")

    -- Destroy unused elements of the menu
	FreiyaTMod.freiya_trade_panel_frame_fullscreen_underlay = find_child_uicomponent(FreiyaTMod.freiya_trade_panel,"fullscreen_underlay")
	FreiyaTMod.freiya_trade_panel_frame_fullscreen_underlay:Destroy()

	FreiyaTMod.freiya_trade_panel_frame_fullscreen_overlay = find_child_uicomponent(FreiyaTMod.freiya_trade_panel_frame,"fullscreen_overlay")
	FreiyaTMod.freiya_trade_panel_frame_fullscreen_overlay:Destroy()

	FreiyaTMod.freiya_trade_panel_frame_temples_list = find_child_uicomponent(FreiyaTMod.freiya_trade_panel_frame,"temples_list")
	FreiyaTMod.freiya_trade_panel_frame_temples_list:Destroy()

	FreiyaTMod.freiya_trade_panel_frame_prestige_holder = find_child_uicomponent(FreiyaTMod.freiya_trade_panel_frame,"prestige_holder")
	FreiyaTMod.freiya_trade_panel_frame_prestige_holder:Destroy()

	FreiyaTMod.freiya_trade_panel_frame_info_button = find_child_uicomponent(FreiyaTMod.freiya_trade_panel_frame,"button_info")
	FreiyaTMod.freiya_trade_panel_frame_info_button:SetVisible(false)

	FreiyaTMod.freiya_trade_panel_frame_ok_button = find_child_uicomponent(FreiyaTMod.freiya_trade_panel_frame,"button_ok_frame")
	FreiyaTMod.freiya_trade_panel_frame_ok_button:SetVisible(false)
    
    -- Create each elements of the interface
	FreiyaTMod.freiya_trade_panel_header = find_child_uicomponent(FreiyaTMod.freiya_trade_panel_frame,"header")
	FreiyaTMod.freiya_trade_panel_title_text = find_child_uicomponent(FreiyaTMod.freiya_trade_panel_header,"tx_header")
    FreiyaTMod.freiya_trade_panel_title_text:SetTextHAlign("centre")
	FreiyaTMod.freiya_trade_panel_title_text:SetTextXOffset(0,0)
	FreiyaTMod.freiya_trade_panel_title_text:SetTextYOffset(0,0)
	FreiyaTMod.freiya_trade_panel_title_text:SetStateText(common.get_localised_string("freiya_trade_panel_title_text_loc"))

    FreiyaTMod.freiya_trade_panel_title_text:CopyComponent("freiya_trade_panel_desc")
    FreiyaTMod.freiya_trade_panel_desc = find_child_uicomponent(FreiyaTMod.freiya_trade_panel_header,"freiya_trade_panel_desc")
    FreiyaTMod.freiya_trade_panel_desc:SetDockOffset(-400,250)
    FreiyaTMod.freiya_trade_panel_desc:Resize(150,150)
    FreiyaTMod.freiya_trade_panel_desc:SetVisible(true)
    FreiyaTMod.freiya_trade_panel_desc:SetStateText(common.get_localised_string("freiya_trade_panel_desc_loc"))
    FreiyaTMod.freiya_trade_panel_desc:SetCurrentStateImageOpacity(0, 0)
	
	FreiyaTMod.freiya_trade_panel_title_text:CopyComponent("freiya_trade_their_settlements")
    FreiyaTMod.freiya_trade_their_settlements = find_child_uicomponent(FreiyaTMod.freiya_trade_panel_header,"freiya_trade_their_settlements")
    FreiyaTMod.freiya_trade_their_settlements:SetDockOffset(400,250)
    FreiyaTMod.freiya_trade_their_settlements:Resize(150,150)
    FreiyaTMod.freiya_trade_their_settlements:SetVisible(true)
    FreiyaTMod.freiya_trade_their_settlements:SetStateText(common.get_localised_string("freiya_trade_their_settlements_loc"))
    FreiyaTMod.freiya_trade_their_settlements:SetCurrentStateImageOpacity(0, 0)
	
	FreiyaTMod.freiya_trade_panel_title_text:CopyComponent("freiya_trade_deal")
    FreiyaTMod.freiya_trade_deal = find_child_uicomponent(FreiyaTMod.freiya_trade_panel_header,"freiya_trade_deal")
    FreiyaTMod.freiya_trade_deal:SetDockOffset(0,600)
    FreiyaTMod.freiya_trade_deal:Resize(150,150)
    FreiyaTMod.freiya_trade_deal:SetVisible(false)
    FreiyaTMod.freiya_trade_deal:SetStateText(common.get_localised_string("freiya_trade_deal_loc"))
    FreiyaTMod.freiya_trade_deal:SetCurrentStateImageOpacity(0, 0)
    
    -- Manage multiplayer by creating a list of all players factions
    function freiya_trade_multiplayer_compat()
        local freiya_mpfactions_var = {}
        local freiya_mpfactions_label = {}
        
        -- Create the player faction listbox from the custom xml to have dropdown list with a scroll bar
        FreiyaTMod.freiya_trade_mpfactions_dropdown = core:get_or_create_component("freiya_trade_mpfactions_dropdown","UI/templates/freiya_dropdown_context.twui.xml",FreiyaTMod.freiya_trade_panel_frame)
        FreiyaTMod.freiya_trade_mpfactions_dropdown:SetDockingPoint(5)
        FreiyaTMod.freiya_trade_mpfactions_dropdown:SetDockOffset(-400,-320)
        
        FreiyaTMod.freiya_trade_mpfactions_popup_menu = find_child_uicomponent(FreiyaTMod.freiya_trade_mpfactions_dropdown,"popup_menu")
        FreiyaTMod.freiya_trade_mpfactions_listview = find_child_uicomponent(FreiyaTMod.freiya_trade_mpfactions_popup_menu,"listview")
        FreiyaTMod.freiya_trade_mpfactions_list_clip = find_child_uicomponent(FreiyaTMod.freiya_trade_mpfactions_listview,"list_clip")
        FreiyaTMod.freiya_trade_mpfactions_list_box = find_child_uicomponent(FreiyaTMod.freiya_trade_mpfactions_list_clip,"list_box")
        FreiyaTMod.freiya_trade_mpfactions_template_dropdown_entry = find_child_uicomponent(FreiyaTMod.freiya_trade_mpfactions_list_box,"template_dropdown_entry")
        FreiyaTMod.freiya_trade_mpfactions_template_dropdown_entry:SetVisible(false)	
            
        FreiyaTMod.freiya_trade_mpfactions_selected_context_display = find_child_uicomponent(FreiyaTMod.freiya_trade_mpfactions_dropdown,"selected_context_display")

        FreiyaTMod.freiya_trade_mpfactions_selected_context_display:CopyComponent("freiya_trade_mpfactions_desc_label")
        FreiyaTMod.freiya_trade_mpfactions_desc_label = find_child_uicomponent(FreiyaTMod.freiya_trade_mpfactions_dropdown,"freiya_trade_mpfactions_desc_label")
        FreiyaTMod.freiya_trade_panel_header:Adopt(FreiyaTMod.freiya_trade_mpfactions_desc_label:Address())
        FreiyaTMod.freiya_trade_mpfactions_desc_label:SetCanResizeWidth(true)
        FreiyaTMod.freiya_trade_mpfactions_desc_label:SetCanResizeHeight(true)
        FreiyaTMod.freiya_trade_mpfactions_desc_label:Resize(500,500)
        FreiyaTMod.freiya_trade_mpfactions_desc_label:SetTextVAlign("top")
        FreiyaTMod.freiya_trade_mpfactions_desc_label:SetTextHAlign("centre")
        FreiyaTMod.freiya_trade_mpfactions_desc_label:SetDockingPoint(2)
        FreiyaTMod.freiya_trade_mpfactions_desc_label:SetDockOffset(-400,100)
        FreiyaTMod.freiya_trade_mpfactions_desc_label:SetStateText(common.get_localised_string("freiya_trade_mpfactions_desc_label_loc"))
        
        -- List all player factions
        local freiya_trade_mpfactions = {}

        local all_factions = cm:model():world():faction_list()
        for i = 0, all_factions:num_items() - 1 do
            local current_faction = all_factions:item_at(i)
            
            --if current_faction:is_human() == true and current_faction:region_list():num_items() >= tonumber(freiya_ai_min_region) then
            if current_faction:is_human() then
                local loc_faction_name = common.get_localised_string("factions_screen_name_" .. current_faction:name())
                if loc_faction_name ~= "" then
                    table.insert(freiya_trade_mpfactions, { loc_faction_name, current_faction:name() } )
                end
            end
        end

        -- Sort the player factions table
        if #freiya_trade_mpfactions > 0 then
            table.sort(freiya_trade_mpfactions, function (left, right) return left[1] < right[1] end)
        else
            FreiyaTMod.freiya_trade_mpfactions_template_dropdown_entry:CopyComponent("no_mpfaction_var")
            FreiyaTMod.no_mpfaction_var = find_child_uicomponent(FreiyaTMod.freiya_trade_mpfactions_list_box, "no_mpfaction_var")
            FreiyaTMod.no_mpfaction_label = find_child_uicomponent(FreiyaTMod.no_mpfaction_var, "label_context_name")
            
            FreiyaTMod.no_mpfaction_label:SetStateText(common.get_localised_string("no_faction_label_loc"))
            FreiyaTMod.freiya_trade_mpfactions_selected_context_display:SetStateText(common.get_localised_string("freiya_trade_factions_selected_context_display_loc"))
            
            FreiyaTMod.no_mpfaction_var:SetVisible(true)
            return
        end
        
        -- Create an entry in the list box for each player faction
        for i = 1, #freiya_trade_mpfactions do
            FreiyaTMod.freiya_trade_mpfactions_template_dropdown_entry:CopyComponent(freiya_trade_mpfactions[i][2] .. "mp")
            freiya_mpfactions_var[freiya_trade_mpfactions[i][2] .. "mp"] = find_child_uicomponent(FreiyaTMod.freiya_trade_mpfactions_list_box, freiya_trade_mpfactions[i][2] .. "mp")
            freiya_mpfactions_label[freiya_trade_mpfactions[i][2] .. "mp"] = find_child_uicomponent(freiya_mpfactions_var[freiya_trade_mpfactions[i][2] .. "mp"],"label_context_name")
            freiya_mpfactions_label[freiya_trade_mpfactions[i][2] .. "mp"]:SetStateText(freiya_trade_mpfactions[i][1])
            
            freiya_mpfactions_var[freiya_trade_mpfactions[i][2] .. "mp"]:SetVisible(true)
        end
        
        freiya_selected_mpfaction = freiya_trade_mpfactions[1][2]
        FreiyaTMod.freiya_trade_mpfactions_selected_context_display:SetStateText(freiya_trade_mpfactions[1][1])
        
        -- Add the faction flags to the panel
        local freiya_trade_flag_path = ""
        FreiyaTMod.freiya_trade_faction_our_flag = core:get_or_create_component("freiya_trade_faction_our_flag","ui/templates/panel_frame.twui.xml", FreiyaTMod.freiya_trade_panel_frame)
        freiya_trade_flag_path = common.get_context_value("CcoCampaignFaction", cm:get_faction(freiya_selected_mpfaction):command_queue_index(), "FactionFlagDir")
        FreiyaTMod.freiya_trade_faction_our_flag:SetDockingPoint(1)
        FreiyaTMod.freiya_trade_faction_our_flag:Resize(44, 44, true)
        FreiyaTMod.freiya_trade_faction_our_flag:SetDockOffset(350,150)
        FreiyaTMod.freiya_trade_faction_our_flag:SetCurrentStateImageDockOffset(0,11,3)
        FreiyaTMod.freiya_trade_faction_our_flag:SetImagePath(freiya_trade_flag_path .. "/mon_64.png", 0, true)
        
        freiya_trade_current_player = cm:get_faction(freiya_selected_mpfaction)
        freiya_trade_current_player_name = freiya_selected_mpfaction
        
        core:remove_listener("freiya_trade_mpfaction_pressed_listener")
        
        -- Add the listeners to update the interface when selecting another faction in the list
        core:add_listener(
            "freiya_trade_mpfaction_pressed_listener",
            "ComponentLClickUp",
            function(context)
                for k, v in pairs(freiya_mpfactions_var) do
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
            "freiya_trade_mpfaction_pressed_listener",
            "UITrigger",
            function(context)
                for k, v in pairs(freiya_mpfactions_var) do
                    if context:trigger() == k then
                        return true
                    end
                end
            end,
            function(context)
                for k, v in pairs(freiya_mpfactions_var) do
                    if context:trigger() == k then
                        freiya_selected_mpfaction = k:sub(1, -3)
                        FreiyaTMod.freiya_trade_mpfactions_selected_context_display:SetStateText(common.get_localised_string("factions_screen_name_" .. k:sub(1, -3)))
                        
                        freiya_trade_current_player = cm:get_faction(freiya_selected_mpfaction)
                        freiya_trade_current_player_name = freiya_selected_mpfaction
                        
                        FreiyaTMod.freiya_trade_our_dropdown:Destroy()
                        FreiyaTMod.freiya_trade_our_desc_label:Destroy()
                        FreiyaTMod.freiya_trade_our_value_label:Destroy()
                        FreiyaTMod.freiya_trade_deal_details_desc:Destroy()
                        FreiyaTMod.freiya_trade_our_dropdown_preparation()
                        FreiyaTMod.freiya_trade_our_gold_var:SimulateLClick()
        
                        local freiya_trade_our_flag_path = common.get_context_value("CcoCampaignFaction", cm:get_faction(freiya_selected_mpfaction):command_queue_index(), "FactionFlagDir")
                        FreiyaTMod.freiya_trade_faction_our_flag:SetImagePath(freiya_trade_flag_path .. "/mon_64.png", 0, true)
                        
                        FreiyaTMod.freiya_trade_factions_dropdown:Destroy()
                        FreiyaTMod.freiya_trade_factions_desc_label:Destroy()
                        freiya_trade_factions_list()
                        FreiyaTMod.freiya_trade_their_attitude_var:SimulateLClick()
                        
                        return
                    end
                end
            end,
            true
        )
    end
    
    function freiya_trade_factions_list()
        -- Create the faction listbox from the custom xml to have dropdown list with a scroll bar
        FreiyaTMod.freiya_trade_factions_dropdown = core:get_or_create_component("freiya_trade_factions_dropdown","UI/templates/freiya_dropdown_context.twui.xml",FreiyaTMod.freiya_trade_panel_frame)
        FreiyaTMod.freiya_trade_factions_dropdown:SetDockingPoint(5)
        
        if cm:is_multiplayer() then
            FreiyaTMod.freiya_trade_factions_dropdown:SetDockOffset(400,-320)
        else
            FreiyaTMod.freiya_trade_factions_dropdown:SetDockOffset(0,-320)
            --FreiyaTMod.freiya_trade_factions_dropdown:SetDockOffset(400,-320)
        end
        
        FreiyaTMod.freiya_trade_factions_popup_menu = find_child_uicomponent(FreiyaTMod.freiya_trade_factions_dropdown,"popup_menu")
        FreiyaTMod.freiya_trade_factions_listview = find_child_uicomponent(FreiyaTMod.freiya_trade_factions_popup_menu,"listview")
        FreiyaTMod.freiya_trade_factions_list_clip = find_child_uicomponent(FreiyaTMod.freiya_trade_factions_listview,"list_clip")
        FreiyaTMod.freiya_trade_factions_list_box = find_child_uicomponent(FreiyaTMod.freiya_trade_factions_list_clip,"list_box")
        FreiyaTMod.freiya_trade_factions_template_dropdown_entry = find_child_uicomponent(FreiyaTMod.freiya_trade_factions_list_box,"template_dropdown_entry")
        FreiyaTMod.freiya_trade_factions_template_dropdown_entry:SetVisible(false)	
            
        FreiyaTMod.freiya_trade_factions_selected_context_display = find_child_uicomponent(FreiyaTMod.freiya_trade_factions_dropdown,"selected_context_display")

        FreiyaTMod.freiya_trade_factions_selected_context_display:CopyComponent("freiya_trade_factions_desc_label")
        FreiyaTMod.freiya_trade_factions_desc_label = find_child_uicomponent(FreiyaTMod.freiya_trade_factions_dropdown,"freiya_trade_factions_desc_label")
        FreiyaTMod.freiya_trade_panel_header:Adopt(FreiyaTMod.freiya_trade_factions_desc_label:Address())
        FreiyaTMod.freiya_trade_factions_desc_label:SetCanResizeWidth(true)
        FreiyaTMod.freiya_trade_factions_desc_label:SetCanResizeHeight(true)
        FreiyaTMod.freiya_trade_factions_desc_label:Resize(500,500)
        FreiyaTMod.freiya_trade_factions_desc_label:SetTextVAlign("top")
        FreiyaTMod.freiya_trade_factions_desc_label:SetTextHAlign("centre")
        FreiyaTMod.freiya_trade_factions_desc_label:SetDockingPoint(2)
        
        if cm:is_multiplayer() then
            FreiyaTMod.freiya_trade_factions_desc_label:SetDockOffset(400,100)
        else
            FreiyaTMod.freiya_trade_factions_desc_label:SetDockOffset(0,100)
            --FreiyaTMod.freiya_trade_factions_desc_label:SetDockOffset(400,100)
        end
        
        FreiyaTMod.freiya_trade_factions_desc_label:SetStateText(common.get_localised_string("freiya_trade_factions_desc_label_loc"))
        
        -- List all factions that have been met or not, that own at least X settlements and that are at war with the player or not (depending on the options)
        local freiya_trade_factions = {}
        --local player_faction = cm:get_faction(freiya_trade_current_player_name)

        if freiya_available_factions == "Met Factions (No War)" or freiya_available_factions == "Met Factions (With War)" then
            local met_factions = freiya_trade_current_player:factions_met()
            for i = 0, met_factions:num_items() - 1 do
                local current_faction = met_factions:item_at(i)
            
                if freiya_available_factions == "Met Factions (No War)" and not freiya_trade_current_player:at_war_with(current_faction) and current_faction:region_list():num_items() >= tonumber(freiya_ai_min_region) then
                    local loc_faction_name = common.get_localised_string("factions_screen_name_" .. current_faction:name())
                    table.insert(freiya_trade_factions, { loc_faction_name, current_faction:name() } )
                elseif freiya_available_factions == "Met Factions (With War)" and current_faction:region_list():num_items() >= tonumber(freiya_ai_min_region) then
                    local loc_faction_name = common.get_localised_string("factions_screen_name_" .. current_faction:name())
                    table.insert(freiya_trade_factions, { loc_faction_name, current_faction:name() } )
                end
            end
        elseif freiya_available_factions == "All Factions (No War)" or freiya_available_factions == "All Factions (With War)" then
            local all_factions = cm:model():world():faction_list()
            for i = 0, all_factions:num_items() - 1 do
                local current_faction = all_factions:item_at(i)
            
                if freiya_available_factions == "All Factions (No War)" and not freiya_trade_current_player:at_war_with(current_faction) and current_faction:region_list():num_items() >= tonumber(freiya_ai_min_region) and freiya_trade_current_player ~= current_faction then
                    local loc_faction_name = common.get_localised_string("factions_screen_name_" .. current_faction:name())
                    if loc_faction_name ~= "" then
                        table.insert(freiya_trade_factions, { loc_faction_name, current_faction:name() } )
                    end
                elseif freiya_available_factions == "All Factions (With War)" and current_faction:region_list():num_items() >= tonumber(freiya_ai_min_region) and freiya_trade_current_player ~= current_faction then
                    local loc_faction_name = common.get_localised_string("factions_screen_name_" .. current_faction:name())
                    if loc_faction_name ~= "" then
                        table.insert(freiya_trade_factions, { loc_faction_name, current_faction:name() } )
                    end
                end
            end
        end
        
        -- Sort the factions table or stop the construction of the whole menu if no valid faction has been found
        if #freiya_trade_factions > 0 then
            freiya_find_factions = true
            table.sort(freiya_trade_factions, function (left, right) return left[1] < right[1] end)
        else
            freiya_find_factions = false
            FreiyaTMod.freiya_trade_factions_template_dropdown_entry:CopyComponent("no_faction_var")
            FreiyaTMod.no_faction_var = find_child_uicomponent(FreiyaTMod.freiya_trade_factions_list_box, "no_faction_var")
            FreiyaTMod.no_faction_label = find_child_uicomponent(FreiyaTMod.no_faction_var, "label_context_name")
            
            FreiyaTMod.no_faction_label:SetStateText(common.get_localised_string("no_faction_label_loc"))
            FreiyaTMod.freiya_trade_factions_selected_context_display:SetStateText(common.get_localised_string("freiya_trade_factions_selected_context_display_loc"))
            
            FreiyaTMod.no_faction_var:SetVisible(true)
            FreiyaTMod.freiya_trade_panel_desc:SetVisible(false)
            FreiyaTMod.freiya_trade_their_settlements:SetVisible(false)
            FreiyaTMod.freiya_trade_deal:SetVisible(false)
            FreiyaTMod.freiya_trade_factions_desc_label:SetVisible(false)
            return
        end
        
        -- Create an entry in the list box for each faction
        for i = 1, #freiya_trade_factions do
            FreiyaTMod.freiya_trade_factions_template_dropdown_entry:CopyComponent(freiya_trade_factions[i][2])
            freiya_factions_var[freiya_trade_factions[i][2]] = find_child_uicomponent(FreiyaTMod.freiya_trade_factions_list_box, freiya_trade_factions[i][2])
            freiya_factions_label[freiya_trade_factions[i][2]] = find_child_uicomponent(freiya_factions_var[freiya_trade_factions[i][2]],"label_context_name")
            freiya_factions_label[freiya_trade_factions[i][2]]:SetStateText(freiya_trade_factions[i][1])
            
            freiya_factions_var[freiya_trade_factions[i][2]]:SetVisible(true)
        end
        
        freiya_selected_faction = freiya_trade_factions[1][2]
        FreiyaTMod.freiya_trade_factions_selected_context_display:SetStateText(freiya_trade_factions[1][1])
        
        -- Add the faction flags to the panel
        local freiya_trade_flag_path = ""
        FreiyaTMod.freiya_trade_faction_our_flag = core:get_or_create_component("freiya_trade_faction_our_flag","ui/templates/panel_frame.twui.xml", FreiyaTMod.freiya_trade_panel_frame)
        freiya_trade_flag_path = common.get_context_value("CcoCampaignFaction", freiya_trade_current_player:command_queue_index(), "FactionFlagDir")
        FreiyaTMod.freiya_trade_faction_our_flag:SetDockingPoint(1)
        FreiyaTMod.freiya_trade_faction_our_flag:Resize(44, 44, true)
        FreiyaTMod.freiya_trade_faction_our_flag:SetDockOffset(350,150)
        FreiyaTMod.freiya_trade_faction_our_flag:SetCurrentStateImageDockOffset(0,11,3)
        FreiyaTMod.freiya_trade_faction_our_flag:SetImagePath(freiya_trade_flag_path .. "/mon_64.png", 0, true)
        
        FreiyaTMod.freiya_trade_faction_their_flag = core:get_or_create_component("freiya_trade_faction_their_flag","ui/templates/panel_frame.twui.xml", FreiyaTMod.freiya_trade_panel_frame)
        freiya_trade_flag_path = common.get_context_value("CcoCampaignFaction", cm:get_faction(freiya_selected_faction):command_queue_index(), "FactionFlagDir")
        FreiyaTMod.freiya_trade_faction_their_flag:SetDockingPoint(1)
        FreiyaTMod.freiya_trade_faction_their_flag:Resize(44, 44, true)
        FreiyaTMod.freiya_trade_faction_their_flag:SetDockOffset(1150,150)
        FreiyaTMod.freiya_trade_faction_their_flag:SetCurrentStateImageDockOffset(0,11,3)
        FreiyaTMod.freiya_trade_faction_their_flag:SetImagePath(freiya_trade_flag_path .. "/mon_64.png", 0, true)
        
        core:remove_listener("freiya_trade_faction_pressed_listener")
        -- Add the listeners to update the interface when selecting another faction in the list
        core:add_listener(
            "freiya_trade_faction_pressed_listener",
            "ComponentLClickUp",
            function(context)
                for k, v in pairs(freiya_factions_var) do
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
            "freiya_trade_faction_pressed_listener",
            "UITrigger",
            function(context)
                for k, v in pairs(freiya_factions_var) do
                    if context:trigger() == k then
                        return true
                    end
                end
            end,
            function(context)
                for k, v in pairs(freiya_factions_var) do
                    if context:trigger() == k then
                        freiya_selected_faction = k
                        FreiyaTMod.freiya_trade_factions_selected_context_display:SetStateText(common.get_localised_string("factions_screen_name_" .. k))
                        
                        if cm:get_faction(freiya_selected_faction):is_human() then
                            freiya_player_benefit = "Gold Gains"
                        else
                            freiya_player_benefit = "Diplomatic Gains"
                        end
                        
                        FreiyaTMod.freiya_trade_their_dropdown:Destroy()
                        FreiyaTMod.freiya_trade_their_desc_label:Destroy()
                        FreiyaTMod.freiya_trade_their_value_label:Destroy()
                        FreiyaTMod.freiya_trade_their_dropdown_preparation()
                        FreiyaTMod.freiya_trade_their_attitude_var:SimulateLClick()
        
                        local freiya_trade_their_flag_path = common.get_context_value("CcoCampaignFaction", cm:get_faction(freiya_selected_faction):command_queue_index(), "FactionFlagDir")
                        FreiyaTMod.freiya_trade_faction_their_flag:SetImagePath(freiya_trade_their_flag_path .. "/mon_64.png", 0, true)
                        
                        return
                    end
                end
            end,
            true
        )
        
        if freiya_find_factions then
            freiya_factions_var[freiya_trade_factions[1][2]]:SimulateLClick()
        else
            FreiyaTMod.no_faction_var:SimulateLClick()
        end
	end
	
	
    -- Create the factions list of players if it's a multiplayer game
    if cm:is_multiplayer() then
        freiya_trade_multiplayer_compat()
    end
    freiya_trade_factions_list()  
	
	
    -- Create the region listbox of the player's faction from the custom xml to have dropdown list with a scroll bar
    function FreiyaTMod.freiya_trade_our_dropdown_preparation()
		local freiya_our_regions_var = {}
		local freiya_our_regions_label = {}
		
        FreiyaTMod.freiya_trade_our_dropdown = core:get_or_create_component("freiya_trade_our_dropdown","UI/templates/freiya_dropdown_context.twui.xml", FreiyaTMod.freiya_trade_panel_frame)
        FreiyaTMod.freiya_trade_our_dropdown:SetDockingPoint(5)
        FreiyaTMod.freiya_trade_our_dropdown:SetDockOffset(-500,-100)

        FreiyaTMod.freiya_trade_our_popup_menu = find_child_uicomponent(FreiyaTMod.freiya_trade_our_dropdown,"popup_menu")
        FreiyaTMod.freiya_trade_our_popup_menu:RegisterTopMost()
		FreiyaTMod.freiya_trade_our_listview = find_child_uicomponent(FreiyaTMod.freiya_trade_our_popup_menu,"listview")
		FreiyaTMod.freiya_trade_our_list_clip = find_child_uicomponent(FreiyaTMod.freiya_trade_our_listview,"list_clip")	
        FreiyaTMod.freiya_trade_our_list_box = find_child_uicomponent(FreiyaTMod.freiya_trade_our_list_clip,"list_box")

        FreiyaTMod.freiya_trade_our_template_dropdown_entry = find_child_uicomponent(FreiyaTMod.freiya_trade_our_list_box,"template_dropdown_entry")
        FreiyaTMod.freiya_trade_our_template_dropdown_entry:SetVisible(false)

        FreiyaTMod.freiya_trade_our_selected_context_display = find_child_uicomponent(FreiyaTMod.freiya_trade_our_dropdown,"selected_context_display")
		
		-- Create the label showing our selected region information
		FreiyaTMod.freiya_trade_our_selected_context_display:CopyComponent("freiya_trade_our_desc_label")
		FreiyaTMod.freiya_trade_our_desc_label = find_child_uicomponent(FreiyaTMod.freiya_trade_our_dropdown,"freiya_trade_our_desc_label")
		FreiyaTMod.freiya_trade_panel_header:Adopt(FreiyaTMod.freiya_trade_our_desc_label:Address())
		FreiyaTMod.freiya_trade_our_desc_label:SetCanResizeWidth(true)
		FreiyaTMod.freiya_trade_our_desc_label:SetCanResizeHeight(true)
		FreiyaTMod.freiya_trade_our_desc_label:Resize(500,500)
		FreiyaTMod.freiya_trade_our_desc_label:SetDockingPoint(2)
		FreiyaTMod.freiya_trade_our_desc_label:SetTextHAlign("left")
		FreiyaTMod.freiya_trade_our_desc_label:SetTextVAlign("top")
		FreiyaTMod.freiya_trade_our_desc_label:SetDockOffset(-110,345)
        
        FreiyaTMod.freiya_trade_our_selected_context_display:CopyComponent("freiya_trade_our_value_label")
		FreiyaTMod.freiya_trade_our_value_label = find_child_uicomponent(FreiyaTMod.freiya_trade_our_dropdown,"freiya_trade_our_value_label")
		FreiyaTMod.freiya_trade_panel_header:Adopt(FreiyaTMod.freiya_trade_our_value_label:Address())
		FreiyaTMod.freiya_trade_our_value_label:SetCanResizeWidth(true)
		FreiyaTMod.freiya_trade_our_value_label:SetCanResizeHeight(true)
		FreiyaTMod.freiya_trade_our_value_label:Resize(500,500)
		FreiyaTMod.freiya_trade_our_value_label:SetDockingPoint(2)
		FreiyaTMod.freiya_trade_our_value_label:SetTextHAlign("left")
		FreiyaTMod.freiya_trade_our_value_label:SetTextVAlign("top")
		FreiyaTMod.freiya_trade_our_value_label:SetDockOffset(-110,460)
        FreiyaTMod.freiya_trade_our_value_label:SetVisible(false)

		-- Create the label showing the deal summary at the bottom of the panel
		FreiyaTMod.freiya_trade_our_selected_context_display:CopyComponent("freiya_trade_deal_details_desc")
		FreiyaTMod.freiya_trade_deal_details_desc = find_child_uicomponent(FreiyaTMod.freiya_trade_our_dropdown,"freiya_trade_deal_details_desc")
		FreiyaTMod.freiya_trade_panel_header:Adopt(FreiyaTMod.freiya_trade_deal_details_desc:Address())
		FreiyaTMod.freiya_trade_deal_details_desc:SetCanResizeWidth(true)
		FreiyaTMod.freiya_trade_deal_details_desc:SetCanResizeHeight(true)
		FreiyaTMod.freiya_trade_deal_details_desc:Resize(500,500)
		FreiyaTMod.freiya_trade_deal_details_desc:SetDockingPoint(2)
		FreiyaTMod.freiya_trade_deal_details_desc:SetTextHAlign("centre")
		FreiyaTMod.freiya_trade_deal_details_desc:SetTextVAlign("top")
		FreiyaTMod.freiya_trade_deal_details_desc:SetDockOffset(0,660)
		FreiyaTMod.freiya_trade_deal_details_desc:SetVisible(false)
		
		-- Create and sort the region list of the player's faction
		local freiya_trade_our_regions = {}
		--local player_faction = cm:get_faction(freiya_trade_current_player_name)
		local region_list = freiya_trade_current_player:region_list()

		for i = 0, region_list:num_items() - 1 do
			local current_region = region_list:item_at(i)
			local loc_region_name = common.get_localised_string("regions_onscreen_" .. current_region:name())
			table.insert(freiya_trade_our_regions, { loc_region_name, current_region:name() });
		end
		
		table.sort(freiya_trade_our_regions, function (left, right) return left[1] < right[1] end)
		
		-- Create a "Gold" entry in the player dropdown list
		FreiyaTMod.freiya_trade_our_template_dropdown_entry:CopyComponent("our_gold_var")
		FreiyaTMod.freiya_trade_our_gold_var = find_child_uicomponent(FreiyaTMod.freiya_trade_our_list_box, "our_gold_var")
		FreiyaTMod.freiya_trade_our_gold_label = find_child_uicomponent(FreiyaTMod.freiya_trade_our_gold_var, "label_context_name")
		
		FreiyaTMod.freiya_trade_our_gold_label:SetStateText(common.get_localised_string("freiya_trade_our_gold_label_loc"))
		
		FreiyaTMod.freiya_trade_our_gold_var:SetVisible(true)
        
		-- Create an entry in the list box for each region of the player's faction
		for i = 1, #freiya_trade_our_regions do
			FreiyaTMod.freiya_trade_our_template_dropdown_entry:CopyComponent(freiya_trade_our_regions[i][2])
			freiya_our_regions_var[freiya_trade_our_regions[i][2]] = find_child_uicomponent(FreiyaTMod.freiya_trade_our_list_box, freiya_trade_our_regions[i][2])
			freiya_our_regions_label[freiya_trade_our_regions[i][2]] = find_child_uicomponent(freiya_our_regions_var[freiya_trade_our_regions[i][2]],"label_context_name")
			freiya_our_regions_label[freiya_trade_our_regions[i][2]]:SetStateText(freiya_trade_our_regions[i][1])
			freiya_our_regions_var[freiya_trade_our_regions[i][2]]:SetVisible(true)
		end
		
		FreiyaTMod.freiya_trade_our_selected_context_display:SetStateText(common.get_localised_string("freiya_trade_our_selected_context_display_loc"))
		
		freiya_selected_our_deal = {}
		table.insert(freiya_selected_our_deal, "Gold" )
		FreiyaTMod.freiya_trade_our_desc_label:SetStateText(common.get_localised_string("freiya_trade_our_desc_label_loc") .. freiya_trade_current_player:treasury())
		
        core:remove_listener("freiya_trade_our_regions_pressed_listener")
        
        -- Add the listeners to update the interface when selecting any entry in the player's faction list
        core:add_listener(
		   "freiya_trade_our_regions_pressed_listener",
		   "ComponentLClickUp",
			function(context)
				for k, v in pairs(freiya_our_regions_var) do
					if context.string == FreiyaTMod.freiya_trade_our_gold_var:Id() or context.string == k then
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
		   "freiya_trade_our_regions_pressed_listener",
		   "UITrigger",
			function(context)
                for k, v in pairs(freiya_our_regions_var) do
					if context:trigger() == FreiyaTMod.freiya_trade_our_gold_var:Id() or context:trigger() == k then
						return true
					end
				end
			end,
			function(context)
				local our_region_level = nil
				local their_region_level = nil
				local whole_province_bonus = 0
                local whole_province_found = false
                local capital_bonus = 0
                local capital_found = false
				freiya_selected_our_deal = {}
				freiya_count_our_buildings = 0
				freiya_count_their_buildings = 0
				
				if context:trigger() == FreiyaTMod.freiya_trade_our_gold_var:Id() then
					FreiyaTMod.freiya_trade_our_selected_context_display:SetStateText(common.get_localised_string("freiya_trade_our_selected_context_display_loc"))
					
					table.insert(freiya_selected_our_deal, "Gold" )
					FreiyaTMod.freiya_trade_our_desc_label:SetStateText(common.get_localised_string("freiya_trade_our_desc_label_loc") .. freiya_trade_current_player:treasury())
					
				else
					-- Define the level and value of the currently selected region
					for k, v in pairs(freiya_our_regions_var) do
						if context:trigger() == k then
							FreiyaTMod.freiya_trade_our_selected_context_display:SetStateText(common.get_localised_string("regions_onscreen_" .. k))
							table.insert(freiya_selected_our_deal, k )
							
							local region_slots = cm:get_region(k):slot_list()
							for i = 0, region_slots:num_items() - 1 do
								local current_slot = region_slots:item_at(i)
								if current_slot:type() == "primary" then
									if current_slot:has_building() then
										local building = current_slot:building()
										local building_name = building:name()
										if string.match(building_name, "ruin") then
											our_region_level = 0
											table.insert(freiya_selected_our_deal, 0 )
										elseif string.match(building_name, "_1") then
											our_region_level = 1
											table.insert(freiya_selected_our_deal, 1 )
										elseif string.match(building_name, "_2") then
											our_region_level = 2
											table.insert(freiya_selected_our_deal, 2 )
										elseif string.match(building_name, "_3") then
											our_region_level = 3
											table.insert(freiya_selected_our_deal, 3 )
										elseif string.match(building_name, "_4") then
											our_region_level = 4
											table.insert(freiya_selected_our_deal, 4 )
										elseif string.match(building_name, "_5") then
											our_region_level = 5
											table.insert(freiya_selected_our_deal, 5 )
										else
											our_region_level = 3
											table.insert(freiya_selected_our_deal, 3 )
										end
									end
								end
								if current_slot:has_building() then
									freiya_count_our_buildings = freiya_count_our_buildings + 1
								end
							end

							break
						end
					end
				end
				
				if freiya_selected_their_deal[1] ~= "Relations" then
					local province = cm:get_region(freiya_selected_their_deal[1]):province()
					if cm:num_regions_controlled_in_province_by_faction(province, cm:get_faction(freiya_selected_faction)) == province:regions():num_items() then
						whole_province_bonus = tonumber(freiya_whole_province_bonus)
                        whole_province_found = true
					end
					
                    if freiya_selected_their_deal[1] == cm:get_faction(freiya_selected_faction):home_region():name() then
                        capital_bonus = tonumber(freiya_capital_bonus)
                        capital_found = true
                    end
                    
					local their_region_slots = cm:get_region(freiya_selected_their_deal[1]):slot_list()
					for i = 0, their_region_slots:num_items() - 1 do
						local their_current_slot = their_region_slots:item_at(i);
						if their_current_slot:type() == "primary" then
							if their_current_slot:has_building() then
								local their_building = their_current_slot:building()
								local their_building_name = their_building:name()
								if string.match(their_building_name, "ruin") then
									their_region_level = 0
									freiya_selected_their_deal[2] = 0
								elseif string.match(their_building_name, "_1") then
									their_region_level = 1
									freiya_selected_their_deal[2] = 1
								elseif string.match(their_building_name, "_2") then
									their_region_level = 2
									freiya_selected_their_deal[2] = 2
								elseif string.match(their_building_name, "_3") then
									their_region_level = 3
									freiya_selected_their_deal[2] = 3
								elseif string.match(their_building_name, "_4") then
									their_region_level = 4
									freiya_selected_their_deal[2] = 4
								elseif string.match(their_building_name, "_5") then
									their_region_level = 5
									freiya_selected_their_deal[2] = 5
								else
									their_region_level = 3
									freiya_selected_their_deal[2] = 3
								end
							end
						end
						if their_current_slot:has_building() then
							freiya_count_their_buildings = freiya_count_their_buildings + 1
						end
					end							
				end	

                FreiyaTMod.freiya_update_interface(our_region_level, their_region_level, whole_province_bonus, whole_province_found, capital_bonus, capital_found, freiya_selected_our_deal, freiya_count_our_buildings, freiya_count_their_buildings)
	
			end,
			true
		)
		
    end
    
	
	if freiya_find_factions then
		FreiyaTMod.freiya_trade_our_dropdown_preparation()
	end


	-- Create the region listbox of the AI's faction from the custom xml to have dropdown list with a scroll bar
    function FreiyaTMod.freiya_trade_their_dropdown_preparation()
		local freiya_their_regions_var = {}
		local freiya_their_regions_label = {}
		
        FreiyaTMod.freiya_trade_their_dropdown = core:get_or_create_component("freiya_trade_settings_their_dropdown","UI/templates/freiya_dropdown_context.twui.xml", FreiyaTMod.freiya_trade_panel_frame)
        FreiyaTMod.freiya_trade_their_dropdown:SetDockingPoint(5)
        FreiyaTMod.freiya_trade_their_dropdown:SetDockOffset(500,-100)

        FreiyaTMod.freiya_trade_their_popup_menu = find_child_uicomponent(FreiyaTMod.freiya_trade_their_dropdown,"popup_menu")
        FreiyaTMod.freiya_trade_their_popup_menu:RegisterTopMost()
		FreiyaTMod.freiya_trade_their_listview = find_child_uicomponent(FreiyaTMod.freiya_trade_their_popup_menu,"listview")
		FreiyaTMod.freiya_trade_their_list_clip = find_child_uicomponent(FreiyaTMod.freiya_trade_their_listview,"list_clip")
        FreiyaTMod.freiya_trade_their_list_box = find_child_uicomponent(FreiyaTMod.freiya_trade_their_list_clip,"list_box")
		
        FreiyaTMod.freiya_trade_their_template_dropdown_entry = find_child_uicomponent(FreiyaTMod.freiya_trade_their_list_box,"template_dropdown_entry")
        FreiyaTMod.freiya_trade_their_template_dropdown_entry:SetVisible(false)

        FreiyaTMod.freiya_trade_their_selected_context_display = find_child_uicomponent(FreiyaTMod.freiya_trade_their_dropdown,"selected_context_display")

		-- Create the label showing their selected region information
		FreiyaTMod.freiya_trade_their_selected_context_display:CopyComponent("freiya_trade_their_desc_label")
		FreiyaTMod.freiya_trade_their_desc_label = find_child_uicomponent(FreiyaTMod.freiya_trade_their_dropdown,"freiya_trade_their_desc_label")
		FreiyaTMod.freiya_trade_panel_header:Adopt(FreiyaTMod.freiya_trade_their_desc_label:Address())
		FreiyaTMod.freiya_trade_their_desc_label:SetCanResizeWidth(true)
		FreiyaTMod.freiya_trade_their_desc_label:SetCanResizeHeight(true)
		FreiyaTMod.freiya_trade_their_desc_label:Resize(500,500)
		FreiyaTMod.freiya_trade_their_desc_label:SetDockingPoint(2)
		FreiyaTMod.freiya_trade_their_desc_label:SetTextHAlign("left")
		FreiyaTMod.freiya_trade_their_desc_label:SetTextVAlign("top")
		FreiyaTMod.freiya_trade_their_desc_label:SetDockOffset(400,345)
        
        FreiyaTMod.freiya_trade_their_selected_context_display:CopyComponent("freiya_trade_their_value_label")
		FreiyaTMod.freiya_trade_their_value_label = find_child_uicomponent(FreiyaTMod.freiya_trade_their_dropdown,"freiya_trade_their_value_label")
		FreiyaTMod.freiya_trade_panel_header:Adopt(FreiyaTMod.freiya_trade_their_value_label:Address())
		FreiyaTMod.freiya_trade_their_value_label:SetCanResizeWidth(true)
		FreiyaTMod.freiya_trade_their_value_label:SetCanResizeHeight(true)
		FreiyaTMod.freiya_trade_their_value_label:Resize(500,500)
		FreiyaTMod.freiya_trade_their_value_label:SetDockingPoint(2)
		FreiyaTMod.freiya_trade_their_value_label:SetTextHAlign("left")
		FreiyaTMod.freiya_trade_their_value_label:SetTextVAlign("top")
		FreiyaTMod.freiya_trade_their_value_label:SetDockOffset(400,460)
        FreiyaTMod.freiya_trade_their_value_label:SetVisible(false)
		
		-- Create an entry in the list box for each region of the AI's faction
		local freiya_trade_their_regions = {}
		local their_region_list = cm:get_faction(freiya_selected_faction):region_list()
		for i = 0, their_region_list:num_items() - 1 do
			local current_their_region = their_region_list:item_at(i)
			local loc_their_region_name = common.get_localised_string("regions_onscreen_" .. current_their_region:name())
			table.insert(freiya_trade_their_regions, { loc_their_region_name, current_their_region:name() });
		end
		
		table.sort(freiya_trade_their_regions, function (left, right) return left[1] < right[1] end)
		
		-- Create an "Improve Relations" entry in the AI dropdown list
        FreiyaTMod.freiya_trade_their_template_dropdown_entry:CopyComponent("their_attitude_var")
		FreiyaTMod.freiya_trade_their_attitude_var = find_child_uicomponent(FreiyaTMod.freiya_trade_their_list_box, "their_attitude_var")
		FreiyaTMod.freiya_trade_their_attitude_label = find_child_uicomponent(FreiyaTMod.freiya_trade_their_attitude_var, "label_context_name")
		
        if freiya_player_benefit == "Diplomatic Gains" then
            FreiyaTMod.freiya_trade_their_attitude_label:SetStateText(common.get_localised_string("freiya_trade_their_attitude_label_loc"))
        else
            FreiyaTMod.freiya_trade_their_attitude_label:SetStateText(common.get_localised_string("freiya_trade_our_gold_label_loc"))
        end
		
		FreiyaTMod.freiya_trade_their_attitude_var:SetVisible(true)
		
		-- Create an entry in the list box for each region of the AI's faction
		for i = 1, #freiya_trade_their_regions do
			FreiyaTMod.freiya_trade_their_template_dropdown_entry:CopyComponent(freiya_trade_their_regions[i][2])
			freiya_their_regions_var[freiya_trade_their_regions[i][2]] = find_child_uicomponent(FreiyaTMod.freiya_trade_their_list_box, freiya_trade_their_regions[i][2])
			freiya_their_regions_label[freiya_trade_their_regions[i][2]] = find_child_uicomponent(freiya_their_regions_var[freiya_trade_their_regions[i][2]],"label_context_name")
			freiya_their_regions_label[freiya_trade_their_regions[i][2]]:SetStateText(freiya_trade_their_regions[i][1])
			freiya_their_regions_var[freiya_trade_their_regions[i][2]]:SetVisible(true)
		end

        if freiya_player_benefit == "Diplomatic Gains" then
            FreiyaTMod.freiya_trade_their_selected_context_display:SetStateText(common.get_localised_string("freiya_trade_their_selected_context_display_loc"))
        else
            FreiyaTMod.freiya_trade_their_selected_context_display:SetStateText(common.get_localised_string("freiya_trade_our_selected_context_display_loc"))
        end
		freiya_selected_their_deal = {}
		table.insert(freiya_selected_their_deal, "Relations" )
		FreiyaTMod.freiya_trade_their_desc_label:SetStateText(common.get_localised_string("freiya_trade_their_desc_labela_loc") .. math.floor(cm:get_faction(freiya_selected_faction):diplomatic_attitude_towards(freiya_trade_current_player_name)))
		
		core:remove_listener("freiya_trade_their_regions_pressed_listener")
		
		-- Add the listeners to update the interface when selecting any entry in the AI's faction list
        core:add_listener(
		   "freiya_trade_their_regions_pressed_listener",
		   "ComponentLClickUp",
			function(context)
				for k, v in pairs(freiya_their_regions_var) do
					if context.string == FreiyaTMod.freiya_trade_their_attitude_var:Id() or context.string == k then
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
		   "freiya_trade_their_regions_pressed_listener",
		   "UITrigger",
			function(context)
				for k, v in pairs(freiya_their_regions_var) do
					if context:trigger() == FreiyaTMod.freiya_trade_their_attitude_var:Id() or context:trigger() == k then
						return true
					end
				end
			end,
			function(context)
				local their_region_level = nil
				local our_region_level = nil
				local whole_province_bonus = 0
                local whole_province_found = false
                local capital_bonus = 0
                local capital_found = false
				freiya_selected_their_deal = {}
				freiya_count_our_buildings = 0
				freiya_count_their_buildings = 0
				
				if context:trigger() == FreiyaTMod.freiya_trade_their_attitude_var:Id() then
                    if freiya_player_benefit == "Diplomatic Gains" then
                        FreiyaTMod.freiya_trade_their_selected_context_display:SetStateText(common.get_localised_string("freiya_trade_their_selected_context_display_loc"))
                    else
                        FreiyaTMod.freiya_trade_their_selected_context_display:SetStateText(common.get_localised_string("freiya_trade_our_selected_context_display_loc"))
                    end
					table.insert(freiya_selected_their_deal, "Relations" )
					
					-- Display the treasury instead of the diplomcy attitude if the chosen faction to trade with is a player
					if cm:is_multiplayer() and cm:get_faction(freiya_selected_faction):is_human() then
                        FreiyaTMod.freiya_trade_their_desc_label:SetStateText(common.get_localised_string("freiya_trade_our_desc_label_loc") .. cm:get_faction(freiya_selected_faction):treasury())
					else
                        FreiyaTMod.freiya_trade_their_desc_label:SetStateText(common.get_localised_string("freiya_trade_their_desc_labela_loc") .. math.floor(cm:get_faction(freiya_selected_faction):diplomatic_attitude_towards(freiya_trade_current_player_name)))
                    end
					
				else		
					-- Define the level and value of the currently selected region
					for k, v in pairs(freiya_their_regions_var) do
						if context:trigger() == k then
							FreiyaTMod.freiya_trade_their_selected_context_display:SetStateText(common.get_localised_string("regions_onscreen_" .. k))
							table.insert(freiya_selected_their_deal, k )
							
							local province = cm:get_region(freiya_selected_their_deal[1]):province()
							if cm:num_regions_controlled_in_province_by_faction(province, cm:get_faction(freiya_selected_faction)) == province:regions():num_items() then
								whole_province_bonus = tonumber(freiya_whole_province_bonus)
                                whole_province_found = true
							end
                            
                            if freiya_selected_their_deal[1] == cm:get_faction(freiya_selected_faction):home_region():name() then
                                capital_bonus = tonumber(freiya_capital_bonus)
                                capital_found = true
                            end
							
							local region_slots = cm:get_region(k):slot_list()	
							for i = 0, region_slots:num_items() - 1 do
								local current_slot = region_slots:item_at(i);
								if current_slot:type() == "primary" then
									if current_slot:has_building() then
										local building = current_slot:building()
										local building_name = building:name()
										if string.match(building_name, "ruin") then
											their_region_level = 0
											table.insert(freiya_selected_their_deal, 0 )
										elseif string.match(building_name, "_1") then
											their_region_level = 1
											table.insert(freiya_selected_their_deal, 1 )
										elseif string.match(building_name, "_2") then
											their_region_level = 2
											table.insert(freiya_selected_their_deal, 2 )
										elseif string.match(building_name, "_3") then
											their_region_level = 3
											table.insert(freiya_selected_their_deal, 3 )
										elseif string.match(building_name, "_4") then
											their_region_level = 4
											table.insert(freiya_selected_their_deal, 4 )
										elseif string.match(building_name, "_5") then
											their_region_level = 5
											table.insert(freiya_selected_their_deal, 5 )
										else
											their_region_level = 3
											table.insert(freiya_selected_their_deal, 3 )
										end
									end
								end
								if current_slot:has_building() then
									freiya_count_their_buildings = freiya_count_their_buildings + 1
								end
							end
							
							break
						end
					end
				end
				
				if freiya_selected_our_deal[1] ~= "Gold" then
					local our_region_slots = cm:get_region(freiya_selected_our_deal[1]):slot_list()	
					
					for i = 0, our_region_slots:num_items() - 1 do
						local our_current_slot = our_region_slots:item_at(i)
						if our_current_slot:type() == "primary" then
							if our_current_slot:has_building() then
								local our_building = our_current_slot:building()
								local our_building_name = our_building:name()
								if string.match(our_building_name, "ruin") then
									our_region_level = 0
									freiya_selected_our_deal[2] = 0
								elseif string.match(our_building_name, "_1") then
									our_region_level = 1
									freiya_selected_our_deal[2] = 1
								elseif string.match(our_building_name, "_2") then
									our_region_level = 2
									freiya_selected_our_deal[2] = 2
								elseif string.match(our_building_name, "_3") then
									our_region_level = 3
									freiya_selected_our_deal[2] = 3
								elseif string.match(our_building_name, "_4") then
									our_region_level = 4
									freiya_selected_our_deal[2] = 4
								elseif string.match(our_building_name, "_5") then
									our_region_level = 5
									freiya_selected_our_deal[2] = 5
								else
									our_region_level = 3
									freiya_selected_our_deal[2] = 3
								end
							end
						end
						if our_current_slot:has_building() then
							freiya_count_our_buildings = freiya_count_our_buildings + 1
						end
					end
				end
				
				FreiyaTMod.freiya_update_interface(our_region_level, their_region_level, whole_province_bonus, whole_province_found, capital_bonus, capital_found, freiya_selected_our_deal, freiya_count_our_buildings, freiya_count_their_buildings)

			end,
			true
		)

    end
	
	if freiya_find_factions then
		FreiyaTMod.freiya_trade_their_dropdown_preparation()
	end
	
    
    -- Update the interface when clicking on any of the region list boxes and calculate the deal
    function FreiyaTMod.freiya_update_interface(our_region_level, their_region_level, whole_province_bonus, whole_province_found, capital_bonus, capital_found, freiya_selected_our_deal, freiya_count_our_buildings, freiya_count_their_buildings)
        local turn_modifier = 0
        local attitude_mod = 0
        local vassal_mod = 0
        local ally_mod = 0
        freiya_trade_total_cost = 0
        attitude_not_enough_cash = 0
        freiya_our_gold_value = 0
        freiya_our_attitude_value = 0
        freiya_their_gold_cost = 0
        freiya_their_attitude_value = 0
        
        turn_modifier = 1 + tonumber(freiya_turn_modifier) * cm:turn_number()
        
        if cm:get_faction(freiya_selected_faction):is_vassal_of(freiya_trade_current_player) then
            vassal_mod = tonumber(freiya_vassal_discount)
        elseif cm:get_faction(freiya_selected_faction):is_ally_vassal_or_client_state_of(freiya_trade_current_player) then
            ally_mod = tonumber(freiya_ally_discount)
        end

        -- Calculate the value of the selected settlement
        if our_region_level ~= nil then
            -- Player's gold value
            freiya_our_gold_value = math.floor(tonumber(freiya_region_level_gold[our_region_level + 1]) * turn_modifier * ((freiya_count_our_buildings * tonumber(freiya_gold_per_buildings_modifier)) + 1 ))
            
            -- Player's attitude value
            freiya_our_attitude_value = math.ceil(math.floor(tonumber(freiya_region_level_attitude[our_region_level + 1]) * ((freiya_count_our_buildings * tonumber(freiya_attitude_per_buildings_modifier)) + 1 ))/5)*5
            
            if cm:is_multiplayer() and cm:get_faction(freiya_selected_faction):is_human() then
                if freiya_our_gold_value > 0 and vassal_mod ~= 0 then
                    freiya_our_gold_value = math.floor(freiya_our_gold_value - (freiya_our_gold_value * vassal_mod))
                elseif freiya_our_gold_value > 0 and ally_mod ~= 0 then
                    freiya_our_gold_value = math.floor(freiya_our_gold_value - (freiya_our_gold_value * ally_mod))
                end
                
                if freiya_our_gold_value < 0 then
                    freiya_our_gold_value = 0
                end
                
                
                if freiya_our_attitude_value > 0 and vassal_mod ~= 0 then
                    freiya_our_attitude_value = math.floor(freiya_our_attitude_value - (freiya_our_attitude_value * vassal_mod))
                elseif freiya_our_attitude_value > 0 and ally_mod ~= 0 then
                    freiya_our_attitude_value = math.floor(freiya_our_attitude_value - (freiya_our_attitude_value * ally_mod))
                end

                if freiya_our_attitude_value < 0 then
                    freiya_our_attitude_value = 0
                else
                    freiya_our_attitude_value = math.ceil(freiya_our_attitude_value / 5 ) * 5
                end
            end          
        end
        
        if their_region_level ~= nil then
            if cm:is_multiplayer() and cm:get_faction(freiya_selected_faction):is_human() then
                freiya_their_gold_cost = math.floor(tonumber(freiya_region_level_gold[their_region_level + 1]) * turn_modifier * ((freiya_count_their_buildings * tonumber(freiya_gold_per_buildings_modifier)) + 1 ))
                
                if freiya_their_gold_cost > 0 and vassal_mod ~= 0 then
                    freiya_their_gold_cost = math.floor(freiya_their_gold_cost - (freiya_their_gold_cost * vassal_mod))
                elseif freiya_their_gold_cost > 0 and ally_mod ~= 0 then
                    freiya_their_gold_cost = math.floor(freiya_their_gold_cost - (freiya_their_gold_cost * ally_mod))
                end
                
                if freiya_their_gold_cost < 0 then
                    freiya_their_gold_cost = 0
                end
                
                
                freiya_their_attitude_value = math.ceil(math.floor(tonumber(freiya_region_level_attitude[their_region_level + 1]) * ((freiya_count_their_buildings * tonumber(freiya_attitude_per_buildings_modifier)) + 1 ))/5)*5
                
                if freiya_their_attitude_value > 0 and vassal_mod ~= 0 then
                    freiya_their_attitude_value = math.floor(freiya_their_attitude_value - (freiya_their_attitude_value * vassal_mod))
                elseif freiya_their_attitude_value > 0 and ally_mod ~= 0 then
                    freiya_their_attitude_value = math.floor(freiya_their_attitude_value - (freiya_their_attitude_value * ally_mod))
                end

                if freiya_their_attitude_value < 0 then
                    freiya_their_attitude_value = 0
                else
                    freiya_their_attitude_value = math.ceil(freiya_their_attitude_value / 5 ) * 5
                end
                
            else
                -- AI's gold cost
                freiya_their_gold_cost = math.floor(tonumber(freiya_region_level_gold[their_region_level + 1]) * turn_modifier * ((freiya_count_their_buildings * tonumber(freiya_gold_per_buildings_modifier)) + 1 ) + whole_province_bonus + capital_bonus)

                if freiya_their_gold_cost > 0 then
                    attitude_mod = cm:get_faction(freiya_selected_faction):diplomatic_attitude_towards(freiya_trade_current_player_name) * tonumber(freiya_relation_discount)
                    if (tonumber(freiya_relation_cap)/100) < attitude_mod then
                        attitude_mod = tonumber(freiya_relation_cap / 100)
                    elseif attitude_mod < 0 and (tonumber(freiya_relation_cap)/100) * -1 > attitude_mod then
                        attitude_mod = tonumber(freiya_relation_cap / 100) * -1
                    end
                
                    freiya_their_gold_cost = math.floor(freiya_their_gold_cost - (freiya_their_gold_cost * attitude_mod))
                    
                    if freiya_their_gold_cost > 0 and vassal_mod ~= 0 then
                        freiya_their_gold_cost = math.floor(freiya_their_gold_cost - (freiya_their_gold_cost * vassal_mod))
                    elseif freiya_their_gold_cost > 0 and ally_mod ~= 0 then
                        freiya_their_gold_cost = math.floor(freiya_their_gold_cost - (freiya_their_gold_cost * ally_mod))
                    end
                end
                
                if freiya_their_gold_cost < 0 then
                    freiya_their_gold_cost = 0
                end
                
                
                -- AI's attitude cost
                freiya_their_attitude_value = math.ceil(math.floor(tonumber(freiya_region_level_attitude[their_region_level + 1]) * ((freiya_count_their_buildings * tonumber(freiya_attitude_per_buildings_modifier)) + 1 ) + ( whole_province_bonus + capital_bonus)/(tonumber(freiya_region_level_gold[4])/tonumber(freiya_region_level_attitude[4])))/5)*5
                
                if freiya_their_attitude_value > 0 then
                    attitude_mod = cm:get_faction(freiya_selected_faction):diplomatic_attitude_towards(freiya_trade_current_player_name) * tonumber(freiya_relation_discount)
                    if (tonumber(freiya_relation_cap)/100) < attitude_mod then
                        attitude_mod = tonumber(freiya_relation_cap / 100)
                    end
                    
                    freiya_their_attitude_value = math.floor(freiya_their_attitude_value - (freiya_their_attitude_value * attitude_mod))

                    if freiya_their_attitude_value > 0 and vassal_mod ~= 0 then
                        freiya_their_attitude_value = math.floor(freiya_their_attitude_value - (freiya_their_attitude_value * vassal_mod))
                    elseif freiya_their_attitude_value > 0 and ally_mod ~= 0 then
                        freiya_their_attitude_value = math.floor(freiya_their_attitude_value - (freiya_their_attitude_value * ally_mod))
                    end
                end

                if freiya_their_attitude_value < 0 then
                    freiya_their_attitude_value = 0
                else
                    freiya_their_attitude_value = math.ceil(freiya_their_attitude_value / 5 ) * 5
                end
            end
        end
        
        
        -- Update the infos and value of region on the labels next to the list boxes
        if cm:is_multiplayer() and cm:get_faction(freiya_selected_faction):is_human() then
            if freiya_selected_their_deal[1] ~= "Relations" then
                FreiyaTMod.freiya_trade_their_desc_label:SetStateText(common.get_localised_string("freiya_trade_our_desc_label_loc") .. cm:get_faction(freiya_selected_faction):treasury() .. common.get_localised_string("freiya_trade_desc_labela_loc") .. their_region_level .. common.get_localised_string("freiya_trade_desc_labelb_loc") .. freiya_count_their_buildings)
            end
                                                    
            if freiya_selected_their_deal[1] ~= "Relations" then
                FreiyaTMod.freiya_trade_their_value_label:SetStateText(common.get_localised_string("freiya_trade_value_label_value_loc") .. freiya_their_gold_cost .. " " .. common.get_localised_string("freiya_trade_desc_labeld_loc"))
                FreiyaTMod.freiya_trade_their_value_label:SetVisible(true)
            else
                FreiyaTMod.freiya_trade_their_value_label:SetVisible(false)
            end
            
            if freiya_selected_our_deal[1] ~= "Gold"  then
                FreiyaTMod.freiya_trade_our_desc_label:SetStateText(common.get_localised_string("freiya_trade_our_desc_label_loc") .. freiya_trade_current_player:treasury() .. common.get_localised_string("freiya_trade_desc_labela_loc") .. our_region_level .. common.get_localised_string("freiya_trade_desc_labelb_loc") .. freiya_count_our_buildings)
                
                FreiyaTMod.freiya_trade_our_value_label:SetStateText(common.get_localised_string("freiya_trade_value_label_value_loc") .. freiya_our_gold_value .. " " .. common.get_localised_string("freiya_trade_desc_labeld_loc"))
                FreiyaTMod.freiya_trade_our_value_label:SetVisible(true)
            end
        else
            if freiya_selected_their_deal[1] ~= "Relations" and whole_province_found and not capital_found then
                FreiyaTMod.freiya_trade_their_desc_label:SetStateText(common.get_localised_string("freiya_trade_their_desc_labela_loc") .. math.floor(cm:get_faction(freiya_selected_faction):diplomatic_attitude_towards(freiya_trade_current_player_name)) .. common.get_localised_string("freiya_trade_desc_labela_loc") .. their_region_level .. common.get_localised_string("freiya_trade_desc_labelb_loc") .. freiya_count_their_buildings .. common.get_localised_string("freiya_trade_their_desc_labelb_loc"))
                
            elseif freiya_selected_their_deal[1] ~= "Relations" and whole_province_found and capital_found then
                FreiyaTMod.freiya_trade_their_desc_label:SetStateText(common.get_localised_string("freiya_trade_their_desc_labela_loc") .. math.floor(cm:get_faction(freiya_selected_faction):diplomatic_attitude_towards(freiya_trade_current_player_name)) .. common.get_localised_string("freiya_trade_desc_labela_loc") .. their_region_level .. common.get_localised_string("freiya_trade_desc_labelb_loc") .. freiya_count_their_buildings .. common.get_localised_string("freiya_trade_their_desc_labelb_loc") .. common.get_localised_string("freiya_trade_their_desc_labelc_loc"))
                
            elseif freiya_selected_their_deal[1] ~= "Relations" and not whole_province_found and not capital_found then
                FreiyaTMod.freiya_trade_their_desc_label:SetStateText(common.get_localised_string("freiya_trade_their_desc_labela_loc") .. math.floor(cm:get_faction(freiya_selected_faction):diplomatic_attitude_towards(freiya_trade_current_player_name)) .. common.get_localised_string("freiya_trade_desc_labela_loc") .. their_region_level .. common.get_localised_string("freiya_trade_desc_labelb_loc") .. freiya_count_their_buildings)
                
            elseif freiya_selected_their_deal[1] ~= "Relations" and not whole_province_found and capital_found then
                FreiyaTMod.freiya_trade_their_desc_label:SetStateText(common.get_localised_string("freiya_trade_their_desc_labela_loc") .. math.floor(cm:get_faction(freiya_selected_faction):diplomatic_attitude_towards(freiya_trade_current_player_name)) .. common.get_localised_string("freiya_trade_desc_labela_loc") .. their_region_level .. common.get_localised_string("freiya_trade_desc_labelb_loc") .. freiya_count_their_buildings .. common.get_localised_string("freiya_trade_their_desc_labelc_loc"))
            
            end
                                                    
            if freiya_selected_their_deal[1] ~= "Relations" then
                FreiyaTMod.freiya_trade_their_value_label:SetStateText(common.get_localised_string("freiya_trade_value_label_value_loc") .. freiya_their_gold_cost .. " " .. common.get_localised_string("freiya_trade_desc_labeld_loc"))
                FreiyaTMod.freiya_trade_their_value_label:SetVisible(true)
            else
                FreiyaTMod.freiya_trade_their_value_label:SetVisible(false)
            end
            
            if freiya_selected_our_deal[1] ~= "Gold" and freiya_player_benefit == "Diplomatic Gains" then
                FreiyaTMod.freiya_trade_our_desc_label:SetStateText(common.get_localised_string("freiya_trade_our_desc_label_loc") .. freiya_trade_current_player:treasury() .. common.get_localised_string("freiya_trade_desc_labela_loc") .. our_region_level .. common.get_localised_string("freiya_trade_desc_labelb_loc") .. freiya_count_our_buildings)
                
                FreiyaTMod.freiya_trade_our_value_label:SetStateText(common.get_localised_string("freiya_trade_value_label_value_loc") .. "+" .. freiya_our_attitude_value .. " " .. common.get_localised_string("freiya_trade_desc_labele_loc"))
                FreiyaTMod.freiya_trade_our_value_label:SetVisible(true)
                
            elseif freiya_selected_our_deal[1] ~= "Gold" and freiya_player_benefit == "Gold Gains" then
                FreiyaTMod.freiya_trade_our_desc_label:SetStateText(common.get_localised_string("freiya_trade_our_desc_label_loc") .. freiya_trade_current_player:treasury() .. common.get_localised_string("freiya_trade_desc_labela_loc") .. our_region_level .. common.get_localised_string("freiya_trade_desc_labelb_loc") .. freiya_count_our_buildings)
                
                FreiyaTMod.freiya_trade_our_value_label:SetStateText(common.get_localised_string("freiya_trade_value_label_value_loc") .. freiya_our_gold_value .. " " .. common.get_localised_string("freiya_trade_desc_labeld_loc"))
                FreiyaTMod.freiya_trade_our_value_label:SetVisible(true)
            end
        end
        
        if freiya_selected_our_deal[1] == "Gold" then
            FreiyaTMod.freiya_trade_our_value_label:SetVisible(false)
        end
        
        
        -- Update the deal summary depending on what entries are selected in both region list boxes
        if freiya_selected_their_deal[1] ~= "Relations" then
            FreiyaTMod.freiya_trade_deal:SetVisible(true)
            FreiyaTMod.freiya_trade_deal_details_desc:SetVisible(true)
            FreiyaTMod.freiya_trade_deal_details_desc:SetStateText(common.get_localised_string("freiya_trade_deal_details_desca_loc") .. common.get_localised_string("regions_onscreen_" .. freiya_selected_their_deal[1]))
            FreiyaTMod.freiya_trade_panel_confirm:SetDisabled(false)
            FreiyaTMod.freiya_trade_panel_confirm:SetImagePath("ui/campaign ui/message_icons/event_diplomacy_positive.png", 0, false)
            FreiyaTMod.freiya_trade_panel_confirm:SetTooltipText(common.get_localised_string("freiya_trade_panel_confirmb_loc"), common.get_localised_string("freiya_trade_panel_confirmb_loc"), true)
            return
        end
					
        if freiya_selected_our_deal[1] == "Gold" and freiya_selected_their_deal[1] ~= "Relations" then
            freiya_trade_total_cost = freiya_their_gold_cost
        
            -- Blocks the selling of the last settlement
            --if cm:get_faction(freiya_selected_faction):region_list():num_items() == 1 then
            --    FreiyaTMod.freiya_trade_deal_details_desc:SetStateText(common.get_localised_string("freiya_trade_deal_last_region_loc"))
						
            --    FreiyaTMod.freiya_trade_panel_confirm:SetDisabled(true)
            --    FreiyaTMod.freiya_trade_panel_confirm:SetImagePath("ui/campaign ui/message_icons/event_diplomacy_negative.png", 0, false)
            --    FreiyaTMod.freiya_trade_panel_confirm:SetTooltipText(common.get_localised_string("freiya_trade_deal_last_region_loc"), common.get_localised_string("freiya_trade_deal_last_region_loc"), true)
            --elseif freiya_trade_current_player:treasury() >= freiya_trade_total_cost then
            if freiya_trade_current_player:treasury() >= freiya_trade_total_cost then
                FreiyaTMod.freiya_trade_deal_details_desc:SetStateText(common.get_localised_string("freiya_trade_deal_details_desca_loc") .. freiya_trade_total_cost .. " " .. common.get_localised_string("freiya_trade_deal_details_descb_loc") .. common.get_localised_string("regions_onscreen_" .. freiya_selected_their_deal[1]))
						
                FreiyaTMod.freiya_trade_panel_confirm:SetDisabled(false)
                FreiyaTMod.freiya_trade_panel_confirm:SetImagePath("ui/campaign ui/message_icons/event_diplomacy_positive.png", 0, false)
                FreiyaTMod.freiya_trade_panel_confirm:SetTooltipText(common.get_localised_string("freiya_trade_panel_confirmb_loc"), common.get_localised_string("freiya_trade_panel_confirmb_loc"), true)
            else
                FreiyaTMod.freiya_trade_deal_details_desc:SetStateText(common.get_localised_string("freiya_trade_deal_details_desca_loc") .. freiya_trade_total_cost .. " " .. common.get_localised_string("freiya_trade_deal_details_descc_loc") .. common.get_localised_string("regions_onscreen_" .. freiya_selected_their_deal[1]))
						
                FreiyaTMod.freiya_trade_panel_confirm:SetDisabled(true)
                FreiyaTMod.freiya_trade_panel_confirm:SetImagePath("ui/campaign ui/message_icons/event_diplomacy_negative.png", 0, false)
                FreiyaTMod.freiya_trade_panel_confirm:SetTooltipText(common.get_localised_string("freiya_trade_panel_confirmc_loc"), common.get_localised_string("freiya_trade_panel_confirmc_loc"), true)
            end	
					
        elseif freiya_selected_our_deal[1] ~= "Gold" and freiya_selected_their_deal[1] == "Relations" and freiya_player_benefit == "Diplomatic Gains" then
            freiya_trade_total_cost = freiya_our_attitude_value
					
            FreiyaTMod.freiya_trade_deal_details_desc:SetStateText(common.get_localised_string("freiya_trade_deal_details_desca_loc") .. common.get_localised_string("regions_onscreen_" .. freiya_selected_our_deal[1]) .. common.get_localised_string("freiya_trade_deal_details_descd_loc") .. freiya_trade_total_cost .. " " .. common.get_localised_string("freiya_trade_desc_labele_loc"))
					
            FreiyaTMod.freiya_trade_panel_confirm:SetDisabled(false)
            FreiyaTMod.freiya_trade_panel_confirm:SetImagePath("ui/campaign ui/message_icons/event_diplomacy_positive.png", 0, false)
            FreiyaTMod.freiya_trade_panel_confirm:SetTooltipText(common.get_localised_string("freiya_trade_panel_confirmb_loc"), common.get_localised_string("freiya_trade_panel_confirmb_loc"), true)
                                                
        elseif freiya_selected_our_deal[1] ~= "Gold" and freiya_selected_their_deal[1] == "Relations" and freiya_player_benefit == "Gold Gains" then
            freiya_trade_total_cost = freiya_our_gold_value
            
            if cm:get_faction(freiya_selected_faction):treasury() >= freiya_trade_total_cost then
                FreiyaTMod.freiya_trade_deal_details_desc:SetStateText(common.get_localised_string("freiya_trade_deal_details_desca_loc") .. common.get_localised_string("regions_onscreen_" .. freiya_selected_our_deal[1]) .. common.get_localised_string("freiya_trade_deal_details_desce_loc") .. freiya_trade_total_cost .. " " .. common.get_localised_string("freiya_trade_desc_labeld_loc"))
                        
                FreiyaTMod.freiya_trade_panel_confirm:SetDisabled(false)
                FreiyaTMod.freiya_trade_panel_confirm:SetImagePath("ui/campaign ui/message_icons/event_diplomacy_positive.png", 0, false)
                FreiyaTMod.freiya_trade_panel_confirm:SetTooltipText(common.get_localised_string("freiya_trade_panel_confirmb_loc"), common.get_localised_string("freiya_trade_panel_confirmb_loc"), true)
            elseif cm:get_faction(freiya_selected_faction):treasury() < freiya_trade_total_cost then
                if cm:is_multiplayer() and cm:get_faction(freiya_selected_faction):is_human() then
                    FreiyaTMod.freiya_trade_deal_details_desc:SetStateText(common.get_localised_string("freiya_trade_deal_details_desca_loc") .. common.get_localised_string("regions_onscreen_" .. freiya_selected_our_deal[1]) .. common.get_localised_string("freiya_trade_deal_details_desce_loc") .. freiya_trade_total_cost .. " " .. common.get_localised_string("freiya_trade_deal_details_descmp_loc"))
						
                    FreiyaTMod.freiya_trade_panel_confirm:SetDisabled(true)
                    FreiyaTMod.freiya_trade_panel_confirm:SetImagePath("ui/campaign ui/message_icons/event_diplomacy_negative.png", 0, false)
                    FreiyaTMod.freiya_trade_panel_confirm:SetTooltipText(common.get_localised_string("freiya_trade_panel_confirmc_loc"), common.get_localised_string("freiya_trade_panel_confirmc_loc"), true)
                else
                    attitude_not_enough_cash = math.ceil(math.floor((freiya_trade_total_cost - cm:get_faction(freiya_selected_faction):treasury()) / (tonumber(freiya_region_level_gold[4])/tonumber(freiya_region_level_attitude[4])))/5)*5
                    freiya_trade_total_cost = cm:get_faction(freiya_selected_faction):treasury()
                    
                    if freiya_trade_total_cost ~= 0 then
                        FreiyaTMod.freiya_trade_deal_details_desc:SetStateText(common.get_localised_string("freiya_trade_deal_details_desca_loc") .. common.get_localised_string("regions_onscreen_" .. freiya_selected_our_deal[1]) .. common.get_localised_string("freiya_trade_deal_details_desce_loc") .. freiya_trade_total_cost .. " " .. common.get_localised_string("freiya_trade_desc_labeld_loc") .. "\n+" .. attitude_not_enough_cash .. " " .. common.get_localised_string("freiya_trade_deal_details_descg_loc"))
                    else
                        FreiyaTMod.freiya_trade_deal_details_desc:SetStateText(common.get_localised_string("freiya_trade_deal_details_desca_loc") .. common.get_localised_string("regions_onscreen_" .. freiya_selected_our_deal[1]) .. common.get_localised_string("freiya_trade_deal_details_descd_loc") ..  attitude_not_enough_cash .. " " .. common.get_localised_string("freiya_trade_deal_details_descg_loc"))
                    end
                            
                    FreiyaTMod.freiya_trade_panel_confirm:SetDisabled(false)
                    FreiyaTMod.freiya_trade_panel_confirm:SetImagePath("ui/campaign ui/message_icons/event_diplomacy_positive.png", 0, false)
                    FreiyaTMod.freiya_trade_panel_confirm:SetTooltipText(common.get_localised_string("freiya_trade_panel_confirmb_loc"), common.get_localised_string("freiya_trade_panel_confirmb_loc"), true)
                end
            end

        elseif freiya_player_benefit == "Gold Gains" and freiya_our_gold_value == freiya_their_gold_cost then
            freiya_trade_total_cost = 0
				
            FreiyaTMod.freiya_trade_deal_details_desc:SetStateText(common.get_localised_string("freiya_trade_deal_details_desca_loc") .. common.get_localised_string("regions_onscreen_" .. freiya_selected_our_deal[1]) .. common.get_localised_string("freiya_trade_deal_details_desce_loc") .. common.get_localised_string("regions_onscreen_" .. freiya_selected_their_deal[1]))
					
            FreiyaTMod.freiya_trade_panel_confirm:SetDisabled(false)
            FreiyaTMod.freiya_trade_panel_confirm:SetImagePath("ui/campaign ui/message_icons/event_diplomacy_positive.png", 0, false)
            FreiyaTMod.freiya_trade_panel_confirm:SetTooltipText(common.get_localised_string("freiya_trade_panel_confirmb_loc"), common.get_localised_string("freiya_trade_panel_confirmb_loc"), true)
					
        elseif freiya_player_benefit == "Diplomatic Gains" and freiya_our_attitude_value == freiya_their_attitude_value then
            freiya_trade_total_cost = 0

            FreiyaTMod.freiya_trade_deal_details_desc:SetStateText(common.get_localised_string("freiya_trade_deal_details_desca_loc") .. common.get_localised_string("regions_onscreen_" .. freiya_selected_our_deal[1]) .. common.get_localised_string("freiya_trade_deal_details_desce_loc") .. common.get_localised_string("regions_onscreen_" .. freiya_selected_their_deal[1]))
					
            FreiyaTMod.freiya_trade_panel_confirm:SetDisabled(false)
            FreiyaTMod.freiya_trade_panel_confirm:SetImagePath("ui/campaign ui/message_icons/event_diplomacy_positive.png", 0, false)
            FreiyaTMod.freiya_trade_panel_confirm:SetTooltipText(common.get_localised_string("freiya_trade_panel_confirmb_loc"), common.get_localised_string("freiya_trade_panel_confirmb_loc"), true)
        
        elseif freiya_player_benefit == "Gold Gains" and freiya_our_gold_value < freiya_their_gold_cost then
            freiya_trade_total_cost = freiya_their_gold_cost - freiya_our_gold_value
            if freiya_trade_current_player:treasury() >= freiya_trade_total_cost then
                FreiyaTMod.freiya_trade_deal_details_desc:SetStateText(common.get_localised_string("freiya_trade_deal_details_desca_loc") .. common.get_localised_string("regions_onscreen_" .. freiya_selected_our_deal[1]) .. "\n" .. freiya_trade_total_cost .. " " .. common.get_localised_string("freiya_trade_deal_details_descf_loc") .. common.get_localised_string("regions_onscreen_" .. freiya_selected_their_deal[1]))
						
                FreiyaTMod.freiya_trade_panel_confirm:SetDisabled(false)
                FreiyaTMod.freiya_trade_panel_confirm:SetImagePath("ui/campaign ui/message_icons/event_diplomacy_positive.png", 0, false)
                FreiyaTMod.freiya_trade_panel_confirm:SetTooltipText(common.get_localised_string("freiya_trade_panel_confirmb_loc"), common.get_localised_string("freiya_trade_panel_confirmb_loc"), true)
            else
                FreiyaTMod.freiya_trade_deal_details_desc:SetStateText(common.get_localised_string("freiya_trade_deal_details_desca_loc") .. common.get_localised_string("regions_onscreen_" .. freiya_selected_our_deal[1]) .. "\n" .. freiya_trade_total_cost .. " " .. common.get_localised_string("freiya_trade_deal_details_descc_loc") .. common.get_localised_string("regions_onscreen_" .. freiya_selected_their_deal[1]))
						
                FreiyaTMod.freiya_trade_panel_confirm:SetDisabled(true)
                FreiyaTMod.freiya_trade_panel_confirm:SetImagePath("ui/campaign ui/message_icons/event_diplomacy_negative.png", 0, false)
                FreiyaTMod.freiya_trade_panel_confirm:SetTooltipText(common.get_localised_string("freiya_trade_panel_confirmc_loc"), common.get_localised_string("freiya_trade_panel_confirmc_loc"), true)
            end
            
        elseif freiya_player_benefit == "Diplomatic Gains" and freiya_our_attitude_value < freiya_their_attitude_value then
            freiya_trade_total_cost = math.ceil((freiya_their_attitude_value - freiya_our_attitude_value) * (tonumber(freiya_region_level_gold[4])/tonumber(freiya_region_level_attitude[4])))
            if freiya_trade_current_player:treasury() >= freiya_trade_total_cost then
                FreiyaTMod.freiya_trade_deal_details_desc:SetStateText(common.get_localised_string("freiya_trade_deal_details_desca_loc") .. common.get_localised_string("regions_onscreen_" .. freiya_selected_our_deal[1]) .. "\n" .. freiya_trade_total_cost .. " " .. common.get_localised_string("freiya_trade_deal_details_descf_loc") .. common.get_localised_string("regions_onscreen_" .. freiya_selected_their_deal[1]))
						
                FreiyaTMod.freiya_trade_panel_confirm:SetDisabled(false)
                FreiyaTMod.freiya_trade_panel_confirm:SetImagePath("ui/campaign ui/message_icons/event_diplomacy_positive.png", 0, false)
                FreiyaTMod.freiya_trade_panel_confirm:SetTooltipText(common.get_localised_string("freiya_trade_panel_confirmb_loc"), common.get_localised_string("freiya_trade_panel_confirmb_loc"), true)
            else
                FreiyaTMod.freiya_trade_deal_details_desc:SetStateText(common.get_localised_string("freiya_trade_deal_details_desca_loc") .. common.get_localised_string("regions_onscreen_" .. freiya_selected_our_deal[1]) .. "\n" .. freiya_trade_total_cost .. " " .. common.get_localised_string("freiya_trade_deal_details_descc_loc") .. common.get_localised_string("regions_onscreen_" .. freiya_selected_their_deal[1]))
						
                FreiyaTMod.freiya_trade_panel_confirm:SetDisabled(true)
                FreiyaTMod.freiya_trade_panel_confirm:SetImagePath("ui/campaign ui/message_icons/event_diplomacy_negative.png", 0, false)
                FreiyaTMod.freiya_trade_panel_confirm:SetTooltipText(common.get_localised_string("freiya_trade_panel_confirmc_loc"), common.get_localised_string("freiya_trade_panel_confirmc_loc"), true)
            end
                                                
        elseif freiya_player_benefit == "Gold Gains" and freiya_our_gold_value > freiya_their_gold_cost  then
            freiya_trade_total_cost = freiya_our_gold_value - freiya_their_gold_cost
                    
            if cm:get_faction(freiya_selected_faction):treasury() >= freiya_trade_total_cost then
                FreiyaTMod.freiya_trade_deal_details_desc:SetStateText(common.get_localised_string("freiya_trade_deal_details_desca_loc") .. common.get_localised_string("regions_onscreen_" .. freiya_selected_our_deal[1]) .. common.get_localised_string("freiya_trade_deal_details_desce_loc") .. common.get_localised_string("regions_onscreen_" .. freiya_selected_their_deal[1]) .. "\n" .. freiya_trade_total_cost .. " " .. common.get_localised_string("freiya_trade_desc_labeld_loc"))
                                      
                FreiyaTMod.freiya_trade_panel_confirm:SetDisabled(false)
                FreiyaTMod.freiya_trade_panel_confirm:SetImagePath("ui/campaign ui/message_icons/event_diplomacy_positive.png", 0, false)
                FreiyaTMod.freiya_trade_panel_confirm:SetTooltipText(common.get_localised_string("freiya_trade_panel_confirmb_loc"), common.get_localised_string("freiya_trade_panel_confirmb_loc"), true)
            elseif cm:get_faction(freiya_selected_faction):treasury() < freiya_trade_total_cost then
                if cm:is_multiplayer() and cm:get_faction(freiya_selected_faction):is_human() then
                    FreiyaTMod.freiya_trade_deal_details_desc:SetStateText(common.get_localised_string("freiya_trade_deal_details_desca_loc") .. common.get_localised_string("regions_onscreen_" .. freiya_selected_our_deal[1]) .. common.get_localised_string("freiya_trade_deal_details_desce_loc") .. freiya_trade_total_cost .. " " .. common.get_localised_string("freiya_trade_deal_details_descmp_loc"))
						
                    FreiyaTMod.freiya_trade_panel_confirm:SetDisabled(true)
                    FreiyaTMod.freiya_trade_panel_confirm:SetImagePath("ui/campaign ui/message_icons/event_diplomacy_negative.png", 0, false)
                    FreiyaTMod.freiya_trade_panel_confirm:SetTooltipText(common.get_localised_string("freiya_trade_panel_confirmc_loc"), common.get_localised_string("freiya_trade_panel_confirmc_loc"), true)
                else
                    attitude_not_enough_cash = math.ceil(math.floor((freiya_trade_total_cost - cm:get_faction(freiya_selected_faction):treasury()) / (tonumber(freiya_region_level_gold[4])/tonumber(freiya_region_level_attitude[4])))/5)*5
                    freiya_trade_total_cost = cm:get_faction(freiya_selected_faction):treasury()
                    
                    if freiya_trade_total_cost ~= 0 then
                        FreiyaTMod.freiya_trade_deal_details_desc:SetStateText(common.get_localised_string("freiya_trade_deal_details_desca_loc") .. common.get_localised_string("regions_onscreen_" .. freiya_selected_our_deal[1]) .. common.get_localised_string("freiya_trade_deal_details_desce_loc") .. freiya_trade_total_cost .. " " .. common.get_localised_string("freiya_trade_desc_labeld_loc") .. "\n+" .. attitude_not_enough_cash .. " " .. common.get_localised_string("freiya_trade_deal_details_descg_loc"))
                    else
                        FreiyaTMod.freiya_trade_deal_details_desc:SetStateText(common.get_localised_string("freiya_trade_deal_details_desca_loc") .. common.get_localised_string("regions_onscreen_" .. freiya_selected_our_deal[1]) .. common.get_localised_string("freiya_trade_deal_details_descd_loc") .. attitude_not_enough_cash .. " " .. common.get_localised_string("freiya_trade_deal_details_descg_loc"))
                    end
                    
                    FreiyaTMod.freiya_trade_panel_confirm:SetDisabled(false)
                    FreiyaTMod.freiya_trade_panel_confirm:SetImagePath("ui/campaign ui/message_icons/event_diplomacy_positive.png", 0, false)
                    FreiyaTMod.freiya_trade_panel_confirm:SetTooltipText(common.get_localised_string("freiya_trade_panel_confirmb_loc"), common.get_localised_string("freiya_trade_panel_confirmb_loc"), true)
                end
            end
           
        elseif freiya_player_benefit == "Diplomatic Gains" and freiya_our_attitude_value > freiya_their_attitude_value then
            freiya_trade_total_cost = freiya_our_attitude_value - freiya_their_attitude_value  
                                                
            if freiya_trade_total_cost == 0 then
                freiya_trade_total_cost = 5
            end
            FreiyaTMod.freiya_trade_deal_details_desc:SetStateText(common.get_localised_string("freiya_trade_deal_details_desca_loc") .. common.get_localised_string("regions_onscreen_" .. freiya_selected_our_deal[1]) .. common.get_localised_string("freiya_trade_deal_details_desce_loc") .. common.get_localised_string("regions_onscreen_" .. freiya_selected_their_deal[1]) .. "\n+" .. freiya_trade_total_cost .. " " .. common.get_localised_string("freiya_trade_desc_labele_loc"))
					
            FreiyaTMod.freiya_trade_panel_confirm:SetDisabled(false)
            FreiyaTMod.freiya_trade_panel_confirm:SetImagePath("ui/campaign ui/message_icons/event_diplomacy_positive.png", 0, false)
            FreiyaTMod.freiya_trade_panel_confirm:SetTooltipText(common.get_localised_string("freiya_trade_panel_confirmb_loc"), common.get_localised_string("freiya_trade_panel_confirmb_loc"), true)
        end                                       

        FreiyaTMod.freiya_trade_deal:SetVisible(true)
        FreiyaTMod.freiya_trade_deal_details_desc:SetVisible(true)
    
    end
    
    -- Create the confirm button
	FreiyaTMod.freiya_trade_panel_confirm = core:get_or_create_component("freiya_trade_panel_confirm","UI/templates/round_medium_button.twui.xml", FreiyaTMod.freiya_trade_panel_frame)
	FreiyaTMod.freiya_trade_panel_confirm:SetImagePath("ui/campaign ui/message_icons/event_mission_negative.png", 0,false)
	FreiyaTMod.freiya_trade_panel_confirm:SetDockingPoint(8)
	FreiyaTMod.freiya_trade_panel_confirm:SetDockOffset(-150,-10)
	FreiyaTMod.freiya_trade_panel_confirm:SetTooltipText(common.get_localised_string("freiya_trade_panel_confirma_loc"), common.get_localised_string("freiya_trade_panel_confirma_loc"), true)
	FreiyaTMod.freiya_trade_panel_confirm:SetDisabled(true)

    -- Create the cancel button
	FreiyaTMod.freiya_trade_panel_cancel = core:get_or_create_component("freiya_trade_panel_cancel","UI/templates/round_medium_button.twui.xml", FreiyaTMod.freiya_trade_panel_frame)
	FreiyaTMod.freiya_trade_panel_cancel:SetImagePath("ui/skins/default/icon_cross.png", 0,false)
	FreiyaTMod.freiya_trade_panel_cancel:SetDockingPoint(8)
	FreiyaTMod.freiya_trade_panel_cancel:SetDockOffset(150,-10)
	FreiyaTMod.freiya_trade_panel_cancel:SetTooltipText(common.get_localised_string("freiya_trade_panel_cancel_loc"), common.get_localised_string("freiya_trade_panel_cancel_loc"), true)
    -- End of freiya_trade_menu_creation_initiate
end
local function freiya_trade_panel_button_creation()
	--cm:callback(function()
    local ui_root = core:get_ui_root()
    local menu_bar = find_child_uicomponent(ui_root,"menu_bar")
    local buttongroup = find_child_uicomponent(menu_bar,"buttongroup")
    local freiya_trade_panel_button = find_uicomponent(buttongroup,"freiya_trade_panel_button")
        
    if not freiya_trade_panel_button then
        FreiyaTMod.freiya_trade_panel_button = core:get_or_create_component("freiya_trade_panel_button","UI/templates/round_small_button.twui.xml", buttongroup)
        FreiyaTMod.freiya_trade_panel_button:SetImagePath("ui/campaign ui/diplomacy_icons/diplomatic_option_trade_regions.png", 0,false)
        FreiyaTMod.freiya_trade_panel_button:SetVisible(true)
        FreiyaTMod.freiya_trade_panel_button:Resize(38, 38)
        FreiyaTMod.freiya_trade_panel_button:SetTooltipText(common.get_localised_string("freiya_trade_panel_button_loc"), common.get_localised_string("freiya_trade_panel_button_loc"), true)
    end
	--end, 0.1)

    
    -- Create the listeners that open the trade menu when clicking on the small button on the top-left corner of the screen
    core:add_listener(
    "freiya_trade_button_pressed_listener",
    "ComponentLClickUp",
        function(context)
            return context.string == FreiyaTMod.freiya_trade_panel_button:Id()
        end,
        function(context)
            CampaignUI.TriggerCampaignScriptEvent(0, context.string)
        end,
        true
    )
    
    core:add_listener(
    "freiya_trade_button_pressed_listener",
    "UITrigger",
        function(context)
            return context:trigger() == FreiyaTMod.freiya_trade_panel_button:Id()
        end,
        function(context)
            if FreiyaTMod.freiya_trade_panel == nil or FreiyaTMod.freiya_trade_panel:IsValid() == false then
                freiya_trade_menu_creation_initiate()
                FreiyaTMod.freiya_trade_panel:SetVisible(true)
                freiya_trade_create_listeners()
            end
        end,
        true
    )
end


-- Create the listeners that cancels and confirms the trade and switches settlements, give gold or reputation
function freiya_trade_create_listeners()
    core:add_listener(
        "freiya_trade_buttons_pressed_listener",
        "ComponentLClickUp",
        function(context)
			return context.string == FreiyaTMod.freiya_trade_panel_confirm:Id() or
            context.string == FreiyaTMod.freiya_trade_panel_cancel:Id()
		end,
		function(context)
            CampaignUI.TriggerCampaignScriptEvent(0, context.string)     
        end,
        true
	)
    
	core:add_listener(
        "freiya_trade_buttons_pressed_listener",
        "UITrigger",
		function(context)
            return context:trigger() == FreiyaTMod.freiya_trade_panel_confirm:Id() or
            context:trigger() == FreiyaTMod.freiya_trade_panel_cancel:Id()
		end,
		function(context)
            if context:trigger() == FreiyaTMod.freiya_trade_panel_confirm:Id() then
                local target_region = freiya_selected_their_deal[1]
                if target_region and target_region ~= "Relations" then
                    cm:transfer_region_to_faction(target_region, freiya_trade_current_player_name)
                end
        
                -- Destroy the trade menu
                freiya_trade_total_cost = 0
                attitude_not_enough_cash = 0
                freiya_our_gold_value = 0
                freiya_our_attitude_value = 0
                freiya_their_gold_cost = 0
                freiya_their_attitude_value = 0
        
                FreiyaTMod.freiya_trade_panel:SetVisible(false)
                FreiyaTMod.freiya_trade_panel:Destroy()
                core:remove_listener("freiya_trade_mpfaction_pressed_listener")
                core:remove_listener("freiya_trade_faction_pressed_listener")
                core:remove_listener("freiya_trade_our_regions_pressed_listener")
                core:remove_listener("freiya_trade_their_regions_pressed_listener")
                core:remove_listener("freiya_trade_buttons_pressed_listener")
    
            elseif context:trigger() == FreiyaTMod.freiya_trade_panel_cancel:Id() then
                FreiyaTMod.freiya_trade_panel:SetVisible(false)
                FreiyaTMod.freiya_trade_panel:Destroy()
                core:remove_listener("freiya_trade_mpfaction_pressed_listener")
                core:remove_listener("freiya_trade_faction_pressed_listener")
                core:remove_listener("freiya_trade_our_regions_pressed_listener")
                core:remove_listener("freiya_trade_their_regions_pressed_listener")
                core:remove_listener("freiya_trade_buttons_pressed_listener")
            end
                
		end,
		true
	)
	
end


cm:add_first_tick_callback(function() freiya_trade_panel_button_creation() end);

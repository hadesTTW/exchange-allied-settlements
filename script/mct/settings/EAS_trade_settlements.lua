if not get_mct then return end
local mct = get_mct()

local mct_mod = mct:register_mod("exchange_allied_settlements")
if is_function(mct_mod.set_main_image) then
    mct_mod:set_main_image("ui/exchange-allied-settlements.png", 300, 300);
end;
if is_function(mct_mod.set_workshop_id) then
    mct_mod:set_workshop_id("3651393085");
end;

mct_mod:set_title("mct_EAS_title")
mct_mod:set_author("HadesTTW")
mct_mod:set_description("mct_EAS_description")

local allow_player_cities = mct_mod:add_new_option("allow_player_cities", "checkbox")
allow_player_cities:set_text("mct_EAS_allow_player_cities_text")

allow_player_cities:set_tooltip_text("mct_EAS_allow_player_cities_tooltip")
allow_player_cities:set_is_global(true)
allow_player_cities:set_default_value(false)

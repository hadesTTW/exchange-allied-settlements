if not get_mct then return end
local mct = get_mct()

local mct_mod = mct:register_mod("exchange_allied_settlements")
if is_function(mct_mod.set_main_image) then
    mct_mod:set_main_image("ui/exchange-allied-settlements.png", 300, 300);
end;

mct_mod:set_title("Exchange Allied Settlements")
mct_mod:set_author("HadesTTW")
mct_mod:set_description(
    "A mod that adds in a user interface that allows the user to transfer settlements from one ally to another."
)

local allow_player_cities = mct_mod:add_new_option("allow_player_cities", "checkbox")
allow_player_cities:set_default_value(false)
allow_player_cities:set_text(
    "Allow trading to and from the player",
    "If enabled, you and your allies can send cities to and from your faction. If disabled, cities can only be traded between your allied factions, not involving your own."
)

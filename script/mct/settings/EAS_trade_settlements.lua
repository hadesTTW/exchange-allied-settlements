if not get_mct then return end
local mct = get_mct()

local mct_mod = mct:register_mod("exchange_allied_settlements")

mct_mod:set_title("Exchange Allied Settlements")
mct_mod:set_author("EAS")
mct_mod:set_description(
    "Configure whether you can give and receive your own cities, or only allow transfers between your allied factions."
)

local allow_player_cities = mct_mod:add_new_option("allow_player_cities", "checkbox")
allow_player_cities:set_default_value(false)
allow_player_cities:set_text(
    "Allow trading your own cities",
    "If enabled, you and your allies can send cities to and from your faction. If disabled, cities can only be traded between your allied factions, not involving your own."
)

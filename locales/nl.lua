local Translations ={
    ["not_on_radio"] = "Je bent niet verbonden met een kanaal",
    ["joined_to_radio"] = "Je bent verbonden met: %{channel}",
    ["restricted_channel_error"] = "Je kunt niet verbinden met dit signaal!",
    ["invalid_radio"] = "Deze frequentie is niet beschikbaar.",
    ["you_on_radio"] = "Je bent al verbonden met dit kanaal",
    ["you_leave"] = "Je hebt het kanaal verlaten.",
    ['volume_radio'] = 'Nieuw volume %{value}',
    ['decrease_radio_volume'] = 'De radio staat al op het maximale volume!',
    ['increase_radio_volume'] = 'De radio staat al op het minimale volume!',
}

if GetConvar('qb_locale', 'en') == 'nl' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end

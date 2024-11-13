local Translations = {
    ["not_on_radio"] = "No estás conectado a ninguna frecuencia",
    ["joined_to_radio"] = "Te has conectado a: %{channel}",
    ["restricted_channel_error"] = "¡No te puedes conectar a esta frecuencia!",
    ["invalid_radio"] = "Esta frecuencia no está disponible.",
    ["you_on_radio"] = "Ya estás conectado a esta frecuencia",
    ["you_leave"] = "Has abandonado la frecuencia.",
    ['volume_radio'] = 'Nuevo volumen %{value}',
    ['decrease_radio_volume'] = 'La radio ya está al máximo volumen',
    ['increase_radio_volume'] = 'La radio ya está al mínimo volumen',
}

if GetConvar('qb_locale', 'en') == 'es' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end

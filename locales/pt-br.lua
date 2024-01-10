local Translations = {
    ["not_on_radio"] = "Você não está conectado a um sinal",
    ["on_radio"] = "Você já está conectado a este sinal",
    ["joined_to_radio"] = "Você está conectado a: %{channel}",
    ["restricted_channel_error"] = "Você não pode se conectar a este sinal!",
    ["invalid_radio"] = "Esta frequência não está disponível.",
    ["you_on_radio"] = "Você já está conectado a este canal",
    ["you_leave"] = "Você saiu do canal.",
    ['volume_radio'] = 'Novo volume %{value}',
    ['decrease_radio_volume'] = 'O rádio já está ajustado para o volume máximo',
    ['increase_radio_volume'] = 'O rádio já está ajustado para o volume mais baixo',
    ['increase_decrease_radio_channel'] = 'Novo canal %{value}',
}

if GetConvar('qb_locale', 'en') == 'pt-br' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end

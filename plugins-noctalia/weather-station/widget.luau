barWidget.setGlyph("temperature")

-- Couleur en fonction de la température (seuils ajustables)
local function colorForTemp(temp)
    if temp <= 0 then
        return "#4FC3F7"   -- bleu clair : gel
    elseif temp <= 10 then
        return "#81D4FA"   -- bleu : froid
    elseif temp <= 18 then
        return "#A5D6A7"   -- vert : frais
    elseif temp <= 25 then
        return "#FFD54F"   -- jaune : agréable
    elseif temp <= 32 then
        return "#FFA726"   -- orange : chaud
    else
        return "#EF5350"   -- rouge : très chaud
    end
end

local function render()
    local err = noctalia.state.get("weather_error")
    local data = noctalia.state.get("weather_data")

    if err or data == nil or data.temp == nil then
        barWidget.setText("--°C")
        barWidget.setTooltip("Station météo injoignable")
        barWidget.setColor(nil)  -- retour à la couleur par défaut du thème
        return
    end

    barWidget.setText(string.format("%.1f°C", data.temp))
    barWidget.setColor(colorForTemp(data.temp))

    local tooltip = string.format(
        "Extérieur : %.1f°C · %.0f%% hum.\nRafale : %.1f km/h · Pluie : %.2f mm\nIntérieur : %.1f°C · %.0f%% hum.\nUV : %.1f",
        data.temp, data.hum or 0,
        data.gust or 0, data.rain or 0,
        data.tempIndoor or 0, data.humIndoor or 0,
        data.uv or 0
    )
    if data.date then
        tooltip = tooltip .. "\nRelevé : " .. data.date
    end
    barWidget.setTooltip(tooltip)
end

noctalia.state.watch("weather_data", render)
noctalia.state.watch("weather_error", render)

render()

local url = noctalia.getConfig("url")
local intervalSec = noctalia.getConfig("interval")

noctalia.setUpdateInterval(intervalSec * 1000)

local function parseWeather(text)
    local data = {}

    data.date = text:match("Rel%wv%w le ([%d%-]+ [%d:]+)")
    data.temp = tonumber(text:match("Temp:%s*(-?%d+%.?%d*)"))
    data.rain = tonumber(text:match("Cumul:%s*(-?%d+%.?%d*)"))
    data.hum = tonumber(text:match("Hum:%s*(-?%d+%.?%d*)"))
    data.gust = tonumber(text:match("Rafale:%s*(-?%d+%.?%d*)"))
    data.tempIndoor = tonumber(text:match("TempIndoor:%s*(-?%d+%.?%d*)"))
    data.humIndoor = tonumber(text:match("HumIndoor:%s*(-?%d+%.?%d*)"))
    data.uv = tonumber(text:match("UV:%s*(-?%d+%.?%d*)"))

    return data
end

local function fetchWeather()
    noctalia.http({ url = url }, function(res)
        if not res or not res.body then
            noctalia.state.set("weather_error", true)
            return
        end

        local data = parseWeather(res.body)
        if data.temp then
            noctalia.state.set("weather_data", data)
            noctalia.state.set("weather_error", false)
        else
            noctalia.state.set("weather_error", true)
        end
    end)
end

-- Premier fetch au chargement, puis à chaque tick
fetchWeather()

function update()
    fetchWeather()
end

-- Refresh manuel : noctalia msg plugin moi/weather-station:fetcher all refresh
function onIpc(event, payload)
    if event == "refresh" then
        fetchWeather()
    end
end

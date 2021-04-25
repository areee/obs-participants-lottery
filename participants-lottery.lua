obs                 = obslua
source_name         = ""
last_text           = ""
participants_text   = ""
activated           = false

hotkey_id           = obs.OBS_INVALID_HOTKEY_ID

function run_lottery()
    string.split =
        function(str, pattern) -- Source for this string splitting method: http://lua-users.org/wiki/SplitJoin
            pattern = pattern or "[^%s]+"
            if pattern:len() == 0 then pattern = "[^%s]+" end
            local parts = {__index = table.insert}
            setmetatable(parts, parts)
            str:gsub(pattern, parts)
            setmetatable(parts, nil)
            parts.__index = nil
            return parts
        end

    NameList = participants_text:split("[^,%s]+")
    OrderList = {}

    function Contains(Array, Object)
        for i = 1, #Array do
            Val = Array[i]
            if (Val == Object) then return true end
        end
        return false
    end

    repeat
        RandomNumber = math.random(1, #NameList)
        if not Contains(OrderList, RandomNumber) then
            table.insert(OrderList, RandomNumber)
        end
    until #OrderList == #NameList

    local text = ""

    for i = 1, #OrderList do text = text .. NameList[OrderList[i]] .. "\n" end

    if text ~= last_text then
        local source = obs.obs_get_source_by_name(source_name)
        if source ~= nil then
            local settings = obs.obs_data_create()
            obs.obs_data_set_string(settings, "text", text)
            obs.obs_source_update(source, settings)
            obs.obs_data_release(settings)
            obs.obs_source_release(source)
        end
    end
    last_text = text
end

function activate(activating)
    if activated == activating then return end

    activated = activating

    if activating then run_lottery() end
end

function activate_signal(cd, activating)
    local source = obs.calldata_source(cd, "source")
    if source ~= nil then
        local name = obs.obs_source_get_name(source)
        if (name == source_name) then activate(activating) end
    end
end

function source_activated(cd) activate_signal(cd, true) end

function source_deactivated(cd) activate_signal(cd, false) end

function start_again(pressed)
    if not pressed then return end

    activate(false)
    local source = obs.obs_get_source_by_name(source_name)
    if source ~= nil then
        local active = obs.obs_source_active(source)
        obs.obs_source_release(source)
        activate(active)
    end
end

function start_again_button_clicked(props, p)
    start_again(true)
    return false
end

-- =========================================================================

function script_description()
    return
        "Lottery of meeting participants in random order.\n\nMade 2021 by Arttu Ylhävuori.\nBased on OBS countdown script made by Jim."
end

function script_properties()
    local props = obs.obs_properties_create()

    local p = obs.obs_properties_add_list(props, "source", "Text Source",
                                          obs.OBS_COMBO_TYPE_EDITABLE,
                                          obs.OBS_COMBO_FORMAT_STRING)
    local sources = obs.obs_enum_sources()
    if sources ~= nil then
        for _, source in ipairs(sources) do
            source_id = obs.obs_source_get_unversioned_id(source)
            if source_id == "text_gdiplus" or source_id == "text_ft2_source" then
                local name = obs.obs_source_get_name(source)
                obs.obs_property_list_add_string(p, name, name)
            end
        end
    end
    obs.source_list_release(sources)

    obs.obs_properties_add_text(props, "participants_text", "Participants",
                                obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_button(props, "start_again_button", "Start again",
                                  start_again_button_clicked)

    return props
end

function script_update(settings)
    activate(false)

    source_name = obs.obs_data_get_string(settings, "source")
    participants_text = obs.obs_data_get_string(settings, "participants_text")

    start_again(true)
end

function script_defaults(settings)
    obs.obs_data_set_default_string(settings, "participants_text",
                                    "Mike, Catherine, Tim, Julia")
end

function script_save(settings)
    local hotkey_save_array = obs.obs_hotkey_save(hotkey_id)
    obs.obs_data_set_array(settings, "start_again_hotkey", hotkey_save_array)
    obs.obs_data_array_release(hotkey_save_array)
end

function script_load(settings)
    local sh = obs.obs_get_signal_handler()
    obs.signal_handler_connect(sh, "source_activate", source_activated)
    obs.signal_handler_connect(sh, "source_deactivate", source_deactivated)

    hotkey_id = obs.obs_hotkey_register_frontend("start_again_timer_thingy",
                                                 "Start again", start_again)
    local hotkey_save_array = obs.obs_data_get_array(settings,
                                                     "start_again_hotkey")
    obs.obs_hotkey_load(hotkey_id, hotkey_save_array)
    obs.obs_data_array_release(hotkey_save_array)
end

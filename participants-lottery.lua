Obs                 = obslua
Source_name         = ""
Last_text           = ""
Participants_text   = ""
Activated           = false
Items_per_row       = 0
Hotkey_id           = Obs.OBS_INVALID_HOTKEY_ID

function Run_lottery()
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

    NameList = Participants_text:split("[^,%s]+")
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

    for i = 1, #OrderList do
        text = text .. NameList[OrderList[i]]

        if i % Items_per_row == 0 then
            text = text .. "\n"
        elseif i ~= #OrderList then
            text = text .. ","
        end
    end

    if text ~= Last_text then
        local source = Obs.obs_get_source_by_name(Source_name)
        if source ~= nil then
            local settings = Obs.obs_data_create()
            Obs.obs_data_set_string(settings, "text", text)
            Obs.obs_source_update(source, settings)
            Obs.obs_data_release(settings)
            Obs.obs_source_release(source)
        end
    end
    Last_text = text
end

function Activate(activating)
    if Activated == activating then return end

    Activated = activating

    if activating then Run_lottery() end
end

function Activate_signal(cd, activating)
    local source = Obs.calldata_source(cd, "source")
    if source ~= nil then
        local name = Obs.obs_source_get_name(source)
        if (name == Source_name) then Activate(activating) end
    end
end

function Source_activated(cd) Activate_signal(cd, true) end

function Source_deactivated(cd) Activate_signal(cd, false) end

function Start_again(pressed)
    if not pressed then return end

    Activate(false)
    local source = Obs.obs_get_source_by_name(Source_name)
    if source ~= nil then
        local active = Obs.obs_source_active(source)
        Obs.obs_source_release(source)
        Activate(active)
    end
end

function Start_again_button_clicked(props, p)
    Start_again(true)
    return false
end

-- =========================================================================

function script_description()
    return
        "Lottery of meeting participants in random order.\n\nMade 2021 by Arttu Ylhävuori.\nBased on OBS countdown script made by Jim."
end

function script_properties()
    local props = Obs.obs_properties_create()

    local p = Obs.obs_properties_add_list(props, "source", "Text Source",
                                          Obs.OBS_COMBO_TYPE_EDITABLE,
                                          Obs.OBS_COMBO_FORMAT_STRING)
    local sources = Obs.obs_enum_sources()
    if sources ~= nil then
        for _, source in ipairs(sources) do
            Source_id = Obs.obs_source_get_unversioned_id(source)
            if Source_id == "text_gdiplus" or Source_id == "text_ft2_source" then
                local name = Obs.obs_source_get_name(source)
                Obs.obs_property_list_add_string(p, name, name)
            end
        end
    end
    Obs.source_list_release(sources)

    Obs.obs_properties_add_text(props, "participants_text", "Participants",
                                Obs.OBS_TEXT_DEFAULT)
    Obs.obs_properties_add_button(props, "start_again_button", "Start again",
                                  Start_again_button_clicked)
    Obs.obs_properties_add_int(props, "items", "Items per row", 1, 100000, 1)

    return props
end

function script_update(settings)
    Activate(false)

    Source_name = Obs.obs_data_get_string(settings, "source")
    Participants_text = Obs.obs_data_get_string(settings, "participants_text")
    Items_per_row = Obs.obs_data_get_int(settings, "items")

    Start_again(true)
end

function script_defaults(settings)
    Obs.obs_data_set_default_string(settings, "participants_text",
                                    "Mike, Catherine, Tim, Julia")
    Obs.obs_data_set_default_int(settings, "items", 10)
end

function script_save(settings)
    local hotkey_save_array = Obs.obs_hotkey_save(Hotkey_id)
    Obs.obs_data_set_array(settings, "start_again_hotkey", hotkey_save_array)
    Obs.obs_data_array_release(hotkey_save_array)
end

function script_load(settings)
    local sh = Obs.obs_get_signal_handler()
    Obs.signal_handler_connect(sh, "source_activate", Source_activated)
    Obs.signal_handler_connect(sh, "source_deactivate", Source_deactivated)

    Hotkey_id = Obs.obs_hotkey_register_frontend("start_again_timer_thingy",
                                                 "Start again", Start_again)
    local hotkey_save_array = Obs.obs_data_get_array(settings,
                                                     "start_again_hotkey")
    Obs.obs_hotkey_load(Hotkey_id, hotkey_save_array)
    Obs.obs_data_array_release(hotkey_save_array)
end

----------------------------------------------------------------------------------------------------
-- TIRE PRESSURE SPECIALIZATION
----------------------------------------------------------------------------------------------------
-- Authors:  Rahkiin, reallogger
--
-- Copyright (c) Realismus Modding, 2017
----------------------------------------------------------------------------------------------------

ssTirePressure = {}

ssTirePressure.MAX_CHARS_TO_DISPLAY = 20

ssTirePressure.PRESSURE_LOW = 1
ssTirePressure.PRESSURE_NORMAL = 2
ssTirePressure.PRESSURE_MAX = ssTirePressure.PRESSURE_NORMAL

ssTirePressure.PRESSURES = { 80, 180 }
ssTirePressure.NORMAL_PRESURE = 180 -- vanilla

function ssTirePressure:prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(Motorized, specializations) and
           SpecializationUtil.hasSpecialization(ssAtWorkshop, specializations)
end

function ssTirePressure:preLoad()
    self.updateInflationPressure = ssTirePressure.updateInflationPressure
end

function ssTirePressure:load(savegame)
    if savegame ~= nil then
        self.ssInflationPressure = ssXMLUtil.getInt(savegame.xmlFile, savegame.key .. "#ssInflationPressure", ssTirePressure.PRESSURE_NORMAL)
    end
end

function ssTirePressure:delete()
end

function ssTirePressure:mouseEvent(posX, posY, isDown, isUp, button)
end

function ssTirePressure:keyEvent(unicode, sym, modifier, isDown)
end

function ssTirePressure:loadFromAttributesAndNodes(xmlFile, key)
    return true
end

function ssTirePressure:getSaveAttributesAndNodes(nodeIdent)
    local attributes = ""

    attributes = attributes .. "ssInflationPressure=\"" .. self.ssInflationPressure ..  "\" "

    return attributes, ""
end

function ssAtWorkshop:readStream(streamId, connection)
end

function ssAtWorkshop:writeStream(streamId, connection)
end

function ssTirePressure:updateInflationPressure()
    self.ssInflationPressure = self.ssInflationPressure + 1
    if self.ssInflationPressure > ssTirePressure.PRESSURE_MAX then
        self.ssInflationPressure = ssTirePressure.PRESSURE_LOW
    end

    local pressure = ssTirePressure.PRESSURES[self.ssInflationPressure]

    for _, wheel in pairs(self.wheels) do
        wheel.ssMaxLoad = self:getTireMaxLoad(wheel, pressure)
        wheel.maxDeformation = wheel.ssMaxDeformation * ssTirePressure.NORMAL_PRESURE / pressure
    end

    -- TODO(Jos) send event with new pressure for vehicle
end

function ssTirePressure:update(dt)
    if self.isClient and self:canPlayerInteractInWorkshop() then
        local storeItem = StoreItemsUtil.storeItemsByXMLFilename[self.configFileName:lower()]
        local vehicleName = storeItem.brand .. " " .. storeItem.name

        -- Show text for changing inflation pressure
        local storeItemName = storeItem.name
        if string.len(storeItemName) > ssTirePressure.MAX_CHARS_TO_DISPLAY then
            storeItemName = ssUtil.trim(string.sub(storeItemName, 1, ssTirePressure.MAX_CHARS_TO_DISPLAY - 3)) .. "..."
        end

        g_currentMission:addHelpButtonText(string.format(g_i18n:getText("input_SEASONS_TIRE_PRESSURE"), self.ssInflationPressure), InputBinding.IMPLEMENT_EXTRA2, nil, GS_PRIO_HIGH)

        if InputBinding.hasEvent(InputBinding.IMPLEMENT_EXTRA2) then
            self:updateInflationPressure()
        end
    end
end
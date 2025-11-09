-- autoAttach.lua
-- Auto attach logic for medium rusty tow chain (PC)

local TowChain = {}
TowChain.ATTACH_DISTANCE = 1.0

function TowChain.prerequisitesPresent(specializations)
    return true
end

function TowChain.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onLoad", TowChain)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdate", TowChain)
end

function TowChain:onLoad(savegame)
    self.towChain = { attachedFront = false, attachedBack = false }
    self.jointFrontNode = getChild(self.i3dMappings.rootNode, "jointFront")
    self.jointBackNode = getChild(self.i3dMappings.rootNode, "jointBack")
end

function TowChain:onUpdate(dt)
    if not self.isClient then return end
    if self.towChain.attachedFront and self.towChain.attachedBack then return end

    for _, veh in pairs(g_currentMission.vehicles) do
        if veh ~= self and veh:getIsEnterable() then
            local joints = veh.attacherJoints
            if joints ~= nil then
                for jIndex, jInfo in ipairs(joints) do
                    local wx, wy, wz = getWorldTranslation(jInfo.node)

                    if not self.towChain.attachedFront then
                        local cx, cy, cz = getWorldTranslation(self.jointFrontNode)
                        local dist = MathUtil.vector3Length(cx - wx, cy - wy, cz - wz)
                        if dist <= TowChain.ATTACH_DISTANCE then
                            if veh:attachImplement(self, jIndex) then
                                self.towChain.attachedFront = true
                                break
                            end
                        end
                    end

                    if not self.towChain.attachedBack then
                        local cx2, cy2, cz2 = getWorldTranslation(self.jointBackNode)
                        local dist2 = MathUtil.vector3Length(cx2 - wx, cy2 - wy, cz2 - wz)
                        if dist2 <= TowChain.ATTACH_DISTANCE then
                            if veh:attachImplement(self, jIndex) then
                                self.towChain.attachedBack = true
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end

addModEventListener(TowChain)

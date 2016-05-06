//
//	ns2siege+ Custom Game Mode
//	ZycaR (c) 2016
//
Script.Load("lua/ScriptActor.lua")
Script.Load("lua/Mixins/SignalListenerMixin.lua")

class 'FuncMaid' (Trigger)

FuncMaid.kMapName = "ns2siege_funcmaid"
FuncMaid.kUpdateTime = 0.5
local networkVars = { }

// copied from death_trigger, which should do it right
local function KillEntity(self, entity)
    if Server and HasMixin(entity, "Live") and entity:GetIsAlive() and entity:GetCanDie(true) then
        local direction = GetNormalizedVector(entity:GetModelOrigin() - self:GetOrigin())
        entity:Kill(self, self, self:GetOrigin(), direction)
    end
end

local function FuncMaidTriggered(self)
    local front, siege, suddendeath = GetGameInfoEntity():GetSiegeTimes()
    local active = (self.type == 0 and front > 0) or (self.type == 1 and siege > 0)
    if GetGamerules():GetGameStarted() and active then
        for _, entity in ientitylist(Shared.GetEntitiesWithClassname("Cyst")) do
            if self:GetIsPointInside(entity:GetOrigin()) then
                Shared.Message('Maid\'s cleaning duty for cyst .. ' .. entity:GetId())
                KillEntity(self, entity) // do cleanup
            end
        end
    end
end

function FuncMaid:OnCreate()
    Trigger.OnCreate(self)

    InitMixin(self, SignalListenerMixin)
    self:RegisterSignalListener(function()
        FuncMaidTriggered(self) 
    end, "func_maid_signal")
    
    self:SetPropagate(Entity.Propagate_Never)
end

function FuncMaid:OnInitialized()
    Trigger.OnInitialized(self)
    self:SetTriggerCollisionEnabled(true)
    self:SetUpdates(false)
end

if Server then
    function FuncMaid:OnTriggerEntered(entity, triggerEnt) end
    function FuncMaid:OnTriggerExited(entity, triggerEnt) end
end


Shared.LinkClassToMap("FuncMaid", FuncMaid.kMapName, networkVars)
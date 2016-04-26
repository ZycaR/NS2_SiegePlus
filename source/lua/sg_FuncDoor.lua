//
//	ns2siege+ Custom Game Mode
//	ZycaR (c) 2016
//
Script.Load("lua/ScriptActor.lua")

class 'FuncDoor' (ScriptActor)
FuncDoor.kMapName = "ns2siege_funcdoor"
FuncDoor.kOpenDelta = 0.001

local kOpeningEffect = PrecacheAsset("cinematics/environment/steamjet_ceiling.cinematic")

local networkVars =
{
    scale = "vector",
    isOpened = "boolean",
    isMoving = "boolean"
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)

// Entity defined properties:
// type         (0-FrontDoor; 1-SiegeDoor; ...)
function FuncDoor:GetDoorType()     return self.type end
// model        (models/props/eclipse/eclipse_wallmodse_02_door.model)
function FuncDoor:GetModel()        return self.model end
// direction    (0-Up; 1-Down; 2-Left; 3-Right)
function FuncDoor:GetDirection()    return self.direction end
// distance     (10)
function FuncDoor:GetDistance()     return self.distance end
// speed        (0.25)
function FuncDoor:GetSpeed()        return self.speed end
// is opened or is actually opening
function FuncDoor:GetIsOpened()     return self.isOpened or self.isMoving end

local function SetDestination(self)
    local destination = self:GetDestination()
    local direction = destination - self.srcPosition
    return destination, GetNormalizedVector(direction) * self:GetSpeed()
end

function FuncDoor:OnCreate()
    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    
    // self.type
    // self.model
    // self.direction
    // self.distance
    // self.speed
    // self.protection
end

function FuncDoor:OnInitialized()
    ScriptActor.OnInitialized(self)  

    if self.model ~= nil and GetFileExists(self.model) then
        Shared.PrecacheModel(self.model)
        self:SetModel(self.model)
    end

    if Server then
        self.isOpened = false
        self.isMoving = false
        self.srcPosition = Vector(self:GetOrigin())
        self.srcRotation = Angles(self:GetAngles())
        self.dstPosition, self.momentum = SetDestination(self)
        self.protection = Clamp(self.protection, 0, 15)
    elseif Client then
        self.outline = false
    end

    self:SetPhysicsType(PhysicsType.Kinematic)
    self:MakeSurePlayersCanGoThroughWhenMoving()
end

if Server then 
   
    function FuncDoor:BeginOpenDoor(doorType)
        if self.type == doorType then
            self.isMoving = true
        end
    end
    
    function FuncDoor:Reset()
        ScriptActor.Reset(self)

        if Server then
            self.isOpened = false
            self.isMoving = false
            self:SetAngles(self.srcRotation)
            self:SetOrigin(self.srcPosition)
            self.dstPosition, self.momentum = SetDestination(self)
        end
        
        self:MakeSurePlayersCanGoThroughWhenMoving()            
    end

    function FuncDoor:OnUpdate(deltaTime) 
        if self.isOpened then
            return
        end
        if self.isMoving then 
            // UpdatePosition by delta time
            self:MakeSurePlayersCanGoThroughWhenMoving()
            
            local startPoint = Vector(self:GetOrigin())
            local distance = (self.dstPosition - startPoint):GetLength()
            local delta = deltaTime * self.momentum

            // check, whether doors are already opened
            if distance <= FuncDoor.kOpenDelta then
                self.isOpened = true
                return
            end

            local endPoint = ConditionalValue(distance > delta:GetLength(), startPoint + delta, self.dstPosition)
            self:SetOrigin(endPoint)
            self:MakeSurePlayersCanGoThroughWhenMoving()
            
        else
            // delete all nearby cysts (cut cyst path)
            for _, cysts in ipairs(GetEntitiesForTeamWithinRange("Cyst", 2, self:GetOrigin(), self.protection)) do
                DestroyEntity(cysts)
            end 
        end
    end
    
    function FuncDoor:GetDestination() 
        local dst = self:GetOrigin()

        if self:GetDirection() == 0 then       // Up
            dst = dst + Vector(0,  self:GetDistance(), 0)
        elseif self:GetDirection() == 1 then   // Down
            dst = dst + Vector(0, -self:GetDistance(), 0)
        elseif self:GetDirection() == 2 then   // Left
            dst = dst + Vector( self:GetDistance(), 0, 0)
        elseif self:GetDirection() == 3 then   // Right
            dst = dst + Vector(-self:GetDistance(), 0, 0)
        end

        return dst
    end     
end

if Client then

    function FuncDoor:OnDestroy()
        if self.outline then
            local model = self:GetRenderModel()
            if model ~= nil then
                EquipmentOutline_RemoveModel(model)
                HiveVision_RemoveModel( model )
            end
        end
    end
    function FuncDoor:OnModelChanged()
        self.outline = false
    end

    function FuncDoor:OnUpdate(deltaTime)
        local player = Client.GetLocalPlayer()
        local model = self:GetRenderModel()
        local outline = not self:GetIsOpened()
        
        if model ~= nil and outline ~= self.outline then
            self.outline = outline
            
            EquipmentOutline_RemoveModel( model )
            HiveVision_RemoveModel( model )
            
            if outline then
                EquipmentOutline_AddModel( model, kEquipmentOutlineColor.Fuchsia )
                HiveVision_AddModel( model )
            end
            
        end
    end

end

function FuncDoor:OnAdjustModelCoords(modelCoords)
    local coords = modelCoords
    if self.scale and self.scale:GetLength() ~= 0 then
        coords.xAxis = coords.xAxis * self.scale.x
        coords.yAxis = coords.yAxis * self.scale.y
        coords.zAxis = coords.zAxis * self.scale.z
    end
    return coords
end

function FuncDoor:MakeSurePlayersCanGoThroughWhenMoving()
    self:UpdateModelCoords()
    self:UpdatePhysicsModel()
    if (self._modelCoords and self.boneCoords and self.physicsModel) then
        self.physicsModel:SetBoneCoords(self._modelCoords, self.boneCoords)
    end  
    self:MarkPhysicsDirty()
end

Shared.LinkClassToMap("FuncDoor", FuncDoor.kMapName, networkVars)
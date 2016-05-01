//
//	ns2siege+ Custom Game Mode
//	ZycaR (c) 2016
//
Script.Load("lua/ScriptActor.lua")
Script.Load("lua/ObstacleMixin.lua")

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
AddMixinNetworkVars(ObstacleMixin, networkVars)

// Entity defined properties:
//      self.type
//      self.model
//      self.direction
//      self.distance
//      self.speed
//      self.protection
    
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

local function FindDestination(self)
    local destination = self:GetDestination()
    local direction = destination - self.srcPosition
    return destination, GetNormalizedVector(direction) * self:GetSpeed()
end

function FuncDoor:OnCreate()
    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, ObstacleMixin)
end

function FuncDoor:OnInitialized()
    ScriptActor.OnInitialized(self)  

    if Server then

        if self.model ~= nil and GetFileExists(self.model) then
            Shared.PrecacheModel(self.model)
            self:SetModel(self.model)

            self:SetPhysicsType(PhysicsType.Kinematic)
            self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)
       else
            Shared.Message("Missing or invalid func_door model")
        end

        self.isOpened = false
        self.isMoving = false
        
        self.srcPosition = Vector(self:GetOrigin())
        self.srcRotation = Angles(self:GetAngles())
        self.dstPosition, self.momentum = FindDestination(self)
        self.protection = Clamp(self.protection, 0, 15)

    elseif Client then
        self.outline = false
    end
end

local function DrawDebugBox(self, lifetime)
    if Shared.GetCheatsEnabled() or Shared.GetDevMode() then 
        local size = self:GetObstacleRadius()
        local min = self:GetModelOrigin() + Vector(-size,-size,-size)
        local max = self:GetModelOrigin() + Vector( size, size, size)
        DebugBox(min, max, Vector(0,0,0), lifetime, 1, 0, 0, 1)
    end
end

function FuncDoor:Reset()
    ScriptActor.Reset(self)

    if Server then
        self.isOpened = false
        self.isMoving = false
        self:SetAngles(self.srcRotation)
        self:SetOrigin(self.srcPosition)
        self.dstPosition, self.momentum = FindDestination(self)
        self:SyncPhysicsModel()
        
        self:RemoveFromMesh()
        self:SyncToObstacleMesh()
        
        DrawDebugBox(self, 100)
    end

end

function FuncDoor:OnUpdate(deltaTime)
    if Server then
        self:OnUpdatePosition(deltaTime)
        self:SyncPhysicsModel()
        self:SyncToObstacleMesh()
    elseif Client then
        self:OnUpdateOutline()
    end
end

if Server then 
   
    function FuncDoor:BeginOpenDoor(doorType)
        if self.type == doorType then
            self.isMoving = true
        end
    end
    
    function FuncDoor:OnUpdatePosition(deltaTime) 
        if self.isOpened then
            return
        end
        if self.isMoving then 
            // UpdatePosition by delta time
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

            self:RemoveFromMesh()
            self:SyncPhysicsModel()
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

    function FuncDoor:OnUpdateOutline()
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

function FuncDoor:SyncPhysicsModel()
    local physModel = self:GetPhysicsModel()
    if physModel then
        local coords = self:OnAdjustModelCoords(self:GetCoords())
        coords.origin = self:GetOrigin()
        physModel:SetCoords(coords)
        physModel:SetBoneCoords(coords, CoordsArray())
    end    
end

function FuncDoor:GetScaledModelExtents()
    local min, max = self:GetModelExtents()
    local extents = max * 0.5

    if self.scale ~= nil then
        extents.x = extents.x * self.scale.x
        extents.y = extents.y * self.scale.y
        extents.z = extents.z * self.scale.z    
    end
    
    return extents
end

function FuncDoor:GetObstacleCenterPoint()
    return self:GetModelOrigin()
end

function FuncDoor:GetObstacleRadius()
    return self:GetScaledModelExtents():GetLengthXZ()
end

// add or remove from pathing mesh
function FuncDoor:SyncToObstacleMesh() 
	if not self:GetIsOpened() and self.obstacleId == -1 then
        self:AddToMesh()
    end
    
    if self:GetIsOpened() and self.obstacleId ~= -1 then
        self:RemoveFromMesh()
    end
end

Shared.LinkClassToMap("FuncDoor", FuncDoor.kMapName, networkVars)
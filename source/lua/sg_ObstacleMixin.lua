//
//	ns2siege+ Custom Game Mode
//	ZycaR (c) 2016
//

kFuncDoorMapName = "ns2siege_funcdoor"

function ObstacleMixin:OnInitialized()
    //self:AddToMesh()
end

function ObstacleMixin:OnPathingMeshInitialized()
    //self:AddToMesh()
end

local ns2_GetPathingInfo = ObstacleMixin._GetPathingInfo
function ObstacleMixin:_GetPathingInfo()

    if self:GetMapName() ~= kFuncDoorMapName or not self._modelCoords then
        return ns2_GetPathingInfo(self)
    end

    local centerpoint = self:GetModelOrigin() + Vector(0, -100, 0)
    local radius = Clamp(self:GetScaledModelExtents():GetLengthXZ(), 1.5, 24.0)
    return centerpoint, radius, 1000.0
end

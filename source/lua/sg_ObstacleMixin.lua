//
//	ns2siege+ Custom Game Mode
//	ZycaR (c) 2016
//

local ns2_GetPathingInfo = ObstacleMixin._GetPathingInfo
function ObstacleMixin:_GetPathingInfo()

    if self:GetMapName() ~= "ns2siege_funcdoor" or not self._modelCoords then
        return ns2_GetPathingInfo(self)
    end

    local centerpoint = self:GetModelOrigin() + Vector(0, -100, 0)
    local radius = Clamp(self:GetScaledModelExtents():GetLengthXZ(), 1.5, 24.0)
    return centerpoint, radius, 1000.0
end

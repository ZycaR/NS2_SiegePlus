//
//	ns2siege+ Custom Game Mode
//	ZycaR (c) 2016
//

// Truce mode untill front doors are closed
local ns2_DoDamage = DamageMixin.DoDamage
function DamageMixin:DoDamage(damage, target, point, direction, surface, altMode, showtracer)
    local front, siege, suddendeath = GetGameInfoEntity():GetSiegeTimes()
    if front > 0 and siege > 0 then
        return false    // peacemaker
    end
    return ns2_DoDamage(self, damage, target, point, direction, surface, altMode, showtracer)
end

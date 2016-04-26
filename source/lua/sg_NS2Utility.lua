//
//	ns2siege+ Custom Game Mode
//	ZycaR (c) 2016
//

if Server then

    // Truce mode untill front doors are closed
    local ns2_CanEntityDoDamageTo = CanEntityDoDamageTo
    function CanEntityDoDamageTo(attacker, target, cheats, devMode, friendlyFire, damageType)
        if not GetGamerules():GetFrontDoorsOpen() then
            return false    // peacemaker
        end
        return ns2_CanEntityDoDamageTo(self, attacker, target, cheats, devMode, friendlyFire, damageType)
    end

end

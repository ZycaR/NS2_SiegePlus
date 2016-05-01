//
//	ns2siege+ Custom Game Mode
//	ZycaR (c) 2016
//

NS2Gamerules.kFrontDoorSound = PrecacheAsset("sound/siegeroom.fev/door/frontdoor")
NS2Gamerules.kSiegeDoorSound = PrecacheAsset("sound/siegeroom.fev/door/siege")

function NS2Gamerules:GetFrontDoorsOpen()
    local gameLength = Shared.GetTime() - self:GetGameStartTime()
    return self:GetGameStarted() and gameLength > self.FrontDoorTime
end

function NS2Gamerules:GetSiegeDoorsOpen()
    local gameLength = Shared.GetTime() - self:GetGameStartTime()
    return self:GetGameStarted() and gameLength > self.SiegeDoorTime
end

function NS2Gamerules:GetSuddenDeathActivated()
    local gameLength = Shared.GetTime() - self:GetGameStartTime()
    return self:GetGameStarted() and gameLength > self.SuddenDeathTime
end


if Server then

    local function TestFrontDoorTime(client)
        if Shared.GetCheatsEnabled() or Shared.GetDevMode() then 
            local ns2gamerules = GetGamerules()
            ns2gamerules:OpenFuncDoors(kFrontDoorType, NS2Gamerules.kFrontDoorSound)
            ns2gamerules.frontDoors = true
            Shared.Message("= Front Doors =")
        end
    end
    Event.Hook("Console_frontdoor", TestFrontDoorTime)

    local function TestSiegeDoorTime(client)
        if Shared.GetCheatsEnabled() or Shared.GetDevMode() then 
            local ns2gamerules = GetGamerules()
            ns2gamerules:OpenFuncDoors(kSiegeDoorType, NS2Gamerules.kSiegeDoorSound)
            ns2gamerules.siegeDoors = true
            Shared.Message("= Siege Doors =")
        end
    end
    Event.Hook("Console_siegedoor", TestSiegeDoorTime)

    function NS2Gamerules:OpenFuncDoors(doorType, soundEffectType)
 
        local siegeMessageType = kDoorTypeToSiegeMessage[doorType]
        SendSiegeMessage(self.team1, siegeMessageType)
        SendSiegeMessage(self.team2, siegeMessageType)

        for _, door in ientitylist(Shared.GetEntitiesWithClassname("FuncDoor")) do
            door:BeginOpenDoor(doorType)
        end

        local siegeSoundType = kDoorTypeToSiegeMessage[doorType]
        for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
            if player:GetIsOnPlayingTeam() then
                //Shared.Message('effect ..')
                StartSoundEffectForPlayer(soundEffectType, player)
            end
        end

    end
    
    // Update doors status (techpoints are close enough method)
    local ns2_UpdateTechPoints = NS2Gamerules.UpdateTechPoints
    function NS2Gamerules:UpdateTechPoints()
        ns2_UpdateTechPoints(self)

        if not self.frontDoors and self:GetFrontDoorsOpen() then
            self:OpenFuncDoors(kFrontDoorType, NS2Gamerules.kFrontDoorSound)
            self.frontDoors = true
        end

        if not self.siegeDoors and self:GetSiegeDoorsOpen() then
            self:OpenFuncDoors(kSiegeDoorType, NS2Gamerules.kSiegeDoorSound)
            self.siegeDoors = true
        end
    end

    // Reset door status
    local ns2_ResetGame = NS2Gamerules.ResetGame
    function NS2Gamerules:ResetGame()
        ns2_ResetGame(self)

        self.frontDoors = false
        self.siegeDoors = false
    end

end
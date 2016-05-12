//
//	ns2siege+ Custom Game Mode
//	ZycaR (c) 2016
//

if Server then
    Script.Load("lua/Server.lua")
elseif Client then
    Script.Load("lua/Client.lua")
elseif Predict then
    Script.Load("lua/Predict.lua")
end

Script.Load("lua/sg_FuncDoor.lua")
Script.Load("lua/sg_FuncMaid.lua")
Script.Load("lua/sg_NetworkMessages.lua")

// increase contamination cooldown significanlty ... because siege is about turtling!
kContaminationCooldown = 60
kContaminationBileSpewCount = 1 

kFrontDoorType = 0
kSiegeDoorType = 1

kDoorTypeToSiegeMessage = {}
kDoorTypeToSiegeMessage[kFrontDoorType] = kSiegeMessageTypes.FrontDoorOpened
kDoorTypeToSiegeMessage[kSiegeDoorType] = kSiegeMessageTypes.SiegeDoorOpened


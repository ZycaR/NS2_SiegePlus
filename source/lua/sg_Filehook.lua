//
//	ns2siege+ Custom Game Mode
//	ZycaR (c) 2016
//

ModLoader.SetupFileHook( "lua/GameInfo.lua", "lua/sg_GameInfo.lua" , "post" )
ModLoader.SetupFileHook( "lua/NS2Gamerules.lua", "lua/sg_NS2Gamerules.lua" , "post" )

// Truce mode untill front/siege doors are closed
ModLoader.SetupFileHook( "lua/DamageMixin.lua", "lua/sg_DamageMixin.lua" , "post" )

// Special dynamicaly generated obstacles for func_doors
ModLoader.SetupFileHook( "lua/ObstacleMixin.lua", "lua/sg_ObstacleMixin.lua" , "post" )

// Hook custom gui elements
ModLoader.SetupFileHook( "lua/GUIWorldText.lua", "lua/sg_GUIScriptLoader.lua" , "post" )

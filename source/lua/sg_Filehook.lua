//
//	ns2siege+ Custom Game Mode
//	ZycaR (c) 2016
//

ModLoader.SetupFileHook( "lua/NS2Utility.lua", "lua/sg_NS2Utility.lua" , "post" )
ModLoader.SetupFileHook( "lua/GameInfo.lua", "lua/sg_GameInfo.lua" , "post" )
ModLoader.SetupFileHook( "lua/NS2Gamerules.lua", "lua/sg_NS2Gamerules.lua" , "post" )

// hook custom gui elements
ModLoader.SetupFileHook( "lua/GUIWorldText.lua", "lua/sg_GUIScriptLoader.lua" , "post" )

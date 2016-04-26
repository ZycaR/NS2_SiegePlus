//
//	ns2siege+ Custom Game Mode
//	ZycaR (c) 2016
//

class 'GUIDoorTimers' (GUIScript)

// half of screen & one row
GUIDoorTimers.kBackgroundScale = Vector(460, 32, 0)
GUIDoorTimers.kDoorTimersFontName = Fonts.kArial_17 

function GUIDoorTimers:OnResolutionChanged(oldX, oldY, newX, newY)
    self:Uninitialize()
    self:Initialize()
end

function GUIDoorTimers:Initialize()
    local backgroundSize = GUIScale(GUIDoorTimers.kBackgroundScale)
    
    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize(backgroundSize)
    self.background:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.background:SetPosition( Vector( -backgroundSize.x / 2, GUIScale(10), 0) )
    self.background:SetIsVisible(false)
    self.background:SetColor(Color(0,0,0,0.5))
    self.background:SetLayer(kGUILayerLocationText)
    
    self.timers = GUIManager:CreateTextItem()
    self.timers:SetFontName(GUIDoorTimers.kDoorTimersFontName)
    self.timers:SetScale(GetScaledVector())
    GUIMakeFontScale(self.timers)
    self.timers:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.timers:SetTextAlignmentX(GUIItem.Align_Center)
    self.timers:SetTextAlignmentY(GUIItem.Align_Center)
    self.timers:SetColor(Color(1, 1, 1, 1))
    self.timers:SetText("TIMERS")
    self.background:AddChild(self.timers) 
end

function GUIDoorTimers:Uninitialize()
    GUI.DestroyItem(self.timers)
    self.timers = nil
    
    GUI.DestroyItem(self.background)
    self.background = nil 
end

function GUIDoorTimers:SetIsVisible(visible)
    //Shared.Message(debug.traceback())
end

local function GetGameInfoEntity()
    local entityList = Shared.GetEntitiesWithClassname("GameInfo")
    if entityList:GetSize() > 0 then    
        return entityList:GetEntityAtIndex(0)
    end
end

local function FormatTimer(time)
    if time > 0 then
        local minutes = math.floor( time / 60 )
        local seconds = math.floor( time - minutes * 60 ) 
        return string.format("%d:%02d", minutes, seconds) 
    end
    return "OPEN"
end

function GUIDoorTimers:Update(deltaTime)
    local text = ""
    local visible = false
    local gameTime = PlayerUI_GetGameLengthTime()
    
    if PlayerUI_GetHasGameStarted() and (gameTime > 0) then
        local front, siege, suddendeath = GetGameInfoEntity():GetSiegeTimes()
        if front > 0 or siege > 0 then
            text = string.format("Front Door: %s | Siege Door: %s", FormatTimer(front), FormatTimer(siege))
        else
            text = string.format("Sudden Death in: %s", FormatTimer(suddendeath))
        end
        self.timers:SetText(text) 
        visible = true
    end

    self.background:SetIsVisible(visible)
    self.timers:SetIsVisible(visible)
end

local composer = require( "composer" )
local widget = require( "widget" ) 

local scene = composer.newScene()
local sizeText

sizeOfField = 4

local function setSwitchText(text)
    sizeText.text = text
end

local function setSize(size)
    sizeOfField = size
    if sizeOfField < 3 then sizeOfField = 8
    elseif sizeOfField > 8 then sizeOfField = 3 end
    setSwitchText(tostring(sizeOfField)..' X '..tostring(sizeOfField))
end

local function scaleBt(start)
    transition.to(start, {time = 500, width = 1, height = 1, delta = true, onComplete = function()
        transition.to(start, {time = 500, width = -1, height = -1, delta = true})
    end})
end

function scene:create( event )
 
    local sceneGroup = self.view 

    local bg = display.newImageRect('padoru/bg.jpg', display.contentWidth+400, display.contentHeight)
    bg.x, bg.y = display.contentCenterX, display.contentCenterY

    local switchGroup = display.newGroup()

    local switchColor = {0.97, 0.64, 0.1}
    local textColor = {0.96, 0.9, 0.8}

    local leftBt = widget.newButton({
        onPress = function() setSize(sizeOfField-1) end,
        label = "<",
        fontSize = 90,
        labelColor = { default = switchColor, over = switchColor },
        left = 100,
        top = 455,

        shape = "roundedRect",
        width = 100,
        height = 100,
        cornerRadius = 2,
        fillColor = { default={1,1,1,0}, over={1,1,1,0} },
        strokeColor = { default={1,1,1,0}, over={1,1,1,0} },
        strokeWidth = 4
    })
    local rightBt = widget.newButton({
        onPress = function() setSize(sizeOfField+1) end,
        label = ">",
        fontSize = 90,
        labelColor = { default = switchColor, over = switchColor },
        left = 440,
        top = 455,

        shape = "roundedRect",
        width = 100,
        height = 100,
        cornerRadius = 2,
        fillColor = { default={1,1,1,0}, over={1,1,1,0} },
        strokeColor = { default={1,1,1,0}, over={1,1,1,0} },
        strokeWidth = 4
    })
    sizeText = display.newText({
        text = "4 X 4",
        x = display.contentCenterX,
        y = 500,
        fontSize = 60,
        font = native.systemFontBold
    })

    local start = widget.newButton({
        onPress = function() gotoScene('game') end,
        label = "Start",
        fontSize = 110,
        labelColor = { default = textColor, over = textColor },
        top = 650,

        shape = "roundedRect",
        width = 100,
        height = 100,
        cornerRadius = 2,
        fillColor = { default={1,1,1,0}, over={1,1,1,0} },
        strokeColor = { default={1,1,1,0}, over={1,1,1,0} },
        strokeWidth = 4
    })
    start.x = display.contentCenterX
    timer.performWithDelay(1000, function() scaleBt(start) end, -1)
    sizeText.fill = textColor
    switchGroup:insert(bg)
    switchGroup:insert(leftBt)
    switchGroup:insert(rightBt)
    switchGroup:insert(sizeText)


    sceneGroup:insert(switchGroup)
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
        
    end
end
 
 
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        
 
    elseif ( phase == "did" ) then
        
 
    end
end
 
 
function scene:destroy( event )
 
    local sceneGroup = self.view
 
end
 
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
 
return scene

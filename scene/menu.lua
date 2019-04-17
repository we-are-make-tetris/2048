local composer = require( "composer" )
local widget = require( "widget" ) 
local json = require("json")

local scene = composer.newScene()
local sizeText

local backColor = {0.09, 0.1, 0.15}
local darkFrontColor = {0.39, 0.16, 0.16}
local frontColor = {0.46, 0.07, 0.07}

_G.sizeOfField = 4
_G.achievements = { -- ачивки, если true, то она получена
    a4096 = false, -- ачивка за плитку 4096
    a8192 = false, -- и т.д.
    a16384= false, -- и т.д.
    a32786= false,
    a65536= false,
    a131072=false,
}
_G.minTile = 2
_G.maxTile = 4
_G.minChance = 90
_G.maxChance = 10
_G.pineCoins = 0

local function readSaves()
    local path = system.pathForFile( "achievements.json", system.DocumentsDirectory )
    local file, errorstr = io.open(path, "r")
    if file then
        local t = json.decode(file:read("*a"))
        for k, v in pairs(achievements) do
            achievements[k] = v or t[k]
        end
    else
        file = io.open(path, "w")

        local t = json.encode(_G.achievements)

        file:write(t)

        file:close()
    end
    local path2 = system.pathForFile( "storestuff.json", system.DocumentsDirectory )
    local file2 = io.open(path2, "r")
    if file2 then
        local t = json.decode(file2:read("*a"))
        minTile = t.min
        maxTile = t.max
        minChance = t.minChance
        maxChance = t.maxChance
        pineCoins = t. pineCoin
    else
        file2 = io.open(path2, "w")

        local l = {
            min = 2,
            max = 4,
            minChance = 90,
            maxChance = 10,
            pineCoin = 0,
        }

        local t = json.encode(l)

        file2:write(t)

        file2:close()
    end
end

function scene:setSwitchText(text)
    self.sizeText.text = text
end

local function setSize(size)
    sizeOfField = size
    if sizeOfField < 2 then sizeOfField = 10
    elseif sizeOfField > 10 then sizeOfField = 2 end
    scene:setSwitchText(tostring(sizeOfField)..' X '..tostring(sizeOfField))
end

local function scaleBt(start, width, height)
    transition.to(start, {time = 500, width = width-1, height = height+1, delta = false, onComplete = function()
        transition.to(start, {time = 500, width = width+1, height = height-1, delta = false})
    end})
end

function scene:create( event )
 
    local sceneGroup = self.view 

    readSaves()

    local bg = display.newImageRect('padoru/bg.jpg', display.contentWidth, display.contentHeight+170)
    bg.x, bg.y = display.contentCenterX, display.contentCenterY

    local switchColor = {0.97, 0.64, 0.1}
    local textColor = {0.96, 0.9, 0.8}

    local switchGroup = display.newGroup()
    local moneyGroup = display.newGroup()
    local btGroup = display.newGroup()

    local leftBt = widget.newButton({
        parent = switchGroup,
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
    self.sizeText = display.newText({
        text = "4 X 4",
        x = display.contentCenterX,
        y = 500,
        fontSize = 60,
        font = native.systemFontBold
    })
    self.sizeText.fill = textColor

    switchGroup:insert(self.sizeText)
    switchGroup:insert(leftBt)
    switchGroup:insert(rightBt)

    local start = widget.newButton({
        onPress = function() composer.gotoScene('scene.game', {effect = 'slideLeft', time = 200}) end,
        label = "Start",
        fontSize = 110,
        labelColor = { default = textColor, over = textColor },
        top = 650,

        cornerRadius = 2,
        fillColor = { default={1,1,1,0}, over={1,1,1,0} },
        strokeColor = { default={1,1,1,0}, over={1,1,1,0} },
        strokeWidth = 4
    })
    start.x = display.contentCenterX
    local debWidth, debHeight = start.width, start.height
    scaleBt(start, debWidth, debHeight)
    timer.performWithDelay(990, function() scaleBt(start, debWidth, debHeight) end, -1)
   
    local moneyTitle = display.newRoundedRect(80, 45, 100, 90, 20)  
    moneyTitle:setFillColor(unpack(backColor))
    moneyTitle.strokeWidth = 5
    moneyTitle:setStrokeColor(unpack(frontColor))

    local moneyTitle2 = display.newRoundedRect(320, 45, 330, 90, 20)  
    moneyTitle2:setFillColor(unpack(backColor))
    moneyTitle2.strokeWidth = 5
    moneyTitle2:setStrokeColor(unpack(frontColor))

    local money = display.newImageRect('padoru/Money2.png', 80, 70)
    money.x, money.y = 80, 45

    local moneyAdd = widget.newButton({
        onPress = function()

        end,

        label = '+',
        fontSize = 100,

        top = -10,
        left = 500,

        shape = 'roundedRect',
        height = 90,
        width = 90,
        cornerRadius = 30,
        strokeWidth = 5,

        fillColor = {default = backColor, over = backColor},
        strokeColor = {default = frontColor, over = frontColor},
        labelColor = {default = {1}, over = {1}}
    })

    moneyGroup:insert(moneyTitle2)
    moneyGroup:insert(moneyTitle)
    moneyGroup:insert(money)
    moneyGroup:insert(moneyAdd)


    local achive = widget.newButton({
        onPress = function()
            composer.showOverlay("scene.shop",{
                effect = "slideDown",
                time = 200,
                isModal = false
            })
        end,
        defaultFile = 'padoru/achive.png',


        top = 100,
        left = 50,

        width = 150,
        height = 185,

        fillColor = { default={1,1,1,0}, over={1,1,1,0} },
        strokeColor = { default={1,1,1,0}, over={1,1,1,0} },
        strokeWidth = 4
    })

    local shop = widget.newButton({
        onPress = function()
            composer.showOverlay("scene.achives",{
                effect = "slideDown",
                time = 200,
                isModal = true
            })
        end,
        defaultFile = 'padoru/shop.png',


        top = 100,
        left = 250,

        width = 150,
        height = 185,

        fillColor = { default={1,1,1,1}, over={1,1,1,0} },
        strokeColor = { default={1,1,1,0}, over={1,1,1,0} },
        strokeWidth = 4
    })
    btGroup:insert(achive)
    btGroup:insert(shop)
    btGroup.y = 50 


    sceneGroup:insert(bg)
    sceneGroup:insert(switchGroup)
    sceneGroup:insert(start)
    sceneGroup:insert(btGroup)
    sceneGroup:insert(moneyGroup)
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

local composer = require( "composer" )
local widget = require( "widget" )
local json = require("json")


local Tile = require("objects.tile")
local Field= require("objects.Field")


local gameField -- игровое поле, просто экземпляр класса
local scoreText

local scene = composer.newScene()


local backGroup  -- группа заднего плана
local mainGroup  -- группа игрового поля
local uiGroup -- группа ui
function switchText(x)
	scoreText.text = tostring(x)
end

local function saveCopy()
	local t = json.encode({
		["matrix"] = gameField.matrix,
		["totalScore"] = gameField.totalScore
	})
	local l = json.decode(t, _, nil)
	LAST_Field_Copy = l
end
local function applyCopy(  )
	if not LAST_Field_Copy.matrix then return 0 end
	local gf = Field(gameField.size, gameField.group)

	gf:setField(LAST_Field_Copy.matrix, LAST_Field_Copy.totalScore)
	gameField = gf
end
local function openField(size, group) 
	local path = system.pathForFile( "map" .. tostring(size) .. ".json", system.DocumentsDirectory )
    local file, errorstr = io.open(path, "r")
    if file then
    	local gf = Field(size, group)
    	local l = json.decode(file:read("*a"), nil)
    	gf:setField(l.matrix, l.totalScore)
    	file:close()
    	return gf
	else
		local gf = Field(size, group)
		gf:addNewTile()
		gf:addNewTile()
		return gf
    end
end
local function saveField()
	local path = system.pathForFile( "map" .. tostring(gameField.size) .. ".json", system.DocumentsDirectory )
	local file = io.open(path, "w")
	local t = json.encode({
		["matrix"] = gameField.matrix,
		["totalScore"] = gameField.totalScore
	})
	file:write(t)
	file:close()

	path = system.pathForFile( "achievements.json", system.DocumentsDirectory )

	file = io.open(path, "w")

    t = json.encode(_G.achievements)

    file:write(t)

    file:close()

    path2 = system.pathForFile( "storestuff.json", system.DocumentsDirectory )

    local file2 = io.open(path2, "w")

    local l = {
        min = minTile,
        max = maxTile,
        minChance = minChance,
        maxChance = maxChance,
        pineCoin = pineCoins,
    }

    t = json.encode(l)

    file2:write(t)

    file2:close()
end
local function recycleField()
	gameField:removeAll()
	local gf = Field(gameField.size, gameField.group)
	gf:addNewTile()
	gf:addNewTile()
	gameField = gf
	saveField()
end



-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- объявляю переменные

_G.ACCEPTION = true -- я не уверен нужна ли эта переменная, но она короче должна отвечать за нажатия, типо если нажата какая - то клавиша, то другую нажимать нельзя
_G.GameOver = false -- глобальная переменная, если она true, то игрок больше не может двигаться, иначе может

_G.LAST_Field_Copy = {} -- эта пременная должна отвечать за последнее сохранение игры, откат на шаг назад.

_G.gradientSheet = graphics.newImageSheet("padoru/sheet.png", gradientsOpts:getSheet())
_G.padoruSheet = graphics.newImageSheet("padoru/padorusheet.png", padoruOptions:getSheet())


_G.gameOverEvent = function()
	local div = function(a, b) 
		local x = 0
		while a > b do a = a- b; x = x + 1 end
		return x
	end
	local x = div(gameField.totalScore, 1000)
	local added = (8 - gameField.size) * x
	pineCoins = pineCoins + added
	recycleField()
end



_G.numOfAnims = 0
_G.completedAnim = function()
	numOfAnims = numOfAnims - 1
	if numOfAnims == 0 then
		ACCEPTION = true
		gameField:addNewTile()
	end
end
-- lastTouch = 0 -- она тебя не трогает, и ты ее не трогай


-- свапы от клавиатуры(стрелки)
function swap(event)
	local phase = event.phase -- фаза, нам нужно реагировать только если клавиша отпущена
	if phase == "up" then
		local key = event.keyName -- название нажатой клавишы
		if ACCEPTION then -- если не происходит анимации и при этом можно нажимать (строка 22)
			if key == "up" then
				ACCEPTION = false
				saveCopy()
				gameField:swapUp()
			elseif key == "down" then
				ACCEPTION = false
				saveCopy()
				gameField:swapDown()
			elseif key == "left" then
				ACCEPTION = false
				saveCopy()
				gameField:swapLeft()
			elseif key == "right" then
				ACCEPTION = false
				saveCopy()
				gameField:swapRight()
			elseif key == "b" then
				applyCopy()
			elseif key == "r" then
				recycleField()
			end
		end
	end
end


-- рекомендую сюда не лезть, это жопка
-- реагирование на свайпы на телефоне.
function swipe(event)
	local phase = event.phase
	if phase == "ended" and ACCEPTION then
		
		local dx = event.x - event.xStart -- дельта х, если отрицательна, то свайп влево, иначе вправо
		local dy = event.y - event.yStart -- дельта у, если отрицаетльна, то свайп вверх, иначе вниз
		local amplX = display.contentWidth / 8 -- максимальное отклонение, от начального икса
		local amplY = display.contentHeight / 8 -- максимальное отклонение, от начального игрека


		if math.abs(dx) < 3 and math.abs(dy) < 3 then -- если это простое нажите на экран, то не стоит реагировать
			return 0
		end
		-- я даже хз как это объснить
		if math.abs(dx) < amplX then
			if dy < 0 then
				ACCEPTION = false
				saveCopy()
				gameField:swapUp()
			else
				ACCEPTION = false
				saveCopy()
				gameField:swapDown()
			end
		else
			if dx < 0 then
				ACCEPTION = false
				saveCopy()
				gameField:swapLeft()
			else
				ACCEPTION = false
				saveCopy()
				gameField:swapRight()
			end
		end
	end
end


function save( event ) if event.type == "applicationExit" then saveField() end 
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	mainGroup = display.newGroup()
	uiGroup = display.newGroup()
	-- начало игры
	
	local back = widget.newButton({
		onPress = function()
            composer.gotoScene("scene.menu",{
                effect = "slideRight",
                time = 200
            })
        end,
        defaultFile = 'padoru/back.png',

        top = 25,
        left = 350,
        width = 100,
        height = 100,

        fillColor = { default={1,1,1,0}, over={1,1,1,0} },
        strokeColor = { default={1,1,1,0}, over={1,1,1,0} },
	})		
	local restart = widget.newButton({
		onPress = function()
			recycleField()
		end,
		defaultFile = 'padoru/restart.png',

        top = 850,
        left = 150,
        width = 100,
        height = 100,

        fillColor = { default={1,1,1,0}, over={1,1,1,0} },
        strokeColor = { default={1,1,1,0}, over={1,1,1,0} },
	})
	local backStep = widget.newButton({
		onPress = function()
			applyCopy()
		end,
		defaultFile = 'padoru/backStep.png',

        top = 850,
        left = 400,
        width = 100,
        height = 100,

        fillColor = { default={1,1,1,0}, over={1,1,1,0} },
        strokeColor = { default={1,1,1,0}, over={1,1,1,0} },
	})

	scoreText = display.newText({
		text = 0,
		x = display.contentCenterX/5,
		y = display.actualContentHeight/20,
		font = native.systemFont,
		fontSize = display.actualContentHeight/40,
	})


	uiGroup:insert(scoreText)
	sceneGroup:insert(backStep)
	sceneGroup:insert(restart)
	sceneGroup:insert(back)

	sceneGroup:insert(mainGroup)
	sceneGroup:insert(uiGroup)
	
end

-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
		gameField = openField(sizeOfField, mainGroup)
	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		--Добавление ивентов
		switchText(gameField.totalScore)
		Runtime:addEventListener("key", swap) -- реакция на клавиатуру
		Runtime:addEventListener("touch", swipe) -- на свайпы
		Runtime:addEventListener("system", save)
	end

end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

		-- Code here runs when the scene is on screen (but is about to go off screen)

		


	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		
		saveField()
		LAST_Field_Copy = {}
    	Runtime:removeEventListener("key", swap) -- реакция на клавиатуру
		Runtime:removeEventListener("touch", swipe) -- на свайпы
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene

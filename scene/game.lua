local composer = require( "composer" )
local widget = require( "widget" )
local json = require("json")

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- объявляю переменные
local Tile = require("objects.tile")
local Field= require("objects.Field")

_G.ACCEPTION = true -- я не уверен нужна ли эта переменная, но она короче должна отвечать за нажатия, типо если нажата какая - то клавиша, то другую нажимать нельзя
_G.GameOver = false -- глобальная переменная, если она true, то игрок больше не может двигаться, иначе может

_G.gradientSheet = graphics.newImageSheet("padoru/sheet.png", gradientsOpts:getSheet())
_G.padoruSheet = graphics.newImageSheet("padoru/padorusheet.png", padoruOptions:getSheet())



local gameField -- игровое поле, просто экземпляр класса

local backGroup  -- группа заднего плана
local mainGroup  -- группа игрового поля
local uiGroup -- группа ui
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
				gameField:swapUp()
			elseif key == "down" then
				ACCEPTION = false
				gameField:swapDown()
			elseif key == "left" then
				ACCEPTION = false
				gameField:swapLeft()
			elseif key == "right" then
				ACCEPTION = false
				gameField:swapRight()
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
				gameField:swapUp()
			else
				ACCEPTION = false
				gameField:swapDown()
			end
		else
			if dx < 0 then
				ACCEPTION = false
				gameField:swapLeft()
			else
				ACCEPTION = false
				gameField:swapRight()
			end
		end
	end
end

local function openField(size, group) 
	local path = system.pathForFile( "map" .. tostring(size) .. ".json", system.DocumentsDirectory )
    local file, errorstr = io.open(path, "r")
    if file then
    	local gf = Field(size, group)
    	local l = json.decode(file:read("*a"))
    	gf.field = l.field
    	gf.totalScore = l.totalScore
    	return gf
	else
		return Field(size, group)
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	local mainGroup = display.newGroup()
	local uiGroup = display.newGroup()
	-- начало игры

	for k, v in pairs(achievements) do
		print(k .. " " .. tostring(v))
	end

	local size = 4
	gameField = Field(sizeOfField, mainGroup)
	



	local back = widget.newButton({
		onPress = function()
            composer.gotoScene("scene.menu",{
                effect = "slideRight",
                time = 200
            })
        end,
        defaultFile = 'padoru/back.png',

        top = 50,
        left = 350,
        width = 100,
        height = 100,

        fillColor = { default={1,1,1,0}, over={1,1,1,0} },
        strokeColor = { default={1,1,1,0}, over={1,1,1,0} },
        strokeWidth = 4
	})

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
		gameField:addNewTile()
		gameField:addNewTile()
	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		--Добавление ивентов
		Runtime:addEventListener("key", swap) -- реакция на клавиатуру
		Runtime:addEventListener("touch", swipe) -- на свайпы
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
		local path = system.pathForFile( "map" .. tostring(gameField.size) .. ".json", system.DocumentsDirectory )
		os.remove(path)
    	local file = io.open(path, "w")
    	local t = json.encode({
    		["field"] = gameField.field,
    		["totalScore"] = gameField.totalScore
    	})
    	file:write(t)
    	file:close()


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

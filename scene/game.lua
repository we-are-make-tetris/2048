local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- объявляю переменные
local Tile = require("objects.tile")
local Field= require("objects.Field")

local gameField

local backGroup  
local mainGroup  
local uiGroup 

lastTouch = 0
-- свапы от клавиатуры(стрелки)
function swap(event)
	local phase = event.phase
	if phase == "up" then
		local key = event.keyName
		local time = os.clock()
		if time > lastTouch + timeForMakeDinosaurHappy/1000 * 2 then
			if key == "up" then
				gameField:swapUp()
			elseif key == "down" then
				gameField:swapDown()
			elseif key == "left" then
				gameField:swapLeft()
			elseif key == "right" then
				gameField:swapRight()
			end
			lastTouch = time
		end
	end
end
-- рекомендую сюда не лезть, это жопка
function swipe(event)
	local phase = event.phase
	if phase == "ended" then
		local dx = event.x - event.xStart -- дельта х, если отрицательна, то свайп влево, иначе вправо
		local dy = event.y - event.yStart -- дельта у, если отрицаетльна, то свайп вверх, иначе вниз
		local amplX = display.contentWidth / 8 -- максимальное отклонение, от начального икса
		local amplY = display.contentHeight / 8 -- максимальное отклонение, от начального игрека


		if math.abs(dx) < 5 and math.abs(dy) < 5 then -- если это простое нажите на экран, то не стоит реагировать
			return 0
		end

		-- я даже хз как это объснить
		if math.abs(dx) < amplX then
			if dy < 0 then
				gameField:swapUp()
			else
				gameField:swapDown()
			end
		else
			if dx < 0 then
				gameField:swapLeft()
			else
				gameField:swapRight()
			end
		end
		------------------------------
	end
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
	local size = 4
	gameField = Field(sizeOfField, mainGroup)
	gameField.scoreText.parent = uiGroup
	gameField:addNewTile()
	gameField:addNewTile()
	
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		--Добавление ивентов
		Runtime:addEventListener("key", swap)
		Runtime:addEventListener("touch", swipe)
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

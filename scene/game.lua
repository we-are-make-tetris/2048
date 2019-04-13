local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- объявляю переменные
local Tile = require("objects.tile")
local Field= require("objects.Field")

_G.achievements = { -- ачивки, если true, то она получена
	a4096 = false, -- ачивка за плитку 4096
	a8192 = false, -- и т.д.
	a16384= false, -- и т.д.
	a32786= false,
	a65536= false,
	a131072=false,
}
_G.ACCEPTION = true -- я не уверен нужна ли эта переменная, но она короче должна отвечать за нажатия, типо если нажата какая - то клавиша, то другую нажимать нельзя
_G.GameOver = false -- глобальная переменная, если она true, то игрок больше не может двигаться, иначе может
_G.LAST_Field_Copy = nil -- эта пременная должна отвечать за последнее сохранение игры, откат на шаг назад.

local gameField -- игровое поле, просто экземпляр класса

local backGroup  -- группа заднего плана
local mainGroup  -- группа игрового поля
local uiGroup -- группа ui

-- lastTouch = 0 -- она тебя не трогает, и ты ее не трогай

-- свапы от клавиатуры(стрелки)
function swap(event)
	local phase = event.phase -- фаза, нам нужно реагировать только если клавиша отпущена

	if phase == "up" then
		local key = event.keyName -- название нажатой клавишы
		if not gameField.hasAnimation and ACCEPTION then -- если не происходит анимации и при этом можно нажимать (строка 22)
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
	if phase == "ended" and not gameField.hasAnimation and ACCEPTION then
		
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
	local size = 4 -- размер поля (4*4, 5*5, 8*8)
	gameField = Field(size, mainGroup) -- экземпляр поля
	gameField.scoreText.parent = uiGroup -- забей
	--[[local val = 2
			for i = 1, size do
				for j = 1, size do
					gameField:addNewTile(j, i, val)
					val = val * 2
					gameField.moved = true
				end
			end]] -- на это тоже забей
	gameField:addNewTile() -- Добавление первых двух плиток
	gameField.moved = true --
	gameField:addNewTile() -- 
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

local Tile = Object:extend()

local function setRandomValue() -- двойка = 90%     четверка = 10%
	local x = math.random(10)
	if x <= 1 then
		return 4
	elseif 1 < x then
		return 2
	end
end
-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------
-- тут уже твоя работа, установи цвета для плиток
function setColor(value)
	if value > 2048 then return {0, 0, 0, 1}
	elseif value == 2 then return {0.93, 0.91, 0.93, 1}
	elseif value == 4 then return {0.88, 0.72, 0.87, 1}
	elseif value == 8 then return {0.86, 0.52, 0.85, 1}
	elseif value == 16 then return {0.8, 0.32, 0.78, 1}
	elseif value == 32 then return {0.71, 0.28, 0.7, 1}
	elseif value == 64 then return {0.62, 0.12, 0.6, 1}
	elseif value == 128 then return {0.87, 0.15, 0.95, 1}
	elseif value == 256 then return {0.64, 0.02, 0.71, 1}
	elseif value == 512 then return {0.5, 0.14, 0.54, 1}
	elseif value == 1024 then return {0.32, 0.05, 0.31, 1}
	elseif value == 2048 then return {0.24, 0.05, 0.23, 1}
	end
end
-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------
function setColorText(value)
	if value > 2048 then return {1, 1, 1}
	else return {0, 0, 0} end
end
-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------

function Tile:new(field, x, y, value, size, parent)
	self.x, self.y = x, y -- положение плитки относительно экрана 
	self.size = size -- размер плитки высота и ширина
	self.concated = false -- соединенна ли плитка только что??
	self.value = value or setRandomValue() -- значение плитки ну типо степень двойки(2, 4, 8, 16)
	self.parent = parent

	self.field = field -- группа в которой это все рисуется
	self.defaultSize = size - size/28 -- размер шрифта по default'y

	self.completeAnimation = function() self.parent.hasAnimation = false end

	local backg = display.newRoundedRect(self.field, self.x, self.y, 0, 0, 30) -- плитка, типо ее задний фон
	backg:setFillColor(unpack(setColor(self.value))) -- устанавливаю цвет
	backg:setStrokeColor(unpack({0, 0, 0, 0.9})) -- окантовочку
	backg.strokeWidth = 0
	self.backg = backg -- хз, зачем это, но так надо

	local text = display.newText(self.field, tostring(self.value), self.x, self.y, native.systemFont,self.defaultSize - (#tostring(self.value) - 1) * self.size/5)  -- текст плитки, число внутри клетки
	text:setFillColor(0, 0, 0, 0) -- устанавливаю цвет, по default'y прозрачный, чтобы раньше задника не появлялся
	self.text = text -- тоже самое что и строка 51

	local clause1 = function () self.text:setFillColor(unpack(setColorText(self.value))); self.parent.hasAnimation = false end -- установка цвета для текста, чтобы он перестал быть прозрачным

	transition.to(self.backg, { -- анимация появления плитки
		time = 100, -- время анимации
		--fill = setColor(self.value),
		width = self.size - 4, --
		height = self.size - 4, -- изменение рамера
		strokeWidth = 4, -- окантовка
		onComplete = clause1 -- цвет для текста, строка 57
	})
	

	
end

-----------------------------------------------------------------
-- Функция соединения двух плиток
-----------------------------------------------------------------

function Tile:concat(other, dir, k) -- соединяет две плитки
	local val = self.value + other.value -- значение которое установится на плитке
	self.value = val -- изменение значения плитки
	self.concated = true -- устанавливаем, что он только что соединен, чтобы не было бага типо, когда он плитки 2 2 4  превращает в плитку 8
	self.parent.hasAnimation = true



	k = k - 0.5 -- короче, k это то насколько кубиков он передвинется, так как нам не нужно чтобы он полностью входил в другой мы уменьшаем это значение на половину
	if dir == "up" then other:moveUp(k) -- если кубик, соединяется с верхним, то делаем анимацию движения вверх
	elseif dir == "down" then other:moveDown(k) -- вниз
	elseif dir == "right" then other:moveRight(k) -- вправо
	elseif dir == "left" then other:moveLeft(k) end -- влево

	
	self.text.text = tostring(self.value) -- изменение значения плитки
	self.text.size = self.defaultSize - (#tostring(self.value) - 1) * self.size/5 -- установка размера значения плитки, если в нем будет больше знаков значит шрифт должен быть меньше
	self.text:setFillColor(unpack(setColorText(self.value))) -- установка цвета для текста
	self.backg:setFillColor(unpack(setColor(self.value))) -- установка цвета для задника плитки, строка 13
 	other:remove() 




	return val
end
-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------

-----------------------------------------------------------------
timeForMakeDinosaurHappy = 500 -- время за которое происходит движение плитки
-----------------------------------------------------------------

-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------
function Tile:remove() -- удаление клетки
	self.backg:removeSelf() -- удаляет задник
	self.text:removeSelf() -- удаляет текст
end

function Tile:moveUp(k) -- передвигает плитку на k клеток вверх с анимацией
	self.parent.hasAnimation = true
	transition.to(self.backg, {
		time = timeForMakeDinosaurHappy,
		y = self.backg.y - k * self.size,
		onComplete = self.completeAnimation
	})
	transition.to(self.text, {
		time = timeForMakeDinosaurHappy, 
		y = self.text.y - k * self.size,
		onComplete = self.completeAnimation
	})
end
function Tile:moveDown(k)-- передвигает плитку на k клеток вниз с анимацией
	self.parent.hasAnimation = true
	transition.to(self.backg, {
		time = timeForMakeDinosaurHappy,
		y = self.backg.y + k * self.size,
		onComplete = self.completeAnimation
	})
	transition.to(self.text, {
		time = timeForMakeDinosaurHappy, 
		y = self.text.y + k * self.size,
		onComplete = self.completeAnimation
	})
end
function Tile:moveRight(k) -- передвигает плитку на k клеток вправо с анимацией
	self.parent.hasAnimation = true
	transition.to(self.backg, {
		time = timeForMakeDinosaurHappy,
		x = self.backg.x + k * self.size,
		onComplete = self.completeAnimation
	})
	transition.to(self.text, {
		time = timeForMakeDinosaurHappy, 
		x = self.text.x + k * self.size,
		onComplete = self.completeAnimation
	})
end
function Tile:moveLeft(k) -- передвигает плитку на k клеток влево с анимацией
	self.parent.hasAnimation = true
	transition.to(self.backg, {
		time = timeForMakeDinosaurHappy,
		x = self.backg.x - k * self.size,
		onComplete = self.completeAnimation
	})
	transition.to(self.text, {
		time = timeForMakeDinosaurHappy, 
		x = self.text.x - k * self.size,
		onComplete = self.completeAnimation
	})
end

-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------


return Tile
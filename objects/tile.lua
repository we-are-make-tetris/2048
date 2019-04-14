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
-- все цвета для плиток, заданы картинками, в файле padoru
function setColor(value)
	local im = log2(value)
	print(im)
	if im < 12 then
		return {
			type = "image",
			sheet = gradientSheet,
			frame = gradientsOpts:getFrameIndex("coh" .. tostring(im))
		}
	elseif im < 26 then
		return{
			type = "image",
			sheet = padoruSheet,
			frame = im - 11
		}
	else
		return{
			0, 0, 0, 1
		}
	end

end
-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------
function setColorText(value)
	if value > 2048 then return {1, 1, 1, 0}
	else return {0, 0, 0, 1} end
end
-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------

function Tile:new(group, x, y, value, size, parent)
	self.x, self.y = x, y -- положение плитки относительно экрана 
	self.size = size -- размер плитки высота и ширина
	self.concated = false -- соединенна ли плитка только что??
	self.value = value or setRandomValue() -- значение плитки ну типо степень двойки(2, 4, 8, 16)
	self.parent = parent -- отцовское игровое поле


	self.group = group -- группа в которой это все рисуется
	self.defaultSize = size - size/28 -- размер шрифта по default'y

	self.completeAnimation = function() -- окончание анимации, пременная станет false когда закончится последняя анимация 
		if self.parent.animsInQueue == 1 then
			self.parent.hasAnimation = false
		end
		self.parent.animsInQueue = self.parent.animsInQueue - 1 
	end

	local backg = display.newRoundedRect(unpack({ -- задник, плитки
			--self.group, -- parent
			self.x, -- x
			self.y, -- y
			self.size-4, -- width
			self.size-4, -- height
			self.size/10, -- cornerRadius
		})) -- плитка, типо ее задний фон
	backg.fill = ((setColor(self.value)))
	backg.strokeWidth = 4
	backg:setStrokeColor(0, 0, 0, 1)

	self.backg = backg -- хз, зачем это, но так надо


	local text = display.newText(({
			self.group, -- parent
			text = tostring(self.value), -- text
			x = self.x, -- x
			y = self.y, -- y
			--width = self.size, -- width
			--height = self.size, -- height
			font = native.systemFont, -- font
			fontSize = self.defaultSize - (#tostring(self.value) - 1) * self.size/5, -- fontSize
			align = "center"
		}))  -- текст плитки, число внутри клетки
	text:setFillColor(unpack(setColorText(self.value)))
	self.text = text
	self.group:insert(self.backg)
	self.group:insert(self.text)
end

-----------------------------------------------------------------
-- Функция соединения двух плиток
-----------------------------------------------------------------

function Tile:concat(other) -- соединяет две плитки
	local val = self.value + other.value -- значение которое установится на плитке
	self.value = val -- изменение значения плитки
	self.concated = true -- устанавливаем, что он только что соединен, чтобы не было бага типо, когда он плитки 2 2 4  превращает в плитку 8
	self.parent.hasAnimation = true -- устанавливаем в игровом поле, что сейчас идет анимация
	self.parent.animsInQueue = self.parent.animsInQueue + 1 --увеличиваем количество анимаций в очереди
	
	local scaleAnim_part2 = function() -- окончание анимации и возвращение плитки в прежний размер
		transition.to(self.backg, {
			time = timeForMakeDinosaurHappy/2,
			width = self.size - 4,
			height= self.size - 4,
			onComplete = self.completeAnimation
		})
	end
	self.scaleAnim_part1 = function() -- эффект увелечения плитки
		self.text.text = tostring(self.value) -- установка значения
		self.text.size = self.defaultSize - (#tostring(self.value) - 1) * self.size/5 -- размера текста
		self.backg.fill = (setColor(self.value)) -- изменение задника
		self.text:setFillColor(unpack(setColorText(self.value)))
		transition.to(self.backg, { -- сама анимация увеличения
			time = timeForMakeDinosaurHappy/2,
			width = self.size + self.size/6,
			height= self.size + self.size/6,
			onComplete = scaleAnim_part2
		})
		other:remove() -- удаление присоединенной плитки
	end
	

	other:concatAnim(self) -- анимация движения к плитке
	return val
end
-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------

-----------------------------------------------------------------

timeForMakeDinosaurHappy = 50-- время анимаций

-----------------------------------------------------------------

-----------------------------------------------------------------
--Animations of MOVING
-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------
function Tile:remove() -- удаление клетки
	self.backg:removeSelf() -- удаляет задник
	self.text:removeSelf() -- удаляет текст
end


function Tile:concatAnim(other) -- анимация присоединения
	local tx, ty = other.x, other.y
	--просто плитка идет к другой, ничего интересного
	transition.to(self.backg, {
		time = timeForMakeDinosaurHappy,
		x = tx,
		y = ty,
	})
	transition.to(self.text,{
		time = timeForMakeDinosaurHappy,
		x = tx,
		y = ty,
		onComplete = other.scaleAnim_part1
	})
end

-- тут тоже особо ничего интерсеного, просто движение плиток на k плиток вниз или вверх или вправо или влево
function Tile:moveUp(k)
	self.parent.hasAnimation = true
	self.parent.animsInQueue = self.parent.animsInQueue + 1
	transition.to(self.backg,{
		time = timeForMakeDinosaurHappy,
		y = self.backg.y - k * self.size,
	})
	transition.to(self.text,{
		time = timeForMakeDinosaurHappy,
		y = self.text.y - k * self.size,
		onComplete = self.completeAnimation
	})

	self.x, self.y = self.x, self.y - k * self.size
end
function Tile:moveRight(k)
	self.parent.hasAnimation = true
	self.parent.animsInQueue = self.parent.animsInQueue + 1
	transition.to(self.backg,{
		time = timeForMakeDinosaurHappy,
		x = self.backg.x + k * self.size,
	})
	transition.to(self.text,{
		time = timeForMakeDinosaurHappy,
		x = self.text.x + k * self.size,
		onComplete = self.completeAnimation
	})

	self.x, self.y = self.x + k * self.size, self.y
end
function Tile:moveDown(k)
	self.parent.hasAnimation = true
	self.parent.animsInQueue = self.parent.animsInQueue + 1
	transition.to(self.backg,{
		time = timeForMakeDinosaurHappy,
		y = self.backg.y + k * self.size,
	})
	transition.to(self.text,{
		time = timeForMakeDinosaurHappy,
		y = self.text.y + k * self.size,
		onComplete = self.completeAnimation
	})

	self.x, self.y = self.x, self.y + k * self.size
end
function Tile:moveLeft(k)
	self.parent.hasAnimation = true
	self.parent.animsInQueue = self.parent.animsInQueue + 1
	transition.to(self.backg,{
		time = timeForMakeDinosaurHappy,
		x = self.backg.x - k * self.size,
	})
	transition.to(self.text,{
		time = timeForMakeDinosaurHappy,
		x = self.text.x - k * self.size,
		onComplete = self.completeAnimation
	})

	self.x, self.y = self.x - k * self.size, self.y
end

-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------

function log2(n)
	local k = 0
	while n > 1 do
		n = n/2
		k = k+1
	end
	return k
end


return Tile
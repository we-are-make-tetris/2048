local Field = Object:extend()
local tile = require('objects.tile')



function Field:new(size, group)	
	self.size = size -- размер, например 4*4; 5*5; 8*8
	self.tileSize = (display.contentWidth-20) / self.size -- размер плитки, подстраивается под ширину экрана
	self.width = self.tileSize * self.size --
	self.height= self.tileSize * self.size -- ширина и высота поля в пикселях
	self.group = group -- группа в которой все будет рисоваться
	
	self.hasAnimation = false -- происходит ли анимация на поле
	self.moved = true -- true если произошло хоть какое-то движение плиток, необходима для спавна новых плиток
	self.animsInQueue = 0 -- количество анимаций которые происходят в данный момент

	local field = {} -- матрица игрового поля
	
	for i = 1, size do
		table.insert(field, {})
	end 	
	self.field = field -- заполнил её чтобы она не удалилась

	self.totalScore = 0 -- общий счет игрока, обновляется при соединении двух плиток, если соединить две плитки по 2, то счет увеличится на 4

	self.leftCorner = { -- левый верхний угол поля
		x = display.contentCenterX - (self.tileSize/2 + (self.size/2) * self.tileSize),
		y = display.contentCenterY - (self.tileSize/2 + (self.size/2) * self.tileSize)
	}

	self.spawner = function() self:addNewTile() end -- ну просто спавнер

	local scoreText = display.newText({ -- Текст для счета
		parent = self.group,
		x = display.contentWidth / 1.9,
		y = display.contentHeight / 8,
		width = self.width,
		text = "Score: " .. tostring(self.totalScore),
		font = native.systemFont,
		fontSize = self.width/13,
		align = "left"
	})

	self.scoreText = scoreText

	timer.performWithDelay(50, self.spawner, -1) -- каждые 50 милисекунд он будет пытаться добавить на поле новую плитку
-----------------------------------------------------------------------------------------------------------------------------------------
	local borders = display.newRoundedRect(self.group, display.contentCenterX, display.contentCenterY, self.width-2, self.height-2, 30)
	borders.strokeWidth = 6
	borders:setFillColor(unpack({1, 1, 1}))
	borders:setStrokeColor(unpack({1, 1, 1, 1}))
	self.borders = borders
	-- визуальное игровое поле
-----------------------------------------------------------------------------------------------------------------------------------------
end
------------------------------------------------------------------
-- добавление новой плитки в поле
------------------------------------------------------------------
function Field:addNewTile(x, y, value)

	if not self.hasAnimation and self.moved and not GameOver then -- плитку можно спавнить только если 
		-- 1) Нет анимаций.
		-- 2) Произошло какое нибудь движение(плитка двинулась или соединилась с другой)
		-- 3) Игра не окончена
		local x, y = x or math.random(1, self.size), y or math.random(1, self.size) -- выбирает рандомное положение, если не задано
		local tmp = true -- переменная, чтобы не добавлять плитки, если для них нет места
		if self.field[x][y] then -- если в месте куда я хочу добавить плитку занято, то я перебираю другие клетки, и ищу свободную 
			tmp = false -- сразу же говорим, что сейчас мест нет
			for i = 1, self.size do
				for j = 1, self.size do
					if not self.field[i][j] then x, y = i, j;tmp = true; break end -- ищем места, если тут свободно, меняем х, у, и tmp
				end
			end
		end
	 	-- добавляю плитку, в матрицу
		if tmp then self.field[x][y] = tile(
			self.group, -- группа родитель
			self.leftCorner.x + self.tileSize * x, -- положение по Х
			self.leftCorner.y + self.tileSize * y, -- положение по У
			value or nil, -- начальное значение плитки
			self.tileSize, -- размер плитки
			self -- поле, в котором появится плитка
			) end

		self.moved = false -- чтобы заспавнить следующую нужно сделать движение плиток
		-- проверка, на game over

		GameOver = self:gameOverCheck()
		if GameOver then print("game over") end
	end
end
------------------------------------------------------------------
------------------------------------------------------------------
------------------------------------------------------------------
-- проверка Game Over'a
------------------------------------------------------------------
------------------------------------------------------------------
------------------------------------------------------------------
function Field:gameOverCheck()
	local verdict =  true -- вердикт, игра окнчена или нет

	-- перебор, всех плиток в матрице
	for i = 1, self.size do
		for j = 1, self.size do
			if self.field[i][j] then 
				if i > 1 and (not self.field[i - 1][j] or self.field[i][j].value == self.field[i-1][j].value) then -- можно ли двинутся влево
					verdict = verdict and false -- если да, то, значит что игра точно продолжится
				else
					verdict = verdict and true -- если нет то, возможно она закочилась
				end
				if i < self.size - 1 and (not self.field[i + 1][j] or self.field[i][j].value == self.field[i+1][j].value) then -- можно ли двинутся вправо
					verdict = verdict and false -- тоже самое
				else
					verdict = verdict and true
				end

				if j > 1 and (not self.field[i][j - 1] or self.field[i][j].value == self.field[i][j - 1].value) then -- вверх
					verdict = verdict and false
				else
					verdict = verdict and true
				end

				if j < self.size - 1 and (not self.field[i][j + 1] or self.field[i][j].value == self.field[i][j + 1].value) then-- вниз
					verdict = verdict and false
				else
					verdict = verdict and true
				end
			else
				return false -- если есть пустая ячейка, то значит игра продолжается
			end
		end
	end
	return verdict -- возвращает вердикт
end
------------------------------------------------------------------
------------------------------------------------------------------
------------------------------------------------------------------

-- ДВИЖЕНИЕ ПЛИТОК
------------------------------------------------------------------
------------------------------------------------------------------
------------------------------------------------------------------

-- Я настоятельно рекомендую сюда не лезть, но если ты хочешь, то удачи тебе и терпения
function Field:swapUp()
	for i = 1, self.size do
		local cons = {} -- список свеже соединенных плиток
		for j = 1, self.size do
			if self.field[i][j] then -- есть ли в этой координате плитка?
				local x = j -- вспомогательная переменная
				for k = j - 1, 1, -1 do -- ищем первую преграду сверху, ввиде другой плитки
					if self.field[i][k] then x = k; break
					end
				end

				if x == j then -- если сверху не преград
					if j == 1 then -- елси он и так сверху, то делать ничего не надо
					else -- иначе двигаем её до конца вверх
						self.field[i][j]:moveUp(j - 1)
						self.field[i][1], self.field[i][j] = self.field[i][j], nil -- я не могу объяснить зачем это надо, но оно надо, поверь
						self.moved = true -- движение произошло
					end
				elseif self.field[i][j].value == self.field[i][x].value and not self.field[i][j].concated and not self.field[i][x].concated then
					-- если есть преграда, и её значение равно занчению этой и ещё ни одна из них не свежесоединенная, то соединяем к верхней нынешнюю 
					local sc = self.field[i][x]:concat(self.field[i][j])
					self.totalScore = self.totalScore + sc
					-- изменяем нынешний счет
					self.field[i][j] = nil
					--удаляем плитку
					table.insert(cons, self.field[i][x]) -- добавляем в список соединенных плиток
					self.moved = true -- движение произошло
				elseif x + 1 ~= j then -- при любых других обстоятельствах подовигаем нынешнюю плитку вплотную к верхней
					self.field[i][j]:moveUp(j - x - 1)
					self.field[i][x+1], self.field[i][j] = self.field[i][j], self.field[i][x+1] -- забей
					self.moved = true -- движение произошло
				end
			end
		end
		for _,v in ipairs(cons) do
			v.concated = false -- востанавливаем значения соединенности плиток
		end
	end
	self.scoreText.text = "Score: " .. self.totalScore -- измение общего счета
	ACCEPTION = true -- теперь когда все закончили можно делать следующие свайпы
end
------------------------------------------------------------------
-- дальше все тоже самое
function Field:swapRight()
	for j = 1, self.size do
		local cons = {}
		for i = self.size, 1, -1 do
			local x
			if self.field[i][j] then
				x = i
				for k = i + 1, self.size do
					if self.field[k][j] then x = k; break end
				end

				if x == i then
					if x == self.size then  
					else
						self.field[i][j]:moveRight(self.size - i)
						self.field[self.size][j], self.field[i][j] = self.field[i][j], nil 
						self.moved = true
					end
				elseif self.field[i][j].value == self.field[x][j].value and not self.field[i][j].concated and not self.field[x][j].concated then
					local sc = self.field[x][j]:concat(self.field[i][j])
					self.totalScore = self.totalScore + sc
					table.insert(cons, self.field[x][j])
					self.field[i][j] = nil
					self.moved = true
				elseif x - 1 ~= i then
					self.field[i][j]:moveRight(x - i - 1)
					self.field[x-1][j], self.field[i][j] = self.field[i][j], self.field[x-1][j]
					self.moved = true
				end
			end
		end
		for _,v in pairs(cons) do
			v.concated = false
		end
	end
	self.scoreText.text = "Score: " .. self.totalScore
	ACCEPTION = true
end

------------------------------------------------------------------
------------------------------------------------------------------
-- дальше все делается также

function Field:swapDown()
	for i = 1, self.size do
		local cons = {}
		for j = self.size, 1, -1 do
			if self.field[i][j] then
				local x = j
				for k = j + 1, self.size do
					if self.field[i][k] then x = k; break
					end
				end

				if x == j then
					if j == self.size then 
					else
						self.field[i][j]:moveDown(self.size - j)
						self.field[i][self.size], self.field[i][j] = self.field[i][j], nil
						self.moved = true
					end
				elseif self.field[i][j].value == self.field[i][x].value and not self.field[i][j].concated and not self.field[i][x].concated then
					local sc = self.field[i][x]:concat(self.field[i][j])
					self.totalScore = self.totalScore + sc
					self.field[i][j] = nil
					table.insert(cons, self.field[i][x])
					self.moved = true
				elseif x - 1 ~= j then
					self.field[i][j]:moveDown(x - j - 1)
					self.field[i][x-1], self.field[i][j] = self.field[i][j], self.field[i][x-1]
					self.moved = true
				end
			end
		end
		for _,v in ipairs(cons) do
			v.concated = false
		end
	end
	self.scoreText.text = "Score: " .. self.totalScore -- измение общего счета
	ACCEPTION = true
end
------------------------------------------------------------------
function Field:swapLeft()
	for j = 1, self.size do
		local cons = {}
		for i = 1, self.size do
			local x
			if self.field[i][j] then
				x = i
				for k = i - 1, 1, -1 do
					if self.field[k][j] then x = k; break end
				end

				if x == i then
					if x == 1 then  
					else
						self.field[i][j]:moveLeft(i - 1)
						self.field[1][j], self.field[i][j] = self.field[i][j], nil 
						self.moved = true
					end
				elseif self.field[i][j].value == self.field[x][j].value and not self.field[i][j].concated and not self.field[x][j].concated then
					local sc = self.field[x][j]:concat(self.field[i][j])
					self.totalScore = self.totalScore + sc
					table.insert(cons, self.field[x][j])
					self.field[i][j] = nil
					self.moved = true
				elseif x + 1 ~= i then
					self.field[i][j]:moveLeft(i - x - 1)
					self.field[x+1][j], self.field[i][j] = self.field[i][j], self.field[x+1][j]
					self.moved = true
				end
			end
		end
		for _,v in pairs(cons) do
			v.concated = false
		end
	end
	self.scoreText.text = "Score: " .. self.totalScore
	ACCEPTION = true
end




--1%--------------------------------------------------------------------------
-------------12%--------------------------------------------------------------
---------------------34%------------------------------------------------------ -- это типо слои защиты, лол
------------------------------------46%---------------------------------------
----------------------------------------------------66%----------------------- -- это реально опасная зона
-------------------------------------------------------------99,9%------------
--------------------------------???%------------------------------------------
-------------------------------WARNING----------------------------------------

function Field:remove()
	for i = 1, self.size do
		for j = 1, self.size do
			if self.field[i][j] then
				self.field[i][j]:remove()
			end
		end
	end
end

----------------------------DANGEROUS ZONE------------------------------------
------------------------------->999%------------------------------------------
------------------------------->100%------------------------------------------
-------------------------------<1%--------------------------------------------
-------------------------------1/inf------------------------------------------
------------------------------------------------------------------------------
-- копирование и востановление предыдущей копии
function Field:copyField()
	LAST_Field_Copy = {
		score = self.totalScore,
		field = copy(self.field),
	}
end


function Field:applyCopy()
	self:remove()
	self.totalScore = LAST_Field_Copy.score
	self.field = copy(LAST_Field_Copy.field)
	for i = 1, #self.field do
		for j = 1, #self.field[i] do
			self:addNewTile(i, j, self.field[i][j].value)
			self.moved = true
		end
	end
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------



return Field
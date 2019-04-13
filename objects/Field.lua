local Field = Object:extend()
local tile = require('objects.tile')

_G.GameOver = false -- глобальная переменная, если она true, то игрок больше не может двигаться, иначе может

function Field:new(size, group)	
	self.size = size -- размер, например 4*4; 5*5; 8*8
	self.tileSize = (display.contentWidth-20) / self.size -- размер плитки подстраивается под ширину экрана
	self.width = self.tileSize * self.size 
	self.height= self.tileSize * self.size -- ширина и высота поля в пикселях

	self.hasAnimation = false

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
	self.group = group -- группа в которой все будет рисоваться

	local scoreText = display.newText({ -- Текст для счета
		x = display.contentWidth / 6,
		y = display.contentHeight / 8,
		text = "Score: " .. tostring(self.totalScore),
		font = native.systemFont,
		fontSize = self.width/13
	})

	self.scoreText = scoreText
-----------------------------------------------------------------------------------------------------------------------------------------
	local borders = display.newRoundedRect(self.group, display.contentCenterX, display.contentCenterY, self.width-2, self.height-2, 30)
	borders.strokeWidth = 6
	borders:setFillColor(unpack({1, 1, 1}))
	borders:setStrokeColor(unpack({1, 1, 1, 1}))
	-- визуальное игровое поле
-----------------------------------------------------------------------------------------------------------------------------------------
end
------------------------------------------------------------------
-- добавление новой плитки в поле
------------------------------------------------------------------
function Field:addNewTile(x, y, value)
	self.hasAnimation = true
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
	if tmp then self.field[x][y] = tile(self.group, self.leftCorner.x + self.tileSize * x, self.leftCorner.y + self.tileSize * y, value or nil, self.tileSize, self) end
	-- проверка, на game over
	GameOver = self:gameOverCheck()
	if GameOver then print("game over") end
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
function Field:swapUp()
	local chges = false -- переменная, которая проверяет изменилось ли положение, хоть одной плитки
	local x -- вспомогательная перменная
	if self.hasAnimation then return 0 end
	for i = 1, self.size do
		local cons = {} -- все соединённые плитки, нужно для того чтобы потом изменить их concated
		for j = 1, self.size do
			if self.field[i][j] then -- если здесь есть плитка, проверяем можно ли её двинуть
				x = j
				for k = j - 1, 1, -1 do
					if self.field[i][k] then x = k; break end -- находим, ближайшую прeграду, в виде другой плитки
				end

				if x==j then -- если впереди нету никаких плиток
					if j == 1 then --если впереди вообще ничего нету, тоесть плитка стоит на краю, то делать ничего не надо
					else -- иначе, мы подвинем ее в край
						
						self.field[i][j]:moveUp(j - 1) -- анимация движения плитки на j-1 клетку
						self.field[i][1], self.field[i][j] = self.field[i][j], self.field[i][1]
						-- меняем значение self.field[i][1] на self.field[i][j], а self.field[i][j] на nil 
						
						chges = true -- изменения произошли
					end
				elseif self.field[i][j].value ~= self.field[i][x].value and x + 1 ~= j then -- если впереди есть плитка, с другим значением, и при этом она не стоит вплотную
					
					self.field[i][j]:moveUp(j - x - 1) -- двигаем плитку к другой с анимацией 
					self.field[i][x+1], self.field[i][j] = self.field[i][j], self.field[i][x+1]
					-- меняем значение self.field[i][х] на self.field[i][j], а self.field[i][j] на nil
					
					chges = true -- изменения произошли
				elseif self.field[i][j].value == self.field[i][x].value and not self.field[i][j].concated and not self.field[i][x].concated then
					-- если значение следующей плитки равно значению этой, и при этом ни одна из них еще не была соединена
					
					local sc = self.field[i][x]:concat(self.field[i][j], "up", j - x) -- присоединяем к следующей плитке, эту с анимцией, см. в tile.lua
					self.totalScore = self.totalScore + sc -- измениение счёта
					table.insert(cons, self.field[i][x]) -- добавим эту плитку, к списку соединённых
					self.field[i][j] = nil -- удаляем, присоединившуюся
					chges = true -- изменения произошли
				elseif self.field[i][j].value == self.field[i][x].value and (self.field[i][j].concated or self.field[i][x].concated) then
					-- если значение следующей плитки равно значению этой, но при этом одна или обе из них были соединены
					-- делается все тоже что и в условии в строке 134
					
					self.field[i][j]:moveUp(j - x - 1) 
					self.field[i][x+1], self.field[i][j] = self.field[i][j], self.field[i][x+1]
					
					chges = true
				end
			end			
		end
		for _,v in pairs(cons) do
			v.concated = false -- убираем у присоединенных, условие, что они присоединные
			-- ну, короче это нужно делать здесь (я не знаю почему)
		end	
	end
	if chges and not self.hasAnimation then self:addNewTile() end -- если произошли изменения то нужно создать новую плитку
	self.scoreText.text = "Score: " .. self.totalScore -- измение общего счета
end
------------------------------------------------------------------
------------------------------------------------------------------
------------------------------------------------------------------
-- дальше все делается также

function Field:swapDown( ... )
	local chges = false
	local x
	if self.hasAnimation then return 0 end
	for i = 1, self.size do
		local cons = {}
		for j = self.size, 1, -1 do
			if self.field[i][j] then
				x = j
				for k = j + 1, self.size do
					if self.field[i][k] then
						x = k
						break
					end
				end

				if x == j then
					if j == self.size then
					else 
						self.field[i][j]:moveDown(self.size - j)
						self.field[i][self.size], self.field[i][j] = self.field[i][j], self.field[i][self.size]
						
						chges = true
					end

				elseif self.field[i][j].value ~= self.field[i][x].value and x - 1 ~= j then
					self.field[i][j]:moveDown(x - j - 1)
					self.field[i][x-1], self.field[i][j] = self.field[i][j], self.field[i][x-1]
						
					chges = true

				elseif self.field[i][j].value == self.field[i][x].value and not self.field[i][j].concated and not self.field[i][x].concated then
					local sc = self.field[i][x]:concat(self.field[i][j], "down", x - j)
					self.totalScore = self.totalScore + sc
					table.insert(cons, self.field[i][x])
					self.field[i][j] = nil
					chges = true
				elseif self.field[i][j].value == self.field[i][x].value and (self.field[i][j].concated or self.field[i][x].concated) then
					self.field[i][j]:moveDown(x - j - 1)
					self.field[i][x-1], self.field[i][j] = self.field[i][j], self.field[i][x-1]
						
					chges = true
				end
			end	
		end		
		for _,v in pairs(cons) do
			v.concated = false
		end	
	end
	if chges then self:addNewTile() end
	self.scoreText.text = "Score: " .. self.totalScore
end
function Field:swapRight( ... )
	local chges = false
	local x
	if self.hasAnimation then return 0 end
	for j = 1, self.size do
		local cons = {}
		for i = self.size, 1, -1 do
			if self.field[i][j] then
				x = i
				for k = i + 1, self.size do
					if self.field[k][j] then x = k; break end
				end

				if x == i then
					if x == self.size then  
					else
						self.field[i][j]:moveRight(self.size - i)
						self.field[self.size][j], self.field[i][j] = self.field[i][j], self.field[self.size][j] 
						  
						chges = true
					end
				elseif self.field[i][j].value ~= self.field[x][j].value and x - 1 ~= i then
					self.field[i][j]:moveRight(x - i - 1)
					self.field[x-1][j], self.field[i][j] = self.field[i][j], self.field[x-1][j]
						  
					chges = true
				elseif self.field[i][j].value == self.field[x][j].value and not self.field[i][j].concated and not self.field[x][j].concated then
					local sc = self.field[x][j]:concat(self.field[i][j], "right", x - i)
					self.totalScore = self.totalScore + sc
					table.insert(cons, self.field[x][j])
					self.field[i][j] = nil
					chges = true
				elseif self.field[i][j].value == self.field[x][j].value and (self.field[i][j].concated or self.field[x][j].concated) then
					self.field[i][j]:moveRight(x - i - 1)
					self.field[x-1][j], self.field[i][j] = self.field[i][j], self.field[x-1][j]
						 
					chges = true
				end
			end
		end
		for _,v in pairs(cons) do
			v.concated = false
		end
	end
	if chges then self:addNewTile() end
	self.scoreText.text = "Score: " .. self.totalScore
end
function Field:swapLeft( ... )
	local chges = false
	local x
	if self.hasAnimation then return 0 end
	for j = 1, self.size do
		local cons = {}
		for i = 1, self.size do
			if self.field[i][j] then
				x = i
				for k = i - 1, 1, -1 do
					if self.field[k][j] then
						x = k
						break
					end
				end
				if x == i then
					if x == 1 then 
					else
						self.field[i][j]:moveLeft(i - 1)
						self.field[1][j], self.field[i][j] = self.field[i][j], self.field[1][j] 
						
						chges = true
					end
				elseif self.field[i][j].value ~= self.field[x][j].value and x + 1 ~= i then
					self.field[i][j]:moveLeft(i - x - 1)
					self.field[x+1][j], self.field[i][j] = self.field[i][j], self.field[x+1][j]
						  
					chges = true
				elseif self.field[i][j].value == self.field[x][j].value and not self.field[i][j].concated and not self.field[x][j].concated then
					local sc = self.field[x][j]:concat(self.field[i][j], "left", i - x)
					self.totalScore = self.totalScore + sc
					table.insert(cons, self.field[x][j])
					self.field[i][j] = nil
					chges = true
				elseif self.field[i][j].value == self.field[x][j].value and (self.field[i][j].concated or self.field[x][j].concated) then
					self.field[i][j]:moveLeft(i - x - 1)
					self.field[x+1][j], self.field[i][j] = self.field[i][j], self.field[x+1][j]
						
					chges = true
				end
			end
		end
		for _,v in pairs(cons) do
			v.concated = false
		end	
	end
	if chges then self:addNewTile() end
	self.scoreText.text = "Score: " .. self.totalScore
end

return Field
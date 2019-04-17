local Field = Object:extend()
local tile = require('objects.tile')

local function log2(n)
	local k = 0
	while n > 1 do
		n = n/2
		k = k+1
	end
	return k
end

function getRandomValue()
	local tmp = math.random(100)
	if tmp <= maxChance then
		return maxTile
	else
		return minTile
	end
end

local left_corner

function Field:new(size, group)	
	self.size = size -- размер поля 4*4, 5*5
	self.group = group --группа в которой будут рисоваться плитки

	local width = display.actualContentWidth-20

	self.tileSize = width/size

	left_corner = {
		x = display.contentCenterX - (display.actualContentWidth-20)/2 + self.tileSize/2,
		y = display.contentCenterY - (display.actualContentWidth-20)/2 + self.tileSize/2,
	}
	local field = {}
	for i = 1, self.size do
		table.insert(field, {})
	end
	self.matrix = field -- матрица, со значениями
	local field2 = {}
	for i = 1, self.size do
		table.insert(field2, {})
	end
	self.tileMatrix  = field2 -- матрица, с плитками она не должна много весить там всего лишь три переменные и две функции.

	
	self.totalScore = 0
	----------------------------------------------
	-- визуальная часть поля
	local borders = display.newRoundedRect(
		self.group,
		display.contentCenterX,
		display.contentCenterY,
		width + 4,
		width + 4,
		self.tileSize/8
	)
	borders.strokeWidth = 8
	borders:setStrokeColor(0, 0, 1, 1)
	borders:setFillColor(1, 1, 0, 1)
	self.borders = borders
	-----------------------------------------------
end
------------------------------------------------------------------

function Field:setField(mat, scor)
	self.matrix = mat
	self.totalScore = scor

	for i = 1, self.size do
		for j = 1, self.size do
			if self.matrix[i][j] and self.matrix[i][j] < minTile then
				self.matrix[i][j] = getRandomValue()
			end

			if self.matrix[i][j] then
				self:addNewTile(i, j, self.matrix[i][j])
			end
		end
	end
end

------------------------------------------------------------------
-- добавление новой плитки в поле
------------------------------------------------------------------
function Field:addNewTile(x, y, value)
	x, y = x or math.random(self.size), y or math.random(self.size)
	
	local tmp = true -- проверка наличия свободных мест

	if self.tileMatrix[x][y] then
		tmp = false
		for i = 1, self.size do
			for j = 1, self.size do
				if not self.tileMatrix[i][j] then x, y = i, j; tmp = true; break end
			end
		end
	end
	if tmp then
		self.matrix[x][y] = value or getRandomValue()

		self.tileMatrix[x][y] = tile(
			self.group,
			left_corner.x + (x-1) * self.tileSize,
			left_corner.y + (y-1) * self.tileSize,
			self.matrix[x][y],
			self.tileSize
		)
		GameOver = self:gameOverCheck()
		if GameOver then gameOverEvent() end
		switchText(self.totalScore)
	end
end
------------------------------------------------------------------
------------------------------------------------------------------
------------------------------------------------------------------
-- проверка Game Over'a
function Field:gameOverCheck()
	local verdict =  true -- вердикт, игра окнчена или нет

	-- перебор, всех плиток в матрице
	for i = 1, self.size do
		for j = 1, self.size do
			if self.matrix[i][j] then 
				if i > 1 and (not self.matrix[i - 1][j] or self.matrix[i][j] == self.matrix[i-1][j]) then -- можно ли двинутся влево
					verdict = verdict and false -- если да, то, значит что игра точно продолжится
				else
					verdict = verdict and true -- если нет то, возможно она закочилась
				end
				if i < self.size - 1 and (not self.matrix[i + 1][j] or self.matrix[i][j] == self.matrix[i+1][j]) then -- можно ли двинутся вправо
					verdict = verdict and false -- тоже самое
				else
					verdict = verdict and true
				end

				if j > 1 and (not self.matrix[i][j - 1] or self.matrix[i][j] == self.matrix[i][j - 1]) then -- вверх
					verdict = verdict and false
				else
					verdict = verdict and true
				end

				if j < self.size - 1 and (not self.matrix[i][j + 1] or self.matrix[i][j] == self.matrix[i][j + 1]) then-- вниз
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
tfmdh = 100 -- TimeForMakeDinosuarHappy
------------------------------------------------------------------
------------------------------------------------------------------
------------------------------------------------------------------

local function getCoordinates(x, y, size)
	return {
		x = left_corner.x + (x-1) * size,
		y = left_corner.y + (y-1) * size
	}
end

-- ДВИЖЕНИЕ ПЛИТОК
local function moveTo(trans, target, onComp) 
	onComp = onComp or nil
	numOfAnims = numOfAnims + 1
	transition.to(trans.backg, {
		time = tfmdh,
		x = target.x,
		y = target.y,
		onComplete = completedAnim
	})
	transition.to(trans.text, {
		time = tfmdh,
		x = target.x,
		y = target.y,
		onComplete = onComp
	})
	trans.x, trans.y = target.x, target.y
end
local function concat(trans, target)
	local size = target.size
	local p2 = function ()
		transition.to(target.backg,{
			time = tfmdh/4,
			width = size,
			height = size,
		})
	end
	local f = function()
		target:setValue(trans.value + target.value)
		transition.to(target.backg,{
			time = tfmdh/4,
			width = size + size/10,
			height = size + size/10,
			onComplete = p2
		})
		trans:remove()
	end
	moveTo(trans, target, f)
	local im = log2(target.value) - 11
	if im > 0 then achievements[im] = true end
end
------------------------------------------------------------------
function Field:removeAll( )
	for i = 1, self.size do
		for j = 1, self.size do
			if self.tileMatrix[i][j] then
				self.tileMatrix[i][j]:remove()
			end
		end
	end
end
------------------------------------------------------------------
------------------------------------------------------------------

local f = function() ACCEPTION = true end

function Field:swapUp()
	local ch = true
	for i = 1, self.size do
		local cons = {}
		for j = 1, self.size do 
			if self.matrix[i][j] then
				local t = j
				for k = j-1, 1, -1 do
					if self.tileMatrix[i][k] then
						t = k; break 
					end
				end
				if t == j then
					if t == 1 then 
					else
						moveTo(self.tileMatrix[i][j], getCoordinates(i, 1, self.tileSize))
						self.matrix[i][1], self.matrix[i][j] = self.matrix[i][j], nil
						self.tileMatrix[i][1], self.tileMatrix[i][j] = self.tileMatrix[i][j], nil
						ch = false
					end
				elseif self.matrix[i][j] == self.matrix[i][t] and not cons[t] then
					concat(self.tileMatrix[i][j], self.tileMatrix[i][t])
					cons[t] = true
					self.matrix[i][t] = self.matrix[i][t] * 2
					self.totalScore = self.totalScore + self.matrix[i][t]
					self.tileMatrix[i][j], self.matrix[i][j] = nil, nil
					ch = false
				elseif j ~= t+1 then
					moveTo(self.tileMatrix[i][j], getCoordinates(i, t+1, self.tileSize))
					self.matrix[i][t+1], self.matrix[i][j] = self.matrix[i][j], self.matrix[i][t+1]
					self.tileMatrix[i][t+1], self.tileMatrix[i][j] = self.tileMatrix[i][j], self.tileMatrix[i][t+1]
					ch = false
				end
			end
		end
	end
	if ch then ACCEPTION = true end
end

function Field:swapDown()
	local ch = true
	for i = 1, self.size do
		local cons = {}
		for j = self.size, 1, -1 do 
			if self.matrix[i][j] then
				local t = j
				for k = j+1, self.size do
					if self.tileMatrix[i][k] then
						t = k; break 
					end
				end

				if t == j then
					if t == self.size then 
					else
						moveTo(self.tileMatrix[i][j], getCoordinates(i, self.size, self.tileSize))
						self.matrix[i][self.size], self.matrix[i][j] = self.matrix[i][j], nil
						self.tileMatrix[i][self.size], self.tileMatrix[i][j] = self.tileMatrix[i][j], nil
					ch = false
					end
				elseif self.matrix[i][j] == self.matrix[i][t] and not cons[t] then
					concat(self.tileMatrix[i][j], self.tileMatrix[i][t])
					cons[t] = true
					self.matrix[i][t] = self.matrix[i][t] * 2
					self.totalScore = self.totalScore + self.matrix[i][t]
					self.tileMatrix[i][j], self.matrix[i][j] = nil, nil
					ch = false
				elseif j ~= t-1 then
					moveTo(self.tileMatrix[i][j], getCoordinates(i, t-1, self.tileSize))
					self.matrix[i][t-1], self.matrix[i][j] = self.matrix[i][j], self.matrix[i][t-1]
					self.tileMatrix[i][t-1], self.tileMatrix[i][j] = self.tileMatrix[i][j], self.tileMatrix[i][t-1]
					ch = false
				end
			end
		end
	end
	if ch then ACCEPTION = true end
end

function Field:swapRight()
	local ch = true
	for j = 1, self.size do
		local cons = {}
		for i = self.size, 1, -1 do 
			if self.matrix[i][j] then
				local t = i
				for k = i+1, self.size do
					if self.tileMatrix[k][j] then
						t = k; break 
					end
				end

				if t == i then
					if t == self.size then 
					else
						moveTo(self.tileMatrix[i][j], getCoordinates(self.size, j, self.tileSize))
						self.matrix[self.size][j], self.matrix[i][j] = self.matrix[i][j], nil
						self.tileMatrix[self.size][j], self.tileMatrix[i][j] = self.tileMatrix[i][j], nil
					ch = false
					end
				elseif self.matrix[i][j] == self.matrix[t][j] and not cons[t] then
					concat(self.tileMatrix[i][j], self.tileMatrix[t][j])
					cons[t] = true
					self.matrix[t][j] = self.matrix[t][j] * 2
					self.totalScore = self.totalScore + self.matrix[t][j]
					self.tileMatrix[i][j], self.matrix[i][j] = nil, nil
					ch = false
				elseif i ~= t-1 then
					moveTo(self.tileMatrix[i][j], getCoordinates(t - 1, j, self.tileSize))
					self.matrix[t-1][j], self.matrix[i][j] = self.matrix[i][j], self.matrix[t-1][j]
					self.tileMatrix[t-1][j], self.tileMatrix[i][j] = self.tileMatrix[i][j], self.tileMatrix[t-1][j]
					ch = false
				end
			end
		end
	end
	if ch then ACCEPTION = true end
end
function Field:swapLeft()
	local ch = true
	for j = 1, self.size do
		local cons = {}
		for i = 1, self.size do 
			if self.matrix[i][j] then
				local t = i
				for k = i-1, 1, -1 do
					if self.tileMatrix[k][j] then
						t = k; break 
					end
				end

				if t == i then
					if t == 1 then 
					else
						moveTo(self.tileMatrix[i][j], getCoordinates(1, j, self.tileSize))
						self.matrix[1][j], self.matrix[i][j] = self.matrix[i][j], nil
						self.tileMatrix[1][j], self.tileMatrix[i][j] = self.tileMatrix[i][j], nil
					ch = false
					end
				elseif self.matrix[i][j] == self.matrix[t][j] and not cons[t] then
					concat(self.tileMatrix[i][j], self.tileMatrix[t][j])
					cons[t] = true
					self.matrix[t][j] = self.matrix[t][j] * 2
					self.totalScore = self.totalScore + self.matrix[t][j]
					self.tileMatrix[i][j], self.matrix[i][j] = nil, nil
					ch = false
				elseif i ~= t+1 then
					moveTo(self.tileMatrix[i][j], getCoordinates(t + 1, j, self.tileSize))
					self.matrix[t+1][j], self.matrix[i][j] = self.matrix[i][j], self.matrix[t+1][j]
					self.tileMatrix[t+1][j], self.tileMatrix[i][j] = self.tileMatrix[i][j], self.tileMatrix[t+1][j]
					ch = false
				end
			end
		end
	end
	if ch then ACCEPTION = true end
end



return Field
local Tile = Object:extend()
-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------
local function log2(n)
	local k = 0
	while n > 1 do
		n = n/2
		k = k+1
	end
	return k
end

-- все цвета для плиток, заданы картинками, в файле padoru
function setColor(value)
	local im = log2(value)
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

function Tile:new(group, x, y, value, size)
	self.x, self.y = x, y -- положение плитки относительно экрана 
	self.value = value
	self.size = size
	
	local backg = display.newRoundedRect(
		group,
		self.x, self.y,
		0, 0,
		size/8 
	)
	backg.fill = setColor(self.value)
	self.backg = backg

	transition.to(self.backg,{
		time = tfmdh/2,
		width = size,
		height = size,
	})

	local text = display.newText({
		parent = group,
		x = self.x, y = self.y,
		text = tostring(self.value),
		font = native.systemFont,
		fontSize = self.size - #tostring(self.value) * 20
	})
	text.fill = setColorText(self.value)
	self.text = text
end

function Tile:setValue(val)
	self.value = val
	self.backg.fill = setColor(self.value)
	self.text.text = tostring(self.value)
	self.text.fill = setColorText(self.value)
	self.text.size = self.size - #tostring(self.value) * 20
end

-----------------------------------------------------------------
--Animations of MOVING
-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------
function Tile:remove() -- удаление плитки
	self.backg:removeSelf() -- удаляет задник
	self.text:removeSelf() -- удаляет текст
end

-- тут тоже особо ничего интерсеного, просто движение плиток на k плиток вниз или вверх или вправо или влево


-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------

return Tile
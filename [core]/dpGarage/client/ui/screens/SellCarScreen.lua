SellCarScreen = Screen:subclass "SellCarScreen"
local screenSize = Vector2(guiGetScreenSize())

function SellCarScreen:init(callback)
	self.super:init()
	self.fadeSpeed = 4
	self.canSell = true
	self.text = exports.dpLang:getString("garage_sell_text")
	self.confirm = exports.dpLang:getString("garage_sell_confirm")

	if GarageCar.getCarsCount() <= 1 then
		self.canSell = false
		self.text = exports.dpLang:getString("garage_sell_last_car")
		self.confirm = utf8.fold(exports.dpLang:getString("garage_menu_back"))
	end
	local _, vehiclePrice = exports.dpShared:getVehiclePrices(GarageCar.getName())
	if type(vehiclePrice) ~= "number" then
		vehiclePrice = 0
	end
	self.price = math.floor(vehiclePrice * exports.dpShared:getEconomicsProperty("vehicle_sell_price"))
	self.colorHex = exports.dpUtils:RGBToHex(exports.dpUI:getThemeColor())
end

function SellCarScreen:show()
	self.super:show()
	GarageUI.setHelpText("")
end

function SellCarScreen:hide()
	self.super:hide()
	GarageUI.resetHelpText()
end

function SellCarScreen:draw()
	self.super:draw()
	dxDrawRectangle(0, 0, screenSize.x, screenSize.y, tocolor(0, 0, 0, 150 * self.fadeProgress))
	local text = ""
	if self.canSell then
		text = self.text .. " " .. self.colorHex .. "$" .. tostring(self.price) .. "#FFFFFF?"
	else
		text = self.text
	end
	dxDrawText(
		text, 
		0, 0, 
		screenSize.x, screenSize.y * 0.5, 
		tocolor(255, 255, 255, 255 * self.fadeProgress), 
		1, 
		Assets.fonts.componentName,
		"center",
		"bottom",
		false, false, false, true
	)

	local confirmText = ""
	if self.canSell  then 
		confirmText = self.colorHex .. "ENTER #FFFFFF- " .. self.confirm
	else
		confirmText = self.colorHex .. "Backspace #FFFFFF- " .. self.confirm
	end
	dxDrawText(
		confirmText, 
		0, screenSize.y * 0.51, 
		screenSize.x, screenSize.y, 
		tocolor(255, 255, 255, 255 * self.fadeProgress), 
		1, 
		Assets.fonts.moneyText,
		"center",
		"top",
		false, false, false, true
	)	
end

function SellCarScreen:update(deltaTime)
	self.super:update(deltaTime)
end

function SellCarScreen:onKey(key)
	self.super:onKey(key)
	if key == "enter" then
		if not self.canSell then
			return
		end
		GarageCar.sell()
		self.screenManager:showScreen(MainScreen(2))		
	elseif key == "backspace" then
		self.screenManager:showScreen(MainScreen(2))
	end
end
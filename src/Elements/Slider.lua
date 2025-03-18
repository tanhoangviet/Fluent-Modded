local UserInputService = game:GetService("UserInputService")
local Root = script.Parent.Parent
local Creator = require(Root.Creator)

local New = Creator.New
local Components = Root.Components

local Element = {}
Element.__index = Element
Element.__type = "Slider"

function Element:New(Idx, Config)
	local Library = self.Library

	local Slider = {
		Value = nil,
		Min = Config.Min,
		Max = Config.Max,
		Rounding = Config.Rounding,
		Callback = Config.Callback or function() end,
		Type = "Slider",
	}

	local Dragging = false
	local Touching = false

	local SliderFrame = require(Components.Element)(Config.Title, Config.Description, self.Container, false)
	SliderFrame.DescLabel.Size = UDim2.new(1, -170, 0, 14)

	Slider.SetTitle = SliderFrame.SetTitle
	Slider.SetDesc = SliderFrame.SetDesc

	local SliderDot = New("ImageLabel", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, -7, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		Image = "http://www.roblox.com/asset/?id=12266946128",
		ThemeTag = { ImageColor3 = "Accent" },
	})

	local SliderRail = New("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(7, 0),
		Size = UDim2.new(1, -14, 1, 0),
	}, { SliderDot })

	local SliderFill = New("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		ThemeTag = { BackgroundColor3 = "Accent" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(1, 0) }),
	})

	local SliderDisplay = New("TextLabel", {
		Font = Enum.Font.GothamSSm,
		Text = "Value",
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 100, 0, 14),
		Position = UDim2.new(0, -4, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		ThemeTag = { TextColor3 = "SubText" },
	})

	local SliderInner = New("Frame", {
		Size = UDim2.new(1, 0, 0, 4),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		BackgroundTransparency = 0.4,
		Parent = SliderFrame.Frame,
		ThemeTag = { BackgroundColor3 = "SliderRail" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(1, 0) }),
		New("UISizeConstraint", { MaxSize = Vector2.new(150, math.huge) }),
		SliderDisplay,
		SliderFill,
		SliderRail,
	})

	local function UpdateValue(Input)
		local SizeScale = math.clamp((Input.Position.X - SliderRail.AbsolutePosition.X) / SliderRail.AbsoluteSize.X, 0, 1)
		Slider:SetValue(Slider.Min + ((Slider.Max - Slider.Min) * SizeScale))
	end

	Creator.AddSignal(SliderDot.InputBegan, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = true
		elseif Input.UserInputType == Enum.UserInputType.Touch then
			Touching = true
		end
	end)

	Creator.AddSignal(SliderDot.InputEnded, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = false
		elseif Input.UserInputType == Enum.UserInputType.Touch then
			Touching = false
		end
	end)

	Creator.AddSignal(UserInputService.InputChanged, function(Input)
		if (Dragging or Touching) and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
			UpdateValue(Input)
		end
	end)

	function Slider:SetValue(Value)
		self.Value = Library:Round(math.clamp(Value, self.Min, self.Max), self.Rounding)
		SliderDot.Position = UDim2.new((self.Value - self.Min) / (self.Max - self.Min), -7, 0.5, 0)
		SliderFill.Size = UDim2.fromScale((self.Value - self.Min) / (self.Max - self.Min), 1)
		SliderDisplay.Text = tostring(self.Value)

		Library:SafeCallback(self.Callback, self.Value)
		Library:SafeCallback(self.Changed, self.Value)
	end

	function Slider:Destroy()
		SliderFrame:Destroy()
		Library.Options[Idx] = nil
	end

	Slider:SetValue(Config.Default)
	Library.Options[Idx] = Slider
	return Slider
end

return Element


--========================================================
-- ZEPH HUB V3 | FULL CORRECTED SCRIPT
-- Studio Lite | Mobile + PC | Single LocalScript
--========================================================

local Players=game:GetService("Players")
local Lighting=game:GetService("Lighting")
local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer
if not player then return end
local playerGui=player:WaitForChild("PlayerGui")

local old=playerGui:FindFirstChild("ZephHub")
if old then old:Destroy() end

local purple=Color3.fromRGB(145,55,255)
local dark=Color3.fromRGB(15,12,23)
local white=Color3.new(1,1,1)
local state={Fly=false,Noclip=false,InfiniteJump=false,Sprint=false,DayNight=false,FlySpeed=60,ESPDistance=300}
local character,humanoid,root
local savedPosition
local savedCollision={}
local coords={X=0,Y=5,Z=0}
local objectName=""
local flyVelocity,flyGyro
local guiAlive=true
local busy=false

local function make(class,props,parent)
	local o=Instance.new(class)
	for k,v in pairs(props or {}) do
		pcall(function() o[k]=v end)
	end
	o.Parent=parent
	return o
end
local function round(o,r)
	make("UICorner",{CornerRadius=UDim.new(0,r or 8)},o)
end
local function outline(o,c,t,tr)
	return make("UIStroke",{Color=c or purple,Thickness=t or 1,Transparency=tr or 0},o)
end
local function tween(o,props,d,style,dir)
	local t=TweenService:Create(o,TweenInfo.new(d or .25,style or Enum.EasingStyle.Quart,dir or Enum.EasingDirection.Out),props)
	t:Play()
	return t
end
local function bindCharacter(c)
	character=c
	humanoid=c:WaitForChild("Humanoid",10)
	root=c:WaitForChild("HumanoidRootPart",10)
	table.clear(savedCollision)
end
if player.Character then task.spawn(bindCharacter,player.Character) end
player.CharacterAdded:Connect(bindCharacter)

--========================================================
-- SCREEN GUI
--========================================================

local gui=make("ScreenGui",{
	Name="ZephHub",ResetOnSpawn=false,IgnoreGuiInset=false,
	DisplayOrder=50,ZIndexBehavior=Enum.ZIndexBehavior.Sibling
},playerGui)

-- LOADING SCREEN
local loading=make("Frame",{
	Name="Loading",Size=UDim2.fromScale(1,1),
	BackgroundColor3=Color3.fromRGB(7,5,12),
	BorderSizePixel=0,ZIndex=100
},gui)
local loadTitle=make("TextLabel",{
	AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.43),
	Size=UDim2.new(0,280,0,42),BackgroundTransparency=1,
	Text="Z E P H   H U B",TextColor3=purple,TextSize=23,
	Font=Enum.Font.GothamBold,ZIndex=101
},loading)
local loadSub=make("TextLabel",{
	AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.49),
	Size=UDim2.new(0,260,0,20),BackgroundTransparency=1,
	Text="INITIALIZING INTERFACE",TextColor3=white,TextSize=10,
	Font=Enum.Font.Code,ZIndex=101
},loading)
local loadBack=make("Frame",{
	AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.55),
	Size=UDim2.new(0,230,0,5),
	BackgroundColor3=Color3.fromRGB(43,36,54),
	BorderSizePixel=0,ZIndex=101
},loading)
round(loadBack,4)
local loadBar=make("Frame",{
	Size=UDim2.new(0,0,1,0),BackgroundColor3=purple,
	BorderSizePixel=0,ZIndex=102
},loadBack)
round(loadBar,4)
outline(loadBar,Color3.fromRGB(200,140,255),1,0)

--========================================================
-- MAIN WIDE RECTANGULAR PANEL
--========================================================

local shadow=make("Frame",{
	Name="Glow",AnchorPoint=Vector2.new(.5,.5),
	Position=UDim2.new(.5,0,.53,0),
	Size=UDim2.new(0,340,0,220),
	BackgroundColor3=purple,BackgroundTransparency=1,
	BorderSizePixel=0,Visible=false
},gui)
round(shadow,12)

local main=make("Frame",{
	Name="Main",AnchorPoint=Vector2.new(.5,.5),
	Position=UDim2.new(.5,0,.53,0),
	Size=UDim2.new(0,326,0,206),
	BackgroundColor3=dark,BackgroundTransparency=1,
	BorderSizePixel=0,ClipsDescendants=true,Visible=false
},gui)
round(main,10)
outline(main,purple,1.5,.05)

local top=make("Frame",{
	Size=UDim2.new(1,0,0,34),
	BackgroundColor3=Color3.fromRGB(24,20,34),
	BorderSizePixel=0
},main)
round(top,10)
make("Frame",{
	Position=UDim2.new(0,0,1,-10),
	Size=UDim2.new(1,0,0,10),
	BackgroundColor3=Color3.fromRGB(24,20,34),
	BorderSizePixel=0
},top)
make("TextLabel",{
	Position=UDim2.new(0,11,0,0),
	Size=UDim2.new(0,140,1,0),
	BackgroundTransparency=1,Text="ZEPH  /  HUB",
	TextColor3=white,TextSize=13,
	Font=Enum.Font.GothamBold,
	TextXAlignment=Enum.TextXAlignment.Left
},top)
make("TextLabel",{
	Position=UDim2.new(1,-92,0,0),
	Size=UDim2.new(0,48,1,0),
	BackgroundTransparency=1,Text="ONLINE",
	TextColor3=Color3.fromRGB(140,255,190),
	TextSize=9,Font=Enum.Font.Code
},top)

local minimize=make("TextButton",{
	Position=UDim2.new(1,-38,0,5),
	Size=UDim2.new(0,28,0,23),
	BackgroundColor3=Color3.fromRGB(48,35,66),
	Text="—",TextColor3=white,TextSize=15,
	Font=Enum.Font.GothamBold,BorderSizePixel=0,
	AutoButtonColor=false
},top)
round(minimize,5)

-- DRAGGING
do
	local dragging=false
	local dragStart,startPos
	top.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
			dragging=true
			dragStart=i.Position
			startPos=main.Position
			i.Changed:Connect(function()
				if i.UserInputState==Enum.UserInputState.End then dragging=false end
			end)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
			local d=i.Position-dragStart
			main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
			shadow.Position=main.Position
		end
	end)
end

-- WHITE Z RESTORE BUTTON
local mini=make("TextButton",{
	Name="RestoreButton",Visible=false,
	AnchorPoint=Vector2.new(.5,.5),Position=main.Position,
	Size=UDim2.new(0,55,0,36),
	BackgroundColor3=dark,Text="Z",TextColor3=white,
	TextSize=22,Font=Enum.Font.GothamBold,
	BorderSizePixel=0,AutoButtonColor=false
},gui)
round(mini,9)
local miniStroke=outline(mini,Color3.fromRGB(180,110,255),1.5,.05)

mini.MouseEnter:Connect(function()
	tween(mini,{BackgroundColor3=Color3.fromRGB(40,27,58)},.15)
	tween(miniStroke,{Thickness=2.5},.15)
end)
mini.MouseLeave:Connect(function()
	tween(mini,{BackgroundColor3=dark},.15)
	tween(miniStroke,{Thickness=1.5},.15)
end)

--========================================================
-- TABS AND CONTENT
--========================================================

local tabBar=make("ScrollingFrame",{
	Position=UDim2.new(0,7,0,40),Size=UDim2.new(1,-14,0,27),
	BackgroundTransparency=1,BorderSizePixel=0,
	ScrollBarThickness=2,ScrollingDirection=Enum.ScrollingDirection.X,
	CanvasSize=UDim2.new(0,0,0,0),
	AutomaticCanvasSize=Enum.AutomaticSize.X
},main)
make("UIListLayout",{
	FillDirection=Enum.FillDirection.Horizontal,
	Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder
},tabBar)

local content=make("ScrollingFrame",{
	Position=UDim2.new(0,8,0,73),Size=UDim2.new(1,-16,1,-80),
	BackgroundColor3=Color3.fromRGB(19,16,27),
	BorderSizePixel=0,ScrollBarThickness=3,
	ScrollBarImageColor3=purple,
	CanvasSize=UDim2.new(0,0,0,0),
	AutomaticCanvasSize=Enum.AutomaticSize.Y
},main)
round(content,7)
make("UIPadding",{
	PaddingTop=UDim.new(0,6),PaddingBottom=UDim.new(0,6),
	PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6)
},content)
make("UIListLayout",{
	Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder
},content)

local pages={}
local function page(n)
	local p={Name=n,Items={}}
	pages[n]=p
	return p
end
local function addButton(p,n,fn)
	table.insert(p.Items,{Type="Button",Label=n,Callback=fn})
end
local function addToggle(p,n,v,fn)
	table.insert(p.Items,{Type="Toggle",Label=n,Value=v,Callback=fn})
end
local function addSlider(p,n,a,b,v,fn)
	table.insert(p.Items,{Type="Slider",Label=n,Min=a,Max=b,Value=v,Callback=fn})
end
local function addInput(p,n,ph,fn)
	table.insert(p.Items,{Type="Input",Label=n,Placeholder=ph,Callback=fn})
end

--========================================================
-- 1. LOCAL PLAYER
--========================================================

local LP=page("LOCAL PLAYER")
addSlider(LP,"WALK SPEED",8,100,16,function(v) if humanoid then humanoid.WalkSpeed=v end end)
addSlider(LP,"JUMP POWER",20,150,50,function(v) if humanoid then humanoid.UseJumpPower=true; humanoid.JumpPower=v end end)
addToggle(LP,"FLY",false,function(v) state.Fly=v end)
addSlider(LP,"FLY SPEED",20,150,60,function(v) state.FlySpeed=v end)
addToggle(LP,"NOCLIP",false,function(v)
	state.Noclip=v
	if not v then
		for part,oldValue in pairs(savedCollision) do
			if part and part.Parent then part.CanCollide=oldValue end
		end
		table.clear(savedCollision)
	end
end)
addToggle(LP,"INFINITE JUMP",false,function(v) state.InfiniteJump=v end)
addToggle(LP,"SPRINT",false,function(v)
	state.Sprint=v
	if humanoid then humanoid.WalkSpeed=v and 32 or 16 end
end)
addSlider(LP,"HIP HEIGHT",0,15,0,function(v) if humanoid then humanoid.HipHeight=v end end)
addButton(LP,"RESET CHARACTER",function() if humanoid then humanoid.Health=0 end end)
addButton(LP,"REAPPLY SETTINGS",function()
	if humanoid then humanoid.WalkSpeed=16; humanoid.UseJumpPower=true; humanoid.JumpPower=50 end
end)

--========================================================
-- 2. WORLD
--========================================================

local W=page("WORLD")
addSlider(W,"TIME OF DAY",0,24,14,function(v) Lighting.ClockTime=v end)
addSlider(W,"BRIGHTNESS",0,5,2,function(v) Lighting.Brightness=v end)
addSlider(W,"GRAVITY",20,250,196,function(v) workspace.Gravity=v end)
addToggle(W,"FOG",false,function(v) Lighting.FogEnd=v and 150 or 100000 end)
addSlider(W,"FOG DISTANCE",50,2000,500,function(v) Lighting.FogEnd=v end)
addToggle(W,"ATMOSPHERE",true,function(v)
	local a=Lighting:FindFirstChildOfClass("Atmosphere")
	if a then a.Density=v and .3 or 0 end
end)
addToggle(W,"CLOUDS",true,function(v)
	local c=workspace.Terrain:FindFirstChildOfClass("Clouds")
	if c then c.Enabled=v end
end)
addToggle(W,"GLOBAL SHADOWS",true,function(v) Lighting.GlobalShadows=v end)
addToggle(W,"DAY / NIGHT",false,function(v) state.DayNight=v end)
addButton(W,"RESET WORLD VISUALS",function()
	Lighting.ClockTime=14
	Lighting.Brightness=2
	Lighting.FogEnd=100000
	Lighting.GlobalShadows=true
end)

--========================================================
-- 3. GRAPHICS
--========================================================

local cc=Lighting:FindFirstChild("ZephColorCorrection")
if not cc then cc=make("ColorCorrectionEffect",{Name="ZephColorCorrection",Saturation=0,Contrast=0,Brightness=0,TintColor=Color3.new(1,1,1)},Lighting) end
local bloom=Lighting:FindFirstChild("ZephBloom")
if not bloom then bloom=make("BloomEffect",{Name="ZephBloom",Intensity=.5,Size=24,Threshold=1,Enabled=false},Lighting) end
local blur=Lighting:FindFirstChild("ZephBlur")
if not blur then blur=make("BlurEffect",{Name="ZephBlur",Size=8,Enabled=false},Lighting) end
local dof=Lighting:FindFirstChild("ZephDepthOfField")
if not dof then dof=make("DepthOfFieldEffect",{Name="ZephDepthOfField",Enabled=false,FarIntensity=.2,FocusDistance=25,InFocusRadius=20,NearIntensity=.1},Lighting) end

local G=page("GRAPHICS")
addSlider(G,"SATURATION",-1,1,0,function(v) cc.Saturation=v end)
addSlider(G,"CONTRAST",-1,1,0,function(v) cc.Contrast=v end)
addSlider(G,"EXPOSURE",-1,1,0,function(v) cc.Brightness=v end)
addToggle(G,"BLOOM",false,function(v) bloom.Enabled=v end)
addSlider(G,"BLOOM INTENSITY",0,3,1,function(v) bloom.Intensity=v end)
addToggle(G,"BLUR",false,function(v) blur.Enabled=v end)
addToggle(G,"DEPTH OF FIELD",false,function(v) dof.Enabled=v end)
addSlider(G,"TINT: RED TO BLUE",0,100,50,function(v)
	cc.TintColor=Color3.fromRGB(math.floor(255-v*1.2),math.floor(180+v*.5),math.floor(100+v*1.55))
end)
addToggle(G,"COLOR CORRECTION",true,function(v) cc.Enabled=v end)
addButton(G,"RESET GRAPHICS",function()
	cc.Saturation=0; cc.Contrast=0; cc.Brightness=0
	cc.TintColor=Color3.new(1,1,1)
	bloom.Enabled=false; blur.Enabled=false; dof.Enabled=false
end)

--========================================================
-- 4. GUI GRAPHICS
--========================================================

local GG=page("GUI GRAPHICS")
addSlider(GG,"HUB TRANSPARENCY",0,60,0,function(v) main.BackgroundTransparency=v/100 end)
addSlider(GG,"UI SCALE",70,120,100,function(v)
	main.Size=UDim2.new(0,326*v/100,0,206*v/100)
	shadow.Size=UDim2.new(0,340*v/100,0,220*v/100)
end)
addSlider(GG,"CORNER ROUNDNESS",2,18,10,function(v)
	for _,o in ipairs({main,top,content,mini,shadow}) do
		local c=o:FindFirstChildOfClass("UICorner")
		if c then c.CornerRadius=UDim.new(0,v) end
	end
end)
addSlider(GG,"GLOW INTENSITY",0,100,72,function(v) shadow.BackgroundTransparency=1-v/100 end)
addSlider(GG,"PURPLE / BLUE ACCENT",0,100,0,function(v)
	purple=Color3.fromRGB(145-v,55+v,255)
	for _,o in ipairs(gui:GetDescendants()) do
		if o:IsA("UIStroke") then o.Color=purple end
	end
end)
addSlider(GG,"TEXT SIZE",8,16,10,function(v)
	for _,o in ipairs(gui:GetDescendants()) do
		if o:IsA("TextLabel") or o:IsA("TextButton") then o.TextSize=v end
	end
end)
addSlider(GG,"BACKGROUND SHADE",0,100,15,function(v)
	main.BackgroundColor3=Color3.fromRGB(math.floor(30-v*.2),math.floor(25-v*.15),math.floor(40-v*.2))
end)
addSlider(GG,"BUTTON TRANSPARENCY",0,80,0,function(v)
	for _,o in ipairs(tabBar:GetChildren()) do
		if o:IsA("TextButton") then o.BackgroundTransparency=v/100 end
	end
end)
addSlider(GG,"ANIMATION SPEED",1,10,3,function(v) state.AnimSpeed=v/10 end)
addButton(GG,"RESET HUB APPEARANCE",function()
	main.BackgroundColor3=dark
	main.BackgroundTransparency=0
	shadow.BackgroundTransparency=.72
	main.Size=UDim2.new(0,326,0,206)
	shadow.Size=UDim2.new(0,340,0,220)
end)

--========================================================
-- 5. TELEPORTS
--========================================================

local T=page("TELEPORTS")
addButton(T,"TELEPORT TO SPAWN",function()
	if root then
		local s=workspace:FindFirstChildWhichIsA("SpawnLocation",true)
		if s then root.CFrame=s.CFrame+Vector3.new(0,4,0) end
	end
end)
addButton(T,"SAVE CURRENT POSITION",function() if root then savedPosition=root.CFrame end end)
addButton(T,"RETURN TO SAVED POSITION",function() if root and savedPosition then root.CFrame=savedPosition end end)
addInput(T,"X COORDINATE","Enter X",function(txt) local n=tonumber(txt); if n then coords.X=n end end)
addInput(T,"Y COORDINATE","Enter Y",function(txt) local n=tonumber(txt); if n then coords.Y=n end end)
addInput(T,"Z COORDINATE","Enter Z",function(txt) local n=tonumber(txt); if n then coords.Z=n end end)
addButton(T,"TELEPORT TO COORDINATES",function() if root then root.CFrame=CFrame.new(coords.X,coords.Y,coords.Z) end end)
addInput(T,"PART / MODEL NAME","Enter object name",function(txt) objectName=txt end)
addButton(T,"TELEPORT TO PART / MODEL",function()
	if not root or objectName=="" then return end
	local obj=workspace:FindFirstChild(objectName,true)
	if obj then
		local p=obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart",true)
		if p then root.CFrame=p.CFrame+Vector3.new(0,4,0) end
	end
end)
addButton(T,"TELEPORT UP 25 STUDS",function() if root then root.CFrame=root.CFrame+Vector3.new(0,25,0) end end)

--========================================================
-- 6. ESP (INITIALIZED BEFORE ITS FEATURES)
--========================================================

local E=page("ESP")
local espFolder=make("Folder",{Name="ZephESP"},gui)
local function clearESP()
	if espFolder then espFolder:ClearAllChildren() end
end
local function addESP(target,labelText,color)
	if not target then return end
	local adornee=target:IsA("Model") and target or target:FindFirstAncestorOfClass("Model") or target
	if not adornee:IsA("Model") and not adornee:IsA("BasePart") then return end
	make("Highlight",{
		Adornee=adornee,FillColor=color or purple,OutlineColor=white,
		FillTransparency=.65,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
	},espFolder)
	if labelText then
		local part=adornee:IsA("Model") and (adornee:FindFirstChild("Head") or adornee:FindFirstChildWhichIsA("BasePart")) or adornee
		if part then
			local bb=make("BillboardGui",{
				Adornee=part,Size=UDim2.new(0,130,0,25),
				StudsOffset=Vector3.new(0,2.5,0),AlwaysOnTop=true
			},espFolder)
			make("TextLabel",{
				Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
				Text=labelText,TextColor3=white,TextStrokeTransparency=.2,
				TextSize=11,Font=Enum.Font.GothamBold
			},bb)
		end
	end
end
addToggle(E,"PLAYER HIGHLIGHTS",false,function(v)
	clearESP()
	if v then for _,p in ipairs(Players:GetPlayers()) do if p~=player and p.Character then addESP(p.Character,p.Name,purple) end end end
end)
addToggle(E,"PLAYER NAME LABELS",false,function(v)
	clearESP()
	if v then for _,p in ipairs(Players:GetPlayers()) do if p~=player and p.Character then addESP(p.Character,p.Name,purple) end end end
end)
addToggle(E,"PLAYER DISTANCE LABELS",false,function(v)
	clearESP()
	if v and root then
		for _,p in ipairs(Players:GetPlayers()) do
			if p~=player and p.Character then
				local r=p.Character:FindFirstChild("HumanoidRootPart")
				if r then addESP(p.Character,p.Name.." "..math.floor((r.Position-root.Position).Magnitude).." studs",purple) end
			end
		end
	end
end)
addSlider(E,"ESP COLOR: RED / BLUE",0,100,50,function(v)
	state.ESPColor=Color3.fromRGB(math.floor(255-v*2.2),50+v,math.floor(50+v*2))
end)
addToggle(E,"NPC HIGHLIGHTS",false,function(v)
	clearESP()
	if v then for _,m in ipairs(workspace:GetDescendants()) do if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(m) then addESP(m,m.Name,purple) end end end
end)
addToggle(E,"NPC NAME LABELS",false,function(v)
	clearESP()
	if v then for _,m in ipairs(workspace:GetDescendants()) do if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(m) then addESP(m,m.Name,purple) end end end
end)
addToggle(E,"OBJECT HIGHLIGHTS",false,function(v)
	clearESP()
	if v then for _,o in ipairs(workspace:GetDescendants()) do if o:IsA("BasePart") and o.Name~="Baseplate" then addESP(o,nil,purple) end end end
end)
addToggle(E,"OBJECT NAME LABELS",false,function(v)
	clearESP()
	if v then for _,o in ipairs(workspace:GetDescendants()) do if o:IsA("BasePart") then addESP(o,o.Name,purple) end end end
end)
addSlider(E,"ESP DISTANCE",50,1000,300,function(v) state.ESPDistance=v end)
addButton(E,"CLEAR ALL ESP",clearESP)

--========================================================
-- UI CONTROL RENDERER
--========================================================

local function clearPage()
	for _,v in ipairs(content:GetChildren()) do
		if v:IsA("GuiObject") and not v:IsA("UIPadding") and not v:IsA("UIListLayout") then v:Destroy() end
	end
end

local function createControl(item)
	local isSlider=item.Type=="Slider"
	local row=make("Frame",{
		Size=UDim2.new(1,-2,0,isSlider and 43 or 30),
		BackgroundColor3=Color3.fromRGB(29,24,40),BorderSizePixel=0
	},content)
	round(row,5)
	make("TextLabel",{
		Position=UDim2.new(0,8,0,0),Size=UDim2.new(.55,-8,1,0),
		BackgroundTransparency=1,Text=item.Label,TextColor3=white,
		TextSize=10,Font=Enum.Font.GothamMedium,
		TextXAlignment=Enum.TextXAlignment.Left
	},row)

	if item.Type=="Button" then
		local b=make("TextButton",{
			Position=UDim2.new(.59,0,.15,0),Size=UDim2.new(.37,0,.7,0),
			BackgroundColor3=Color3.fromRGB(74,38,112),Text="EXECUTE",
			TextColor3=white,TextSize=9,Font=Enum.Font.GothamBold,
			BorderSizePixel=0,AutoButtonColor=false
		},row)
		round(b,4)
		b.Activated:Connect(function()
			local ok,err=pcall(function() if item.Callback then item.Callback() end end)
			if not ok then warn("[ZEPH HUB] "..tostring(err)) end
			tween(b,{BackgroundColor3=purple},.12)
			task.delay(.15,function() if b.Parent then tween(b,{BackgroundColor3=Color3.fromRGB(74,38,112)},.15) end end)
		end)

	elseif item.Type=="Toggle" then
		local on=item.Value
		local b=make("TextButton",{
			Position=UDim2.new(1,-58,.5,-9),Size=UDim2.new(0,49,0,18),
			BackgroundColor3=on and purple or Color3.fromRGB(55,48,65),
			Text=on and "ON" or "OFF",TextColor3=white,
			TextSize=9,Font=Enum.Font.GothamBold,BorderSizePixel=0,
			AutoButtonColor=false
		},row)
		round(b,5)
		b.Activated:Connect(function()
			on=not on
			b.Text=on and "ON" or "OFF"
			tween(b,{BackgroundColor3=on and purple or Color3.fromRGB(55,48,65)},.15)
			local ok,err=pcall(function() if item.Callback then item.Callback(on) end end)
			if not ok then warn("[ZEPH HUB] "..tostring(err)) end
		end)

	elseif isSlider then
		local val=item.Value
		local function ratio() return math.clamp((val-item.Min)/(item.Max-item.Min),0,1) end
		local valueLabel=make("TextLabel",{
			Position=UDim2.new(1,-62,0,1),Size=UDim2.new(0,54,0,16),
			BackgroundTransparency=1,Text=tostring(val),TextColor3=purple,
			TextSize=10,Font=Enum.Font.Code,TextXAlignment=Enum.TextXAlignment.Right
		},row)
		local back=make("Frame",{
			Position=UDim2.new(0,8,0,27),Size=UDim2.new(1,-16,0,5),
			BackgroundColor3=Color3.fromRGB(58,51,70),BorderSizePixel=0
		},row)
		round(back,4)
		local fill=make("Frame",{Size=UDim2.new(ratio(),0,1,0),BackgroundColor3=purple,BorderSizePixel=0},back)
		round(fill,4)
		local knob=make("Frame",{
			AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(ratio(),0,.5,0),
			Size=UDim2.new(0,12,0,12),BackgroundColor3=white,BorderSizePixel=0
		},back)
		round(knob,10)
		local hit=make("TextButton",{
			Position=UDim2.new(0,0,-1,0),Size=UDim2.new(1,0,3,0),
			BackgroundTransparency=1,Text="",AutoButtonColor=false
		},back)
		local dragging=false
		local function setX(x)
			local width=math.max(back.AbsoluteSize.X,1)
			local pct=math.clamp((x-back.AbsolutePosition.X)/width,0,1)
			val=math.floor(item.Min+(item.Max-item.Min)*pct)
			local r=ratio()
			fill.Size=UDim2.new(r,0,1,0)
			knob.Position=UDim2.new(r,0,.5,0)
			valueLabel.Text=tostring(val)
			local ok,err=pcall(function() if item.Callback then item.Callback(val) end end)
			if not ok then warn("[ZEPH HUB] "..tostring(err)) end
		end
		hit.InputBegan:Connect(function(i)
			if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; setX(i.Position.X) end
		end)
		local moveConn=UIS.InputChanged:Connect(function(i)
			if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then setX(i.Position.X) end
		end)
		local endConn=UIS.InputEnded:Connect(function(i)
			if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
		end)
		row.Destroying:Connect(function() moveConn:Disconnect(); endConn:Disconnect() end)

	elseif item.Type=="Input" then
		local box=make("TextBox",{
			Position=UDim2.new(.55,0,.13,0),Size=UDim2.new(.43,0,.74,0),
			BackgroundColor3=Color3.fromRGB(45,37,59),Text="",
			PlaceholderText=item.Placeholder or "Enter value",
			PlaceholderColor3=Color3.fromRGB(160,145,180),
			TextColor3=white,TextSize=10,Font=Enum.Font.Code,
			ClearTextOnFocus=false,BorderSizePixel=0
		},row)
		round(box,4)
		box.FocusLost:Connect(function()
			local ok,err=pcall(function() if item.Callback then item.Callback(box.Text) end end)
			if not ok then warn("[ZEPH HUB] "..tostring(err)) end
		end)
	end
end

local function showPage(name)
	clearPage()
	local p=pages[name]
	if not p then return end
	for _,item in ipairs(p.Items) do createControl(item) end
	content.CanvasPosition=Vector2.new(0,0)
end

for _,name in ipairs({"LOCAL PLAYER","WORLD","GRAPHICS","GUI GRAPHICS","TELEPORTS","ESP"}) do
	local b=make("TextButton",{
		Size=UDim2.new(0,91,0,25),
		BackgroundColor3=name=="LOCAL PLAYER" and purple or Color3.fromRGB(36,29,49),
		Text=name,TextColor3=white,TextSize=9,
		Font=Enum.Font.GothamBold,BorderSizePixel=0,AutoButtonColor=false
	},tabBar)
	round(b,5)
	b.Activated:Connect(function()
		for _,v in ipairs(tabBar:GetChildren()) do
			if v:IsA("TextButton") then
				tween(v,{BackgroundColor3=v==b and purple or Color3.fromRGB(36,29,49)},.15)
			end
		end
		showPage(name)
	end)
end
showPage("LOCAL PLAYER")

--========================================================
-- MINIMIZE / RESTORE
--========================================================

minimize.Activated:Connect(function()
	if busy then return end
	busy=true
	local t=tween(main,{Size=UDim2.new(0,20,0,20),BackgroundTransparency=1},.2,Enum.EasingStyle.Quart,Enum.EasingDirection.In)
	tween(shadow,{Size=UDim2.new(0,20,0,20),BackgroundTransparency=1},.2)
	t.Completed:Wait()
	main.Visible=false
	shadow.Visible=false
	main.Size=UDim2.new(0,326,0,206)
	main.BackgroundTransparency=0
	shadow.Size=UDim2.new(0,340,0,220)
	shadow.BackgroundTransparency=.72
	mini.Position=main.Position
	mini.Size=UDim2.new(0,12,0,12)
	mini.TextTransparency=1
	mini.Visible=true
	tween(mini,{Size=UDim2.new(0,55,0,36),TextTransparency=0},.28,Enum.EasingStyle.Back)
	busy=false
end)
mini.Activated:Connect(function()
	if busy then return end
	busy=true
	mini.Visible=false
	main.Visible=true
	shadow.Visible=true
	main.Size=UDim2.new(0,20,0,20)
	main.BackgroundTransparency=1
	shadow.Size=UDim2.new(0,20,0,20)
	shadow.BackgroundTransparency=1
	tween(main,{Size=UDim2.new(0,326,0,206),BackgroundTransparency=0},.32,Enum.EasingStyle.Back)
	local t=tween(shadow,{Size=UDim2.new(0,340,0,220),BackgroundTransparency=.72},.32)
	t.Completed:Wait()
	busy=false
end)

--========================================================
-- MOVEMENT SYSTEMS
--========================================================

local function stopFly()
	if flyVelocity then flyVelocity:Destroy(); flyVelocity=nil end
	if flyGyro then flyGyro:Destroy(); flyGyro=nil end
end

RunService.Heartbeat:Connect(function()
	if not guiAlive or not character or not humanoid or not root then return end
	if state.Fly then
		if not flyVelocity or not flyVelocity.Parent then
			flyVelocity=make("BodyVelocity",{MaxForce=Vector3.new(1e6,1e6,1e6),Velocity=Vector3.zero},root)
			flyGyro=make("BodyGyro",{MaxTorque=Vector3.new(1e6,1e6,1e6),P=1e4,CFrame=root.CFrame},root)
		end
		local cam=workspace.CurrentCamera
		local vertical=0
		if UIS:IsKeyDown(Enum.KeyCode.Space) then vertical=1
		elseif UIS:IsKeyDown(Enum.KeyCode.LeftControl) then vertical=-1 end
		flyVelocity.Velocity=humanoid.MoveDirection*state.FlySpeed+Vector3.new(0,vertical*state.FlySpeed,0)
		if cam then flyGyro.CFrame=CFrame.new(root.Position,root.Position+cam.CFrame.LookVector) end
	else
		stopFly()
	end
	if state.Noclip then
		for _,part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				if savedCollision[part]==nil then savedCollision[part]=part.CanCollide end
				part.CanCollide=false
			end
		end
	end
	if state.Sprint and humanoid.WalkSpeed~=32 then humanoid.WalkSpeed=32 end
	if state.DayNight then Lighting.ClockTime=(Lighting.ClockTime+.01)%24 end
end)

UIS.JumpRequest:Connect(function()
	if state.InfiniteJump and humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)
player.CharacterAdded:Connect(function()
	state.Fly=false
	state.Noclip=false
	stopFly()
end)

--========================================================
-- LOADING FINISH -> HUB ENTRANCE TWEEN
--========================================================

task.spawn(function()
	local messages={"INITIALIZING INTERFACE","LOADING COMPONENTS","PREPARING CONTROLS","ZEPH HUB READY"}
	for i=1,#messages do
		if not guiAlive or not loading.Parent then return end
		loadSub.Text=messages[i]
		tween(loadBar,{Size=UDim2.new(i/#messages,0,1,0)},.3)
		task.wait(.34)
	end
	task.wait(.15)
	for _,o in ipairs(loading:GetDescendants()) do
		if o:IsA("TextLabel") then tween(o,{TextTransparency=1},.22)
		elseif o:IsA("Frame") then tween(o,{BackgroundTransparency=1},.22) end
	end
	tween(loading,{BackgroundTransparency=1},.25)
	task.wait(.3)
	if loading.Parent then loading:Destroy() end
	if not guiAlive then return end
	main.Visible=true
	shadow.Visible=true
	main.Size=UDim2.new(0,20,0,20)
	main.BackgroundTransparency=1
	shadow.Size=UDim2.new(0,20,0,20)
	shadow.BackgroundTransparency=1
	tween(main,{Size=UDim2.new(0,326,0,206),BackgroundTransparency=0},.38,Enum.EasingStyle.Back)
	tween(shadow,{Size=UDim2.new(0,340,0,220),BackgroundTransparency=.72},.38)
end)

gui.Destroying:Connect(function()
	guiAlive=false
	stopFly()
	clearESP()
end)

print("[ZEPH HUB V3] Loaded")

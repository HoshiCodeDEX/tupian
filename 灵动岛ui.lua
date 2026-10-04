local TweenService=game:GetService("TweenService")
local UserInputService=game:GetService("UserInputService")
local Players=game:GetService("Players")
local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")
local function loadExternalImage(url)
if not url or url=="" then return "" end
if url:match("^rbxasset") then return url end
if not url:match("^https?://") then return url end
local hash=0
for i=1,#url do hash=(hash*31+url:byte(i))%2147483647 end
local fileName="extimg_"..hash..".png"
local getAsset=getcustomasset or getsynasset
if not getAsset then return "" end
if isfile and isfile(fileName) then
local ok,asset=pcall(getAsset,fileName)
if ok and asset then return asset end;end
local ok,data=pcall(function() return game:HttpGet(url) end)
if not ok or not data or data=="" then return "" end
local wok=pcall(function() writefile(fileName,data) end)
if not wok then return "" end
local aok,asset=pcall(getAsset,fileName)
if aok and asset then return asset end
return "" end
local CONFIG={TopOffset=12,CollapsedWidth=140,CollapsedHeight=40,CollapsedRadius=20,ExpandedWidth=380,ExpandedHeight=280,ExpandedRadius=14,SideBarWidth=100,CollapsedTransparency=0.25,CollapsedStrokeTransparency=0.80,ExpandedTransparency=0,ExpandedStrokeTransparency=0.9,ExpandTime=0.50,CollapseTime=0.35,DragThreshold=6,EdgePadding=10,Background="https://raw.githubusercontent.com/iyoulin/-/refs/heads/main/1790958736839.png",BackgroundImageTransparency=0.42,Color={Island=Color3.fromRGB(8,8,10),Text=Color3.fromRGB(255,255,255),SubText=Color3.fromRGB(150,150,160),Green=Color3.fromRGB(48,209,88),TrackOff=Color3.fromRGB(72,72,80),Knob=Color3.fromRGB(255,255,255),Minimize=Color3.fromRGB(255,179,64),Close=Color3.fromRGB(255,69,58),Divider=Color3.fromRGB(255,255,255),Accent=Color3.fromRGB(100,150,255),SideBar=Color3.fromRGB(18,18,22),InputBg=Color3.fromRGB(40,40,46),InputFocus=Color3.fromRGB(50,50,58),WinBtnBg=Color3.fromRGB(255,255,255),WinBtnIcon=Color3.fromRGB(200,200,210)}}
local isExpanded=false
local dragging=false
local dragMoved=false
local dragStartPos=Vector2.new()
local dragStartX=0
local dragStartY=0
local islandX,islandY=0,CONFIG.TopOffset
local panelX,panelY=nil,nil
local activeTweens={}
local expand,collapse,closeUI
local function cancelTweens()
local list=table.clone(activeTweens)
table.clear(activeTweens)
for _,t in ipairs(list) do t:Cancel() end;end
local function playTween(obj,info,goal)
local tween=TweenService:Create(obj,info,goal)
table.insert(activeTweens,tween)
tween.Completed:Connect(function()
local i=table.find(activeTweens,tween)
if i then table.remove(activeTweens,i) end;end)
tween:Play()
return tween end
local island
local function clampPos(x,y,w,h)
local vp=workspace.CurrentCamera.ViewportSize
local pad=CONFIG.EdgePadding
local minX,maxX=w/2+pad,vp.X-w/2-pad
local minY,maxY=pad,vp.Y-h-pad
if minX>maxX then x=vp.X*0.5 else x=math.clamp(x,minX,maxX) end
if minY>maxY then y=pad else y=math.clamp(y,minY,maxY) end
return x,y end
local function applyIslandPos(x,y)
island.Position=UDim2.fromOffset(math.round(x),math.round(y)) end
local oldGui=playerGui:FindFirstChild("DynamicIslandGui")
if oldGui then oldGui:Destroy() end
local gui=Instance.new("ScreenGui")
gui.Name="DynamicIslandGui"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.DisplayOrder=999
gui.Parent=playerGui
island=Instance.new("Frame")
island.Name="Island"
island.AnchorPoint=Vector2.new(0.5,0)
island.Size=UDim2.fromOffset(CONFIG.CollapsedWidth,CONFIG.CollapsedHeight)
island.BackgroundColor3=CONFIG.Color.Island
island.BackgroundTransparency=CONFIG.CollapsedTransparency
island.BorderSizePixel=0
island.ClipsDescendants=true
island.Active=true
island.Parent=gui
local islandCorner=Instance.new("UICorner")
islandCorner.CornerRadius=UDim.new(0,CONFIG.CollapsedRadius)
islandCorner.Parent=island
local islandStroke=Instance.new("UIStroke")
islandStroke.Color=Color3.fromRGB(255,255,255)
islandStroke.Transparency=CONFIG.CollapsedStrokeTransparency
islandStroke.Thickness=1
islandStroke.Parent=island
local islandGradient=Instance.new("UIGradient")
islandGradient.Rotation=90
islandGradient.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(28,28,32)),ColorSequenceKeypoint.new(1,Color3.fromRGB(6,6,8))})
islandGradient.Parent=island
local islandBgImage=Instance.new("ImageLabel")
islandBgImage.Name="Background"
islandBgImage.Size=UDim2.fromScale(1,1)
islandBgImage.Position=UDim2.fromScale(0,0)
islandBgImage.BackgroundTransparency=1
islandBgImage.Image=loadExternalImage(CONFIG.Background)
islandBgImage.ImageTransparency=1
islandBgImage.ScaleType=Enum.ScaleType.Crop
islandBgImage.ZIndex=0
islandBgImage.Parent=island
local islandBgCorner=Instance.new("UICorner")
islandBgCorner.CornerRadius=UDim.new(0,CONFIG.CollapsedRadius)
islandBgCorner.Parent=islandBgImage
local collapsedGroup=Instance.new("CanvasGroup")
collapsedGroup.Name="Collapsed"
collapsedGroup.AnchorPoint=Vector2.new(0.5,0)
collapsedGroup.Position=UDim2.new(0.5,0,0,0)
collapsedGroup.Size=UDim2.fromOffset(CONFIG.CollapsedWidth,CONFIG.CollapsedHeight)
collapsedGroup.BackgroundTransparency=1
collapsedGroup.GroupTransparency=0
collapsedGroup.ZIndex=4
collapsedGroup.Parent=island
local collapsedDot=Instance.new("Frame")
collapsedDot.Name="Dot"
collapsedDot.AnchorPoint=Vector2.new(0,0.5)
collapsedDot.Position=UDim2.new(0,18,0.5,0)
collapsedDot.Size=UDim2.fromOffset(8,8)
collapsedDot.BackgroundColor3=CONFIG.Color.Green
collapsedDot.BorderSizePixel=0
collapsedDot.Parent=collapsedGroup
local collapsedDotCorner=Instance.new("UICorner")
collapsedDotCorner.CornerRadius=UDim.new(1,0)
collapsedDotCorner.Parent=collapsedDot
local collapsedLabel=Instance.new("TextLabel")
collapsedLabel.Name="Label"
collapsedLabel.AnchorPoint=Vector2.new(0,0.5)
collapsedLabel.Position=UDim2.new(0,34,0.5,0)
collapsedLabel.Size=UDim2.new(0,92,0,20)
collapsedLabel.BackgroundTransparency=1
collapsedLabel.Font=Enum.Font.GothamBold
collapsedLabel.Text="霸王龙"
collapsedLabel.TextColor3=CONFIG.Color.Text
collapsedLabel.TextTransparency=0
collapsedLabel.TextSize=13
collapsedLabel.TextXAlignment=Enum.TextXAlignment.Left
collapsedLabel.Parent=collapsedGroup
local collapsedBtn=Instance.new("TextButton")
collapsedBtn.Name="Trigger"
collapsedBtn.Size=UDim2.fromScale(1,1)
collapsedBtn.BackgroundTransparency=1
collapsedBtn.Text=""
collapsedBtn.AutoButtonColor=false
collapsedBtn.ZIndex=6
collapsedBtn.Parent=collapsedGroup
local expandedGroup=Instance.new("CanvasGroup")
expandedGroup.Name="Expanded"
expandedGroup.Size=UDim2.fromScale(1,1)
expandedGroup.BackgroundTransparency=1
expandedGroup.GroupTransparency=1
expandedGroup.Visible=false
expandedGroup.ZIndex=5
expandedGroup.Parent=island
local header=Instance.new("Frame")
header.Name="Header"
header.BackgroundTransparency=1
header.Position=UDim2.new(0,12,0,8)
header.Size=UDim2.new(1,-24,0,34)
header.Active=true
header.Parent=expandedGroup
local dragHandle=Instance.new("TextButton")
dragHandle.Name="DragHandle"
dragHandle.Size=UDim2.new(1,-90,1,0)
dragHandle.BackgroundTransparency=1
dragHandle.Text=""
dragHandle.AutoButtonColor=false
dragHandle.ZIndex=1
dragHandle.Parent=header
local headerDot=Instance.new("Frame")
headerDot.AnchorPoint=Vector2.new(0,0.5)
headerDot.Position=UDim2.new(0,0,0.35,0)
headerDot.Size=UDim2.fromOffset(7,7)
headerDot.BackgroundColor3=CONFIG.Color.Green
headerDot.BorderSizePixel=0
headerDot.Parent=header
local headerDotCorner=Instance.new("UICorner")
headerDotCorner.CornerRadius=UDim.new(1,0)
headerDotCorner.Parent=headerDot
local headerTitle=Instance.new("TextLabel")
headerTitle.Name="Title"
headerTitle.AnchorPoint=Vector2.new(0,0)
headerTitle.Position=UDim2.new(0,14,0,0)
headerTitle.Size=UDim2.new(1,-100,0,16)
headerTitle.BackgroundTransparency=1
headerTitle.Font=Enum.Font.GothamBold
headerTitle.Text="控制中心"
headerTitle.TextColor3=CONFIG.Color.Text
headerTitle.TextSize=12
headerTitle.TextXAlignment=Enum.TextXAlignment.Left
headerTitle.Parent=header
local headerSub=Instance.new("TextLabel")
headerSub.Name="Sub"
headerSub.AnchorPoint=Vector2.new(0,0)
headerSub.Position=UDim2.new(0,14,0,16)
headerSub.Size=UDim2.new(1,-100,0,12)
headerSub.BackgroundTransparency=1
headerSub.Font=Enum.Font.Gotham
headerSub.Text="霸王龙 · 灵动岛面板"
headerSub.TextColor3=CONFIG.Color.SubText
headerSub.TextSize=9
headerSub.TextXAlignment=Enum.TextXAlignment.Left
headerSub.Parent=header
local function createWindowButton(parent,icon,order,hoverColor,onClick)
local btn=Instance.new("TextButton")
btn.Name="WinBtn"
btn.Size=UDim2.fromOffset(24,24)
btn.BackgroundColor3=CONFIG.Color.WinBtnBg
btn.BackgroundTransparency=0.92
btn.BorderSizePixel=0
btn.Text=""
btn.AutoButtonColor=false
btn.LayoutOrder=order
btn.ZIndex=5
btn.Parent=parent
local corner=Instance.new("UICorner")
corner.CornerRadius=UDim.new(1,0)
corner.Parent=btn
local stroke=Instance.new("UIStroke")
stroke.Color=Color3.fromRGB(255,255,255)
stroke.Transparency=0.85
stroke.Thickness=1
stroke.Parent=btn
local label=Instance.new("TextLabel")
label.Name="Icon"
label.Size=UDim2.fromScale(1,1)
label.BackgroundTransparency=1
label.Font=Enum.Font.GothamBold
label.Text=icon
label.TextColor3=CONFIG.Color.WinBtnIcon
label.TextSize=12
label.Parent=btn
btn.MouseEnter:Connect(function()
TweenService:Create(btn,TweenInfo.new(0.15),{BackgroundTransparency=0.55,BackgroundColor3=hoverColor}):Play()
TweenService:Create(label,TweenInfo.new(0.15),{TextColor3=Color3.fromRGB(255,255,255)}):Play()
TweenService:Create(stroke,TweenInfo.new(0.15),{Transparency=0.6}):Play();end)
btn.MouseLeave:Connect(function()
TweenService:Create(btn,TweenInfo.new(0.2),{BackgroundTransparency=0.92,BackgroundColor3=CONFIG.Color.WinBtnBg}):Play()
TweenService:Create(label,TweenInfo.new(0.2),{TextColor3=CONFIG.Color.WinBtnIcon}):Play()
TweenService:Create(stroke,TweenInfo.new(0.2),{Transparency=0.85}):Play();end)
btn.MouseButton1Down:Connect(function()
TweenService:Create(btn,TweenInfo.new(0.08),{Size=UDim2.fromOffset(20,20)}):Play();end)
btn.MouseButton1Up:Connect(function()
TweenService:Create(btn,TweenInfo.new(0.18,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(24,24)}):Play();end)
btn.MouseButton1Click:Connect(function()
if onClick then onClick() end;end)
return btn end
local buttonGroup=Instance.new("Frame")
buttonGroup.Name="ButtonGroup"
buttonGroup.AnchorPoint=Vector2.new(1,0.5)
buttonGroup.Position=UDim2.new(1,0,0.5,0)
buttonGroup.Size=UDim2.fromOffset(56,24)
buttonGroup.BackgroundTransparency=1
buttonGroup.Parent=header
local buttonLayout=Instance.new("UIListLayout")
buttonLayout.FillDirection=Enum.FillDirection.Horizontal
buttonLayout.SortOrder=Enum.SortOrder.LayoutOrder
buttonLayout.Padding=UDim.new(0,8)
buttonLayout.VerticalAlignment=Enum.VerticalAlignment.Center
buttonLayout.HorizontalAlignment=Enum.HorizontalAlignment.Right
buttonLayout.Parent=buttonGroup
local minBtn=createWindowButton(buttonGroup,"−",1,CONFIG.Color.Minimize,function()
if collapse then collapse() end;end)
local closeBtn=createWindowButton(buttonGroup,"✕",2,CONFIG.Color.Close,function()
if closeUI then closeUI() end;end)
local sideBar=Instance.new("Frame")
sideBar.Name="SideBar"
sideBar.BackgroundColor3=CONFIG.Color.SideBar
sideBar.BackgroundTransparency=0.3
sideBar.BorderSizePixel=0
sideBar.Position=UDim2.new(0,10,0,48)
sideBar.Size=UDim2.new(0,CONFIG.SideBarWidth,1,-58)
sideBar.Parent=expandedGroup
local sideBarCorner=Instance.new("UICorner")
sideBarCorner.CornerRadius=UDim.new(0,8)
sideBarCorner.Parent=sideBar
local sideBarStroke=Instance.new("UIStroke")
sideBarStroke.Color=Color3.fromRGB(255,255,255)
sideBarStroke.Transparency=0.94
sideBarStroke.Thickness=1
sideBarStroke.Parent=sideBar
local sideBarPadding=Instance.new("UIPadding")
sideBarPadding.PaddingTop=UDim.new(0,4)
sideBarPadding.PaddingBottom=UDim.new(0,4)
sideBarPadding.PaddingLeft=UDim.new(0,4)
sideBarPadding.PaddingRight=UDim.new(0,4)
sideBarPadding.Parent=sideBar
local sideBarLayout=Instance.new("UIListLayout")
sideBarLayout.FillDirection=Enum.FillDirection.Vertical
sideBarLayout.SortOrder=Enum.SortOrder.LayoutOrder
sideBarLayout.Padding=UDim.new(0,3)
sideBarLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
sideBarLayout.VerticalAlignment=Enum.VerticalAlignment.Top
sideBarLayout.Parent=sideBar
local contentArea=Instance.new("Frame")
contentArea.Name="ContentArea"
contentArea.BackgroundTransparency=1
contentArea.Position=UDim2.new(0,CONFIG.SideBarWidth+18,0,48)
contentArea.Size=UDim2.new(1,-(CONFIG.SideBarWidth+28),1,-58)
contentArea.ClipsDescendants=true
contentArea.Parent=expandedGroup
local tabs={}
local activeTabIndex=nil
local function createTabButton(title,icon,order)
local btn=Instance.new("TextButton")
btn.Name=title
btn.Size=UDim2.new(1,0,0,28)
btn.BackgroundColor3=CONFIG.Color.Accent
btn.BackgroundTransparency=1
btn.BorderSizePixel=0
btn.Text=""
btn.AutoButtonColor=false
btn.LayoutOrder=order
btn.Parent=sideBar
local corner=Instance.new("UICorner")
corner.CornerRadius=UDim.new(0,6)
corner.Parent=btn
local accentBar=Instance.new("Frame")
accentBar.Name="AccentBar"
accentBar.AnchorPoint=Vector2.new(0,0.5)
accentBar.Position=UDim2.new(0,0,0.5,0)
accentBar.Size=UDim2.fromOffset(2,12)
accentBar.BackgroundColor3=Color3.fromRGB(255,255,255)
accentBar.BorderSizePixel=0
accentBar.BackgroundTransparency=1
accentBar.Parent=btn
local accentBarCorner=Instance.new("UICorner")
accentBarCorner.CornerRadius=UDim.new(1,0)
accentBarCorner.Parent=accentBar
local iconLabel=Instance.new("TextLabel")
iconLabel.Name="Icon"
iconLabel.AnchorPoint=Vector2.new(0,0.5)
iconLabel.Position=UDim2.new(0,8,0.5,0)
iconLabel.Size=UDim2.new(0,14,0,14)
iconLabel.BackgroundTransparency=1
iconLabel.Font=Enum.Font.GothamBold
iconLabel.Text=icon
iconLabel.TextColor3=CONFIG.Color.SubText
iconLabel.TextSize=11
iconLabel.TextXAlignment=Enum.TextXAlignment.Center
iconLabel.Parent=btn
local label=Instance.new("TextLabel")
label.Name="Label"
label.AnchorPoint=Vector2.new(0,0.5)
label.Position=UDim2.new(0,26,0.5,0)
label.Size=UDim2.new(1,-30,1,0)
label.BackgroundTransparency=1
label.Font=Enum.Font.GothamMedium
label.Text=title
label.TextColor3=CONFIG.Color.SubText
label.TextSize=11
label.TextXAlignment=Enum.TextXAlignment.Left
label.Parent=btn
return btn,label,iconLabel,accentBar end
local function createTabContent(name)
local frame=Instance.new("ScrollingFrame")
frame.Name=name
frame.BackgroundTransparency=1
frame.BorderSizePixel=0
frame.Position=UDim2.fromScale(0,0)
frame.Size=UDim2.fromScale(1,1)
frame.CanvasSize=UDim2.new(0,0,0,0)
frame.AutomaticCanvasSize=Enum.AutomaticSize.Y
frame.ScrollBarThickness=3
frame.ScrollBarImageColor3=Color3.fromRGB(255,255,255)
frame.ScrollBarImageTransparency=0.6
frame.Visible=false
frame.Parent=contentArea
local pad=Instance.new("UIPadding")
pad.PaddingRight=UDim.new(0,8)
pad.PaddingTop=UDim.new(0,2)
pad.PaddingBottom=UDim.new(0,8)
pad.Parent=frame
local layout=Instance.new("UIListLayout")
layout.FillDirection=Enum.FillDirection.Vertical
layout.SortOrder=Enum.SortOrder.LayoutOrder
layout.Padding=UDim.new(0,6)
layout.Parent=frame
return frame end
local function switchTab(index)
if activeTabIndex==index then return end
activeTabIndex=index
for i,tab in ipairs(tabs) do
local active=(i==index)
tab.content.Visible=active
TweenService:Create(tab.button,TweenInfo.new(0.18,Enum.EasingStyle.Quart),{BackgroundTransparency=active and 0.1 or 1}):Play()
TweenService:Create(tab.label,TweenInfo.new(0.18,Enum.EasingStyle.Quart),{TextColor3=active and Color3.fromRGB(255,255,255) or CONFIG.Color.SubText}):Play()
TweenService:Create(tab.icon,TweenInfo.new(0.18,Enum.EasingStyle.Quart),{TextColor3=active and Color3.fromRGB(255,255,255) or CONFIG.Color.SubText}):Play()
TweenService:Create(tab.accentBar,TweenInfo.new(0.18,Enum.EasingStyle.Quart),{BackgroundTransparency=active and 0 or 1}):Play();end;end
local function createRow(parent,order)
local row=Instance.new("Frame")
row.Name="Row"
row.Size=UDim2.new(1,0,0,38)
row.BackgroundTransparency=1
row.LayoutOrder=order
row.Parent=parent
return row end
local function createDivider(parent,order)
local line=Instance.new("Frame")
line.Name="Divider"
line.Size=UDim2.new(1,0,0,1)
line.BackgroundColor3=CONFIG.Color.Divider
line.BackgroundTransparency=0.9
line.BorderSizePixel=0
line.LayoutOrder=order
line.Parent=parent
return line end
local function createToggle(parent,label,desc,defaultOn,order,onChanged)
local row=createRow(parent,order)
local labelText=Instance.new("TextLabel")
labelText.BackgroundTransparency=1
labelText.Size=UDim2.new(1,-60,0,18)
labelText.Position=UDim2.new(0,0,0,0)
labelText.Font=Enum.Font.GothamMedium
labelText.Text=label
labelText.TextColor3=CONFIG.Color.Text
labelText.TextSize=11
labelText.TextXAlignment=Enum.TextXAlignment.Left
labelText.Parent=row
if desc and desc~="" then
local descText=Instance.new("TextLabel")
descText.BackgroundTransparency=1
descText.Size=UDim2.new(1,-60,0,12)
descText.Position=UDim2.new(0,0,0,18)
descText.Font=Enum.Font.Gotham
descText.Text=desc
descText.TextColor3=CONFIG.Color.SubText
descText.TextSize=9
descText.TextXAlignment=Enum.TextXAlignment.Left
descText.Parent=row;end
local TRACK_W,TRACK_H=34,18
local KNOB_SIZE=14
local KNOB_PAD=2
local KNOB_OFF=KNOB_PAD
local KNOB_ON=TRACK_W-KNOB_SIZE-KNOB_PAD
local track=Instance.new("TextButton")
track.AnchorPoint=Vector2.new(1,0.5)
track.Position=UDim2.new(1,0,0.5,0)
track.Size=UDim2.fromOffset(TRACK_W,TRACK_H)
track.BackgroundColor3=defaultOn and CONFIG.Color.Green or CONFIG.Color.TrackOff
track.BorderSizePixel=0
track.Text=""
track.AutoButtonColor=false
track.Parent=row
local trackCorner=Instance.new("UICorner")
trackCorner.CornerRadius=UDim.new(1,0)
trackCorner.Parent=track
local knob=Instance.new("Frame")
knob.AnchorPoint=Vector2.new(0,0.5)
knob.Position=UDim2.new(0,defaultOn and KNOB_ON or KNOB_OFF,0.5,0)
knob.Size=UDim2.fromOffset(KNOB_SIZE,KNOB_SIZE)
knob.BackgroundColor3=CONFIG.Color.Knob
knob.BorderSizePixel=0
knob.Parent=track
local knobCorner=Instance.new("UICorner")
knobCorner.CornerRadius=UDim.new(1,0)
knobCorner.Parent=knob
local state=defaultOn
local animating=false
local function setState(on,animate)
state=on
local info=animate and TweenInfo.new(0.22,Enum.EasingStyle.Quart,Enum.EasingDirection.Out) or TweenInfo.new(0)
TweenService:Create(knob,info,{Position=UDim2.new(0,on and KNOB_ON or KNOB_OFF,0.5,0)}):Play()
TweenService:Create(track,info,{BackgroundColor3=on and CONFIG.Color.Green or CONFIG.Color.TrackOff}):Play();end
track.MouseButton1Click:Connect(function()
if animating then return end
animating=true
setState(not state,true)
if onChanged then onChanged(state) end
task.delay(0.25,function() animating=false end);end)
return {Row=row,Get=function() return state end,Set=setState} end
local function createSlider(parent,label,desc,min,max,default,order,onChanged)
local row=createRow(parent,order)
row.Size=UDim2.new(1,0,0,48)
local labelText=Instance.new("TextLabel")
labelText.BackgroundTransparency=1
labelText.Size=UDim2.new(1,-60,0,18)
labelText.Font=Enum.Font.GothamMedium
labelText.Text=label
labelText.TextColor3=CONFIG.Color.Text
labelText.TextSize=11
labelText.TextXAlignment=Enum.TextXAlignment.Left
labelText.Parent=row
if desc and desc~="" then
local descText=Instance.new("TextLabel")
descText.BackgroundTransparency=1
descText.Size=UDim2.new(1,-60,0,12)
descText.Position=UDim2.new(0,0,0,16)
descText.Font=Enum.Font.Gotham
descText.Text=desc
descText.TextColor3=CONFIG.Color.SubText
descText.TextSize=9
descText.TextXAlignment=Enum.TextXAlignment.Left
descText.Parent=row;end
local valueLabel=Instance.new("TextLabel")
valueLabel.AnchorPoint=Vector2.new(1,0)
valueLabel.Position=UDim2.new(1,0,0,0)
valueLabel.Size=UDim2.new(0,40,0,16)
valueLabel.BackgroundTransparency=1
valueLabel.Font=Enum.Font.GothamBold
valueLabel.Text=tostring(default)
valueLabel.TextColor3=CONFIG.Color.Accent
valueLabel.TextSize=11
valueLabel.TextXAlignment=Enum.TextXAlignment.Right
valueLabel.Parent=row
local barBg=Instance.new("Frame")
barBg.AnchorPoint=Vector2.new(0,1)
barBg.Position=UDim2.new(0,0,1,0)
barBg.Size=UDim2.new(1,0,0,4)
barBg.BackgroundColor3=Color3.fromRGB(45,45,52)
barBg.BorderSizePixel=0
barBg.Parent=row
local barBgCorner=Instance.new("UICorner")
barBgCorner.CornerRadius=UDim.new(1,0)
barBgCorner.Parent=barBg
local barFill=Instance.new("Frame")
barFill.Size=UDim2.new((default-min)/(max-min),0,1,0)
barFill.BackgroundColor3=CONFIG.Color.Accent
barFill.BorderSizePixel=0
barFill.Parent=barBg
local barFillCorner=Instance.new("UICorner")
barFillCorner.CornerRadius=UDim.new(1,0)
barFillCorner.Parent=barFill
local handle=Instance.new("Frame")
handle.AnchorPoint=Vector2.new(0.5,0.5)
handle.Position=UDim2.new((default-min)/(max-min),0,0.5,0)
handle.Size=UDim2.fromOffset(10,10)
handle.BackgroundColor3=Color3.fromRGB(255,255,255)
handle.BorderSizePixel=0
handle.Parent=barBg
local handleCorner=Instance.new("UICorner")
handleCorner.CornerRadius=UDim.new(1,0)
handleCorner.Parent=handle
local clickArea=Instance.new("TextButton")
clickArea.Size=UDim2.new(1,0,2,0)
clickArea.Position=UDim2.new(0,0,-0.5,0)
clickArea.BackgroundTransparency=1
clickArea.Text=""
clickArea.AutoButtonColor=false
clickArea.Parent=barBg
local state=default
local trackDragging=false
local function updateFromX(x)
local rel=math.clamp((x-barBg.AbsolutePosition.X)/barBg.AbsoluteSize.X,0,1)
local val=math.round(min+(max-min)*rel)
state=val
valueLabel.Text=tostring(val)
barFill.Size=UDim2.new(rel,0,1,0)
handle.Position=UDim2.new(rel,0,0.5,0)
if onChanged then onChanged(val) end;end
clickArea.MouseButton1Down:Connect(function()
trackDragging=true
updateFromX(UserInputService:GetMouseLocation().X);end)
UserInputService.InputChanged:Connect(function(input)
if trackDragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
updateFromX(input.Position.X) end;end)
UserInputService.InputEnded:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
trackDragging=false end;end)
return {Row=row,Get=function() return state end} end
local function createDropdown(parent,label,desc,options,default,order,onChanged)
local row=createRow(parent,order)
row.Size=UDim2.new(1,0,0,44)
local labelText=Instance.new("TextLabel")
labelText.BackgroundTransparency=1
labelText.Size=UDim2.new(1,-60,0,18)
labelText.Font=Enum.Font.GothamMedium
labelText.Text=label
labelText.TextColor3=CONFIG.Color.Text
labelText.TextSize=11
labelText.TextXAlignment=Enum.TextXAlignment.Left
labelText.Parent=row
if desc and desc~="" then
local descText=Instance.new("TextLabel")
descText.BackgroundTransparency=1
descText.Size=UDim2.new(1,-60,0,12)
descText.Position=UDim2.new(0,0,0,16)
descText.Font=Enum.Font.Gotham
descText.Text=desc
descText.TextColor3=CONFIG.Color.SubText
descText.TextSize=9
descText.TextXAlignment=Enum.TextXAlignment.Left
descText.Parent=row;end
local btn=Instance.new("TextButton")
btn.AnchorPoint=Vector2.new(1,0.5)
btn.Position=UDim2.new(1,0,0.5,4)
btn.Size=UDim2.fromOffset(120,26)
btn.BackgroundColor3=CONFIG.Color.InputBg
btn.BorderSizePixel=0
btn.Text=""
btn.AutoButtonColor=false
btn.ClipsDescendants=true
btn.Parent=row
local btnCorner=Instance.new("UICorner")
btnCorner.CornerRadius=UDim.new(0,6)
btnCorner.Parent=btn
local btnLabel=Instance.new("TextLabel")
btnLabel.AnchorPoint=Vector2.new(0,0)
btnLabel.Position=UDim2.new(0,8,0,0)
btnLabel.Size=UDim2.new(1,-24,0,26)
btnLabel.BackgroundTransparency=1
btnLabel.Font=Enum.Font.GothamMedium
btnLabel.Text=default or options[1]
btnLabel.TextColor3=CONFIG.Color.Text
btnLabel.TextSize=10
btnLabel.TextXAlignment=Enum.TextXAlignment.Left
btnLabel.TextTruncate=Enum.TextTruncate.AtEnd
btnLabel.ZIndex=11
btnLabel.Parent=btn
local arrow=Instance.new("TextLabel")
arrow.AnchorPoint=Vector2.new(1,0)
arrow.Position=UDim2.new(1,-6,0,0)
arrow.Size=UDim2.new(0,14,0,26)
arrow.BackgroundTransparency=1
arrow.Font=Enum.Font.GothamBold
arrow.Text="▾"
arrow.TextColor3=CONFIG.Color.SubText
arrow.TextSize=10
arrow.ZIndex=11
arrow.Parent=btn
local state=default or options[1]
local listOpen=false
local optionButtons={}
local function closeList()
listOpen=false
for _,ob in ipairs(optionButtons) do ob:Destroy() end
table.clear(optionButtons)
arrow.Text="▾"
TweenService:Create(btn,TweenInfo.new(0.18,Enum.EasingStyle.Quart),{Size=UDim2.fromOffset(120,26)}):Play();end
btn.MouseButton1Click:Connect(function()
if listOpen then closeList() return end
listOpen=true
arrow.Text="▴"
local targetH=26+#options*22
TweenService:Create(btn,TweenInfo.new(0.2,Enum.EasingStyle.Quart),{Size=UDim2.fromOffset(120,targetH)}):Play()
for i,opt in ipairs(options) do
local ob=Instance.new("TextButton")
ob.Name="Option"..i
ob.Size=UDim2.new(1,0,0,20)
ob.Position=UDim2.new(0,0,0,26+(i-1)*22)
ob.BackgroundColor3=opt==state and CONFIG.Color.Accent or Color3.fromRGB(35,35,40)
ob.BorderSizePixel=0
ob.Text=""
ob.AutoButtonColor=false
ob.ZIndex=10
ob.Parent=btn
local obCorner=Instance.new("UICorner")
obCorner.CornerRadius=UDim.new(0,4)
obCorner.Parent=ob
local obLabel=Instance.new("TextLabel")
obLabel.AnchorPoint=Vector2.new(0,0.5)
obLabel.Position=UDim2.new(0,8,0.5,0)
obLabel.Size=UDim2.new(1,-16,1,0)
obLabel.BackgroundTransparency=1
obLabel.Font=Enum.Font.Gotham
obLabel.Text=opt
obLabel.TextColor3=CONFIG.Color.Text
obLabel.TextSize=10
obLabel.TextXAlignment=Enum.TextXAlignment.Left
obLabel.ZIndex=11
obLabel.Parent=ob
ob.MouseButton1Click:Connect(function()
state=opt
btnLabel.Text=opt
closeList()
if onChanged then onChanged(opt) end;end)
table.insert(optionButtons,ob);end;end)
return {Row=row,Get=function() return state end} end
local function createInput(parent,label,desc,placeholder,order,onChanged)
local row=createRow(parent,order)
row.Size=UDim2.new(1,0,0,44)
local labelText=Instance.new("TextLabel")
labelText.BackgroundTransparency=1
labelText.Size=UDim2.new(1,-60,0,18)
labelText.Font=Enum.Font.GothamMedium
labelText.Text=label
labelText.TextColor3=CONFIG.Color.Text
labelText.TextSize=11
labelText.TextXAlignment=Enum.TextXAlignment.Left
labelText.Parent=row
if desc and desc~="" then
local descText=Instance.new("TextLabel")
descText.BackgroundTransparency=1
descText.Size=UDim2.new(1,-60,0,12)
descText.Position=UDim2.new(0,0,0,16)
descText.Font=Enum.Font.Gotham
descText.Text=desc
descText.TextColor3=CONFIG.Color.SubText
descText.TextSize=9
descText.TextXAlignment=Enum.TextXAlignment.Left
descText.Parent=row;end
local inputBg=Instance.new("Frame")
inputBg.AnchorPoint=Vector2.new(1,0.5)
inputBg.Position=UDim2.new(1,0,0.5,4)
inputBg.Size=UDim2.fromOffset(140,26)
inputBg.BackgroundColor3=CONFIG.Color.InputBg
inputBg.BorderSizePixel=0
inputBg.Parent=row
local inputCorner=Instance.new("UICorner")
inputCorner.CornerRadius=UDim.new(0,6)
inputCorner.Parent=inputBg
local inputBox=Instance.new("TextBox")
inputBox.AnchorPoint=Vector2.new(0,0.5)
inputBox.Position=UDim2.new(0,8,0.5,0)
inputBox.Size=UDim2.new(1,-16,1,0)
inputBox.BackgroundTransparency=1
inputBox.Font=Enum.Font.Gotham
inputBox.PlaceholderText=placeholder or "输入..."
inputBox.PlaceholderColor3=CONFIG.Color.SubText
inputBox.Text=""
inputBox.TextColor3=CONFIG.Color.Text
inputBox.TextSize=10
inputBox.TextXAlignment=Enum.TextXAlignment.Left
inputBox.ClearTextOnFocus=false
inputBox.Parent=inputBg
inputBox.Focused:Connect(function()
TweenService:Create(inputBg,TweenInfo.new(0.15),{BackgroundColor3=CONFIG.Color.InputFocus}):Play();end)
inputBox.FocusLost:Connect(function()
TweenService:Create(inputBg,TweenInfo.new(0.15),{BackgroundColor3=CONFIG.Color.InputBg}):Play()
if onChanged then onChanged(inputBox.Text) end;end)
return {Row=row,Get=function() return inputBox.Text end} end
local function createButton(parent,label,desc,color,order,onClick)
local row=createRow(parent,order)
row.Size=UDim2.new(1,0,0,34)
local btn=Instance.new("TextButton")
btn.Size=UDim2.new(1,0,0,30)
btn.BackgroundColor3=color or Color3.fromRGB(50,50,58)
btn.BorderSizePixel=0
btn.Text=""
btn.AutoButtonColor=false
btn.Parent=row
local btnCorner=Instance.new("UICorner")
btnCorner.CornerRadius=UDim.new(0,6)
btnCorner.Parent=btn
local btnLabel=Instance.new("TextLabel")
btnLabel.AnchorPoint=Vector2.new(0,0.5)
btnLabel.Position=UDim2.new(0,10,0.5,0)
btnLabel.Size=UDim2.new(1,-20,1,0)
btnLabel.BackgroundTransparency=1
btnLabel.Font=Enum.Font.GothamBold
btnLabel.Text=label
btnLabel.TextColor3=Color3.fromRGB(255,255,255)
btnLabel.TextSize=11
btnLabel.TextXAlignment=Enum.TextXAlignment.Left
btnLabel.Parent=btn
btn.MouseButton1Down:Connect(function()
TweenService:Create(btn,TweenInfo.new(0.08),{Size=UDim2.new(1,0,0,26)}):Play();end)
btn.MouseButton1Up:Connect(function()
TweenService:Create(btn,TweenInfo.new(0.15,Enum.EasingStyle.Back),{Size=UDim2.new(1,0,0,30)}):Play();end)
btn.MouseButton1Click:Connect(function()
if onClick then onClick() end;end)
return {Row=row} end
local function createParagraph(parent,title,content,order)
local row=createRow(parent,order)
row.Size=UDim2.new(1,0,0,40)
local titleLabel=Instance.new("TextLabel")
titleLabel.BackgroundTransparency=1
titleLabel.Size=UDim2.new(1,0,0,16)
titleLabel.Font=Enum.Font.GothamBold
titleLabel.Text=title
titleLabel.TextColor3=CONFIG.Color.Text
titleLabel.TextSize=11
titleLabel.TextXAlignment=Enum.TextXAlignment.Left
titleLabel.Parent=row
local contentLabel=Instance.new("TextLabel")
contentLabel.BackgroundTransparency=1
contentLabel.Position=UDim2.new(0,0,0,18)
contentLabel.Size=UDim2.new(1,0,0,22)
contentLabel.Font=Enum.Font.Gotham
contentLabel.Text=content
contentLabel.TextColor3=CONFIG.Color.SubText
contentLabel.TextSize=9
contentLabel.TextXAlignment=Enum.TextXAlignment.Left
contentLabel.TextWrapped=true
contentLabel.TextYAlignment=Enum.TextYAlignment.Top
contentLabel.Parent=row
return {Row=row} end
do
local b1,l1,i1,a1=createTabButton("基础","◈",1)
local b2,l2,i2,a2=createTabButton("输入","✎",2)
local b3,l3,i3,a3=createTabButton("配置","⚙",3)
local c1=createTabContent("TabBasic")
local c2=createTabContent("TabInput")
local c3=createTabContent("TabConfig")
table.insert(tabs,{button=b1,label=l1,icon=i1,accentBar=a1,content=c1})
table.insert(tabs,{button=b2,label=l2,icon=i2,accentBar=a2,content=c2})
table.insert(tabs,{button=b3,label=l3,icon=i3,accentBar=a3,content=c3})
b1.MouseButton1Click:Connect(function() switchTab(1) end)
b2.MouseButton1Click:Connect(function() switchTab(2) end)
b3.MouseButton1Click:Connect(function() switchTab(3) end)
local order=0
local function ord()
order=order+1
return order end
createParagraph(c1,"基础交互","点击按钮、切换开关、拖动滑块",ord())
createButton(c1,"普通按钮","点击触发回调",Color3.fromRGB(55,55,65),ord(),function() end)
createButton(c1,"彩色按钮","带颜色的按钮",CONFIG.Color.Accent,ord(),function() end)
createDivider(c1,ord())
createToggle(c1,"示例开关","切换布尔状态",false,ord(),function(s) end)
createToggle(c1,"自动保存","开启后自动保存配置",true,ord(),function(s) end)
createToggle(c1,"夜间模式","降低画面亮度",false,ord(),function(s) end)
createDivider(c1,ord())
createSlider(c1,"音量","调整音量 0 到 100",0,100,50,ord(),function(v) end)
createSlider(c1,"透明度","调整透明度 0 到 100",0,100,75,ord(),function(v) end)
order=0
createParagraph(c2,"输入控件","输入文本、选择下拉选项",ord())
createInput(c2,"用户名","请输入你的名字","输入文字...",ord(),function(t) end)
createInput(c2,"搜索","输入关键词搜索","搜索...",ord(),function(t) end)
createDivider(c2,ord())
createDropdown(c2,"选择模式","从列表中选择",{"标准模式","性能模式","静音模式","自定义模式"},"标准模式",ord(),function(o) end)
createDropdown(c2,"语言","界面显示语言",{"简体中文","English","日本語","한국어"},"简体中文",ord(),function(o) end)
createDropdown(c2,"主题","界面配色主题",{"深色","浅色","跟随系统"},"深色",ord(),function(o) end)
order=0
createParagraph(c3,"配置管理","保存 / 加载 / 重置你的所有设置",ord())
createButton(c3,"保存配置","将当前控件状态保存到本地",Color3.fromRGB(48,140,80),ord(),function() end)
createButton(c3,"加载配置","从本地恢复控件状态",Color3.fromRGB(48,110,160),ord(),function() end)
createButton(c3,"重置全部","恢复所有控件默认值",Color3.fromRGB(160,60,60),ord(),function() end)
createDivider(c3,ord())
createParagraph(c3,"关于","灵动岛 UI v1.0 · 支持自定义背景图。所有控件回调目前仅打印日志，可自行替换为实际逻辑。",ord())
switchTab(1);end
function expand()
if isExpanded then return end
isExpanded=true
cancelTweens()
collapsedBtn.Visible=false
if panelX==nil or panelY==nil then
local vp=workspace.CurrentCamera.ViewportSize
panelX=vp.X*0.5
panelY=CONFIG.TopOffset end
panelX,panelY=clampPos(panelX,panelY,CONFIG.ExpandedWidth,CONFIG.ExpandedHeight)
islandX,islandY=panelX,panelY
applyIslandPos(islandX,islandY)
local easeOut=TweenInfo.new(CONFIG.ExpandTime,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
playTween(island,easeOut,{Size=UDim2.fromOffset(CONFIG.ExpandedWidth,CONFIG.ExpandedHeight),BackgroundTransparency=CONFIG.ExpandedTransparency})
playTween(islandStroke,easeOut,{Transparency=CONFIG.ExpandedStrokeTransparency})
playTween(islandCorner,easeOut,{CornerRadius=UDim.new(0,CONFIG.ExpandedRadius)})
playTween(islandBgImage,easeOut,{ImageTransparency=CONFIG.BackgroundImageTransparency})
playTween(islandBgCorner,easeOut,{CornerRadius=UDim.new(0,CONFIG.ExpandedRadius)})
playTween(collapsedGroup,TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{GroupTransparency=1})
expandedGroup.Visible=true
expandedGroup.GroupTransparency=1
playTween(expandedGroup,TweenInfo.new(0.30,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0.14),{GroupTransparency=0});end
function collapse(onDone)
if not isExpanded then
if onDone then onDone() end
return end
isExpanded=false
cancelTweens()
dragging=false
local vp=workspace.CurrentCamera.ViewportSize
local targetX=vp.X*0.5
local targetY=CONFIG.TopOffset
islandX,islandY=targetX,targetY
local easeOut=TweenInfo.new(CONFIG.CollapseTime,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
playTween(expandedGroup,TweenInfo.new(0.12),{GroupTransparency=1})
playTween(island,easeOut,{Size=UDim2.fromOffset(CONFIG.CollapsedWidth,CONFIG.CollapsedHeight),Position=UDim2.fromOffset(math.round(targetX),math.round(targetY)),BackgroundTransparency=CONFIG.CollapsedTransparency})
playTween(islandStroke,easeOut,{Transparency=CONFIG.CollapsedStrokeTransparency})
playTween(islandCorner,easeOut,{CornerRadius=UDim.new(0,CONFIG.CollapsedRadius)})
playTween(islandBgImage,easeOut,{ImageTransparency=1})
playTween(islandBgCorner,easeOut,{CornerRadius=UDim.new(0,CONFIG.CollapsedRadius)})
playTween(collapsedGroup,TweenInfo.new(0.26,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0.10),{GroupTransparency=0})
task.delay(CONFIG.CollapseTime,function()
if not isExpanded then
expandedGroup.Visible=false
collapsedBtn.Visible=true end
if onDone then onDone() end;end);end
function closeUI()
collapse(function()
gui.Enabled=false end);end
collapsedBtn.MouseButton1Click:Connect(function()
expand();end)
dragHandle.InputBegan:Connect(function(input)
if not isExpanded then return end
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
dragging=true
dragMoved=false
dragStartPos=Vector2.new(input.Position.X,input.Position.Y)
dragStartX=islandX
dragStartY=islandY end;end)
UserInputService.InputChanged:Connect(function(input)
if not dragging then return end
if not isExpanded then
dragging=false
return end
if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
local pos=Vector2.new(input.Position.X,input.Position.Y)
local delta=pos-dragStartPos
if not dragMoved and delta.Magnitude>CONFIG.DragThreshold then
dragMoved=true
cancelTweens() end
if dragMoved then
local nx,ny=clampPos(dragStartX+delta.X,dragStartY+delta.Y,CONFIG.ExpandedWidth,CONFIG.ExpandedHeight)
islandX,islandY=nx,ny
applyIslandPos(nx,ny)
panelX,panelY=nx,ny end;end;end)
UserInputService.InputEnded:Connect(function(input)
if not dragging then return end
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
dragging=false end;end)
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
if isExpanded then
panelX,panelY=clampPos(panelX,panelY,CONFIG.ExpandedWidth,CONFIG.ExpandedHeight)
islandX,islandY=panelX,panelY
else
islandX=workspace.CurrentCamera.ViewportSize.X*0.5
islandY=CONFIG.TopOffset end
applyIslandPos(islandX,islandY);end)
do
local vp=workspace.CurrentCamera.ViewportSize
islandX=vp.X*0.5
islandY=CONFIG.TopOffset
applyIslandPos(islandX,islandY);end
UserInputService.InputBegan:Connect(function(input,gameProcessed)
if gameProcessed then return end
if input.KeyCode==Enum.KeyCode.K and not gui.Enabled then
cancelTweens()
isExpanded=false
dragging=false
local vp=workspace.CurrentCamera.ViewportSize
islandX=vp.X*0.5
islandY=CONFIG.TopOffset
island.Size=UDim2.fromOffset(CONFIG.CollapsedWidth,CONFIG.CollapsedHeight)
island.Position=UDim2.fromOffset(math.round(islandX),math.round(islandY))
island.BackgroundTransparency=CONFIG.CollapsedTransparency
islandCorner.CornerRadius=UDim.new(0,CONFIG.CollapsedRadius)
islandStroke.Transparency=CONFIG.CollapsedStrokeTransparency
islandBgImage.ImageTransparency=1
islandBgCorner.CornerRadius=UDim.new(0,CONFIG.CollapsedRadius)
collapsedGroup.GroupTransparency=0
collapsedGroup.Visible=true
collapsedBtn.Visible=true
expandedGroup.GroupTransparency=1
expandedGroup.Visible=false
gui.Enabled=true end;end)
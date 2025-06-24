local cloneref = cloneref or clonereference or function(o) return o; end

local isfile = isfile or function(file)
        local success, result = pcall(readfile, file);
        return success and result ~= nil and result ~= '';
end

local assets = {
        ['vware/assets/shadow.png'] = 'rbxassetid://14898786664'; -- from vape v4 but whatever
        ['vware/assets/chevron.png'] = 'rbxassetid://73522118049967';
        ['vware/assets/close.png'] = 'rbxassetid://135062162350099';
        ['vware/assets/minimize.png'] = 'rbxassetid://71352560337965';
        ['vware/assets/search.png'] = 'rbxassetid://81893825403118';
};

local oldgetcustomasset = getcustomasset or getsynasset
local getcustomasset = function(path)
        if oldgetcustomasset then
                local success, result = pcall(oldgetcustomasset, path);
                return success and result ~= nil and result ~= '' and result;
        end

        return assets[path];
end

do
        for _, folder in {'vware', 'vware/assets', 'vware/configs', `vware/configs/{game.PlaceId}`} do
                if not isfolder(folder) then makefolder(folder); end
        end

        for path in assets do
                if not isfile(path) then
                        writefile(path, game:HttpGet(path:gsub('vware/', 'https://raw.githubusercontent.com/v537/vware/refs/heads/main/')));
                end
        end
end

-- Services
local InputService = game:GetService('UserInputService');
local TweenService = game:GetService('TweenService');

-- Variables
local centerPoint = Vector2.new(.5, .5);
local centerPos = UDim2.new(.5, .5);

local Library = {
        Palette = {
                Font = Font.fromName('Montserrat');
                Background = Color3.fromRGB(6, 6, 6);
                Inactive = Color3.fromRGB(150, 150, 150);
                Accent = Color3.fromRGB(255, 100, 100);
        };
        Connections = {};
        Tabs = {};
        Keybind = Enum.KeyCode.RightControl;
};

-- Helper funcs
local function Lighten(Color: Color3, Amount: number)
        return Color3.fromRGB(
                Color.R + Amount,
                Color.G + Amount,
                Color.B + Amount
        );
end

local function Tween(Object: GuiObject, Info: TweenInfo, Properties: {[string]: any})
        local tween = TweenService:Create(Object, Info, Properties);
        tween:Play();
        return tween;
end

local function New(ClassName: string, Properties: {[string]: any}?): Instance
        local instance = Instance.new(ClassName);

        if Properties then for Property, Value in Properties do
                pcall(function() instance[Property] = Value; end);
        end end

        return instance;
end

local function Connect(Signal: RBXScriptSignal, Callback: (...any) -> (...any), ...): RBXScriptConnection
        local Args = {...};
        local Wrapped = function()
                Callback(table.unpack(Args));
        end
        local Connection = Signal:Connect(Wrapped);
        table.insert(Library.Connections, Connection);
        return Connection;
end


-- GUI helper funcs
local function AddShadow(Object: GuiObject): ImageLabel
        local Shadow = New('ImageLabel', {
                Size = UDim2.new(1, 89, 1, 52);
                Position = UDim2.fromOffset(-48, -31);
                BackgroundTransparency = 1;
                Image = getcustomasset('vware/assets/shadow.png');
                ScaleType = Enum.ScaleType.Slice;
                SliceCenter = Rect.new(52, 31, 261, 502);
                Parent = Object;
        });

        return Shadow;
end

local function AddCorner(Object: GuiObject): UICorner
        local Corner = New('UICorner', {
                CornerRadius = UDim.new(0, 5);
                Parent = Object;
        });

        return Corner;
end

local function AddPadding(Object: GuiObject, Paddings: {[string]: number}): UIPadding
        local function getUdim(key)
                return UDim.new(0, Paddings[key] or 0);
        end

        local Padding = New('UIPadding', {
                PaddingBottom = getUdim('B');
                PaddingLeft = getUdim('L');
                PaddingRight = getUdim('R');
                Paddingtop = getUdim('T');
                Parent = Object;
        });

        return Padding;
end

-- GUI
local Container = New('ScreenGui', {
        Parent = (function()
                for _, try in {
                        function() return (gethui or get_hidden_gui)() end;
                        function() return cloneref(game:GetService('CoreGui')) end;
                        function() return cloneref(game:GetService('Players').LocalPlayer:WaitForChild('PlayerGui')) end;
                } do
                        local success, result = pcall(try);
                        if success then return result; end
                end
        end)();
});

local NotificationsFolder = New('Folder', {Parent = Container});

local Window = New('Frame', {
        AnchorPoint = centerPoint;
        Position = centerPos;
        Size = UDim2.fromOffset(400, 400);
        BackgroundColor3 = Library.Palette.Background;
        BorderSizePixel = 0;
        Parent = Container;
}) AddCorner(Window); AddShadow(Window);

local DragDetector = New('UIDragDetector', {Parent = Window});

local a = Library.Palette.Accent;
local TitleFrame = New('TextLabel', {
        Size = UDim2.new(1, 0, 0, 30);
        BorderSizePixel = 0;
        BackgroundColor3 = Lighten(Library.Palette.Background, 4);
        FontFace = Library.Palette.Font;
        TextSize = 14;
        RichText = true;
        TextColor3 = Color3.new(1, 1, 1);
        TextXAlignment = Enum.TextXAlignment.Left;
        Text = `v<font color="rgb({math.round(a.R * 255)}, {math.round(a.G * 255)}, {math.round(a.B * 255)})">ware</font>.dev`;
        Parent = Window;
}); AddCorner(TitleFrame); AddPadding(TitleFrame, {L = 10});

-- uicorner fix
New('Frame', {
        BackgroundColor3 = TitleFrame.BackgroundColor3;
        Position = UDim2.new(0, -10, 1, -5);
        Size = UDim2.new(1, 10, 0, 5);
        BorderSizePixel = 0;
        Parent = TitleFrame;
});

-- line
New('Frame', {
        BackgroundColor3 = Lighten(Library.Palette.Background, 14);
        BorderSizePixel = 0;
        Position = UDim2.new(0, -10, 1, 0);
        Size = UDim2.new(1, 10, 0, 1);
        Parent = TitleFrame;
})

function Library:Tab(name: string, icon: string?)

end

function Library:Notify(text: string, duration: number?)
        local index = #NotificationsFolder:GetChildren();
        local Ypos = (-40 * index) -10;

        local Notification = New('TextLabel', {
                BackgroundColor3 = Lighten(self.Palette.Background, 4);
                AnchorPoint = Vector2.new(1, 1);
                FontFace = self.Palette.Font;
                TextSize = 14;
                TextColor3 = Color3.new(1, 1, 1);
                RichText = true;
                Text = text;
                Parent = NotificationsFolder;
        }); AddCorner(Notification); AddShadow(Notification);
        Notification.Size = UDim2.fromOffset(Notification.TextBounds.X + 20, 30);
        local position = UDim2.new(1, Notification.Size.X.Offset * 2, 1, Ypos);
        Notification.Position = position;

        local tweenInfo = TweenInfo.new(.4, Enum.EasingStyle.Quart);

        Tween(Notification, tweenInfo, {Position = UDim2.new(1, -10, 1, Ypos)})

        task.delay(duration or 5, function()
                local tween = Tween(Notification, tweenInfo, {Position = position});
                Connect(tween.Completed, Notification.Destroy, Notification);
        end)
end

return Library;

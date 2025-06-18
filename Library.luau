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

local Library = {
        Palette = {
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
        return TweenService:Create(Object, Info, Properties):Play();
end

local function New(ClassName: string, Properties: {[string]: any}?): Instance
        local instance = Instance.new(ClassName);

        if Properties then for Property, Value in Properties do
                pcall(function() instance[Property] = Value; end);
        end end

        return instance;
end

local function Connect(Signal: RBXScriptSignal, Callback: (...any) -> (...any)): RBXScriptConnection
        local Connection = Signal:Connect(Callback);
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

local Window = New('Frame', {

});

function Library:Tab(name: string, icon: string?)

end

function Library:Notify(text: string, duration: number?)

end

return Library;

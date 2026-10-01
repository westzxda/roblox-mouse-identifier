local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MouseInspector"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.Parent = playerGui

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 500, 0, 300)
label.Position = UDim2.new(0, 20, 0, 20)
label.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
label.BackgroundTransparency = 0.15
label.BorderSizePixel = 2
label.BorderColor3 = Color3.fromRGB(0, 255, 150)
label.TextColor3 = Color3.fromRGB(0, 255, 150)
label.Font = Enum.Font.Code
label.TextSize = 13
label.TextWrapped = true
label.TextXAlignment = Enum.TextXAlignment.Left
label.TextYAlignment = Enum.TextYAlignment.Top
label.Visible = true
label.Parent = screenGui

-- ScrollingFrame pra melhor visualização
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, 0)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 8
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
scrollFrame.Parent = label

label:Destroy()
label = scrollFrame

local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, -16, 0, 500)
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
textLabel.Font = Enum.Font.Code
textLabel.TextSize = 13
textLabel.TextWrapped = true
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.TextYAlignment = Enum.TextYAlignment.Top
textLabel.Parent = scrollFrame

-- Função pra fazer raycast melhor
local function raycastFromMouse()
    local unitRay = camera:ScreenPointToRay(mouse.X, mouse.Y)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {playerGui}

    local rayResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, raycastParams)
    
    if rayResult then
        return rayResult.Instance
    end
    
    return nil
end

-- Função pra pegar UI sob o mouse
local function getUiUnderMouse()
    local x, y = mouse.X, mouse.Y
    local list = playerGui:GetGuiObjectsAtPosition(x, y)

    if #list == 0 then
        return nil
    end

    for _, gui in ipairs(list) do
        if gui.Name ~= "MouseInspector" then
            return gui
        end
    end

    return nil
end

local function formatValue(value)
    if value == nil then
        return "nil"
    elseif typeof(value) == "Color3" then
        return string.format("RGB(%d, %d, %d)", value.R * 255, value.G * 255, value.B * 255)
    elseif typeof(value) == "Vector3" then
        return string.format("(%.2f, %.2f, %.2f)", value.X, value.Y, value.Z)
    elseif typeof(value) == "Instance" then
        return value:GetFullName()
    else
        return tostring(value)
    end
end

local function getDetailedInfo(obj)
    if obj == nil then
        return "⚠️ Nada sob o mouse"
    end

    local lines = {}
    
    table.insert(lines, "═══════════════════════════════════")
    table.insert(lines, "📍 ALVO: " .. obj.Name)
    table.insert(lines, "📦 Classe: " .. obj.ClassName)
    table.insert(lines, "📁 Path: " .. obj:GetFullName())
    table.insert(lines, "═══════════════════════════════════")

    -- BasePart (3D Objects)
    if obj:IsA("BasePart") then
        table.insert(lines, "")
        table.insert(lines, "🎨 PROPRIEDADES 3D:")
        table.insert(lines, "  Material: " .. formatValue(obj.Material))
        table.insert(lines, "  Cor: " .. formatValue(obj.Color))
        table.insert(lines, "  Transparência: " .. formatValue(obj.Transparency))
        table.insert(lines, "  Reflectância: " .. formatValue(obj.Reflectance))
        table.insert(lines, "  Tamanho: " .. formatValue(obj.Size))
        table.insert(lines, "  Posição: " .. formatValue(obj.Position))
        
        if obj.TextureID ~= "" then
            table.insert(lines, "  🖼️  TextureID: " .. obj.TextureID)
        end

        -- Procurar Decals, Textures, Meshes
        table.insert(lines, "")
        table.insert(lines, "🔍 FILHOS (Texturas/Meshes):")
        local foundChildren = false
        
        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("Decal") then
                foundChildren = true
                table.insert(lines, "  📌 Decal:")
                table.insert(lines, "    ID: " .. child.Texture)
                table.insert(lines, "    Face: " .. tostring(child.Face))
                table.insert(lines, "    Transparência: " .. tostring(child.Transparency))
            elseif child:IsA("Texture") then
                foundChildren = true
                table.insert(lines, "  🎨 Texture:")
                table.insert(lines, "    ID: " .. child.Texture)
                table.insert(lines, "    StudsPerTileU: " .. tostring(child.StudsPerTileU))
            elseif child:IsA("SpecialMesh") then
                foundChildren = true
                table.insert(lines, "  🔷 SpecialMesh:")
                table.insert(lines, "    MeshId: " .. child.MeshId)
                table.insert(lines, "    TextureId: " .. child.TextureId)
                table.insert(lines, "    Scale: " .. formatValue(child.Scale))
            elseif child:IsA("SurfaceGui") then
                foundChildren = true
                table.insert(lines, "  🖥️  SurfaceGui:")
                table.insert(lines, "    Enabled: " .. tostring(child.Enabled))
            end
        end
        
        if not foundChildren then
            table.insert(lines, "  (Nenhum filho de textura/mesh)")
        end

    -- Decal
    elseif obj:IsA("Decal") then
        table.insert(lines, "")
        table.insert(lines, "📌 DECAL:")
        table.insert(lines, "  🖼️  Texture: " .. obj.Texture)
        table.insert(lines, "  Face: " .. tostring(obj.Face))
        table.insert(lines, "  Transparência: " .. formatValue(obj.Transparency))

    -- Texture
    elseif obj:IsA("Texture") then
        table.insert(lines, "")
        table.insert(lines, "🎨 TEXTURE:")
        table.insert(lines, "  🖼️  ID: " .. obj.Texture)
        table.insert(lines, "  StudsPerTileU: " .. tostring(obj.StudsPerTileU))
        table.insert(lines, "  StudsPerTileV: " .. tostring(obj.StudsPerTileV))

    -- SpecialMesh
    elseif obj:IsA("SpecialMesh") then
        table.insert(lines, "")
        table.insert(lines, "🔷 SPECIAL MESH:")
        table.insert(lines, "  🖼️  MeshId: " .. obj.MeshId)
        table.insert(lines, "  🎨 TextureId: " .. obj.TextureId)
        table.insert(lines, "  Scale: " .. formatValue(obj.Scale))
        table.insert(lines, "  Offset: " .. formatValue(obj.Offset))

    -- GUI Objects
    elseif obj:IsA("GuiObject") then
        table.insert(lines, "")
        table.insert(lines, "🖥️  PROPRIEDADES UI:")
        table.insert(lines, "  Posição: " .. formatValue(obj.AbsolutePosition))
        table.insert(lines, "  Tamanho: " .. formatValue(obj.AbsoluteSize))
        table.insert(lines, "  Visível: " .. tostring(obj.Visible))

        if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            table.insert(lines, "")
            table.insert(lines, "🖼️  IMAGE:")
            table.insert(lines, "  Image: " .. obj.Image)
            table.insert(lines, "  ImageTransparency: " .. tostring(obj.ImageTransparency))
            if obj:IsA("ImageButton") then
                table.insert(lines, "  ImageColor3: " .. formatValue(obj.ImageColor3))
            end
        end

        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            table.insert(lines, "")
            table.insert(lines, "📝 TEXTO:")
            table.insert(lines, "  Conteúdo: " .. obj.Text)
            table.insert(lines, "  Fonte: " .. tostring(obj.Font))
            table.insert(lines, "  TamanhoPx: " .. tostring(obj.TextSize))
        end

    -- Model
    elseif obj:IsA("Model") then
        table.insert(lines, "")
        table.insert(lines, "🏗️  MODEL:")
        
        local partsCount = 0
        local decalsCount = 0
        local meshCount = 0
        
        for _, child in ipairs(obj:GetDescendants()) do
            if child:IsA("BasePart") then
                partsCount = partsCount + 1
            elseif child:IsA("Decal") then
                decalsCount = decalsCount + 1
            elseif child:IsA("SpecialMesh") or child:IsA("Mesh") then
                meshCount = meshCount + 1
            end
        end
        
        table.insert(lines, "  Parts: " .. partsCount)
        table.insert(lines, "  Decals: " .. decalsCount)
        table.insert(lines, "  Meshes: " .. meshCount)
    end

    table.insert(lines, "")
    table.insert(lines, "═══════════════════════════════════")

    return table.concat(lines, "\n")
end

local function updateInspector()
    -- Tenta pegar via raycast (melhor pra bola e pequenos objetos)
    local targetRaycast = raycastFromMouse()
    
    -- Tenta pegar via mouse.Target (fallback)
    local targetMouse = mouse.Target
    
    -- Prioriza raycast, depois mouse.Target, depois UI
    local uiTarget = getUiUnderMouse()
    
    local target = targetRaycast or targetMouse or uiTarget
    
    if target then
        textLabel.Text = getDetailedInfo(target)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, textLabel.TextBounds.Y + 20)
    else
        textLabel.Text = "⚠️ Nada sob o mouse"
    end
end

-- Atualiza constantemente
mouse.Move:Connect(updateInspector)
task.spawn(function()
    while true do
        updateInspector()
        task.wait(0.05)
    end
end)

print("✅ Mouse Inspector iniciado! Mova o mouse sobre objetos pra ver detalhes.")
local ui = setupUI([[
Panel
  height: 19
  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('Scripts')
    font: verdana-11px-rounded

  Button
    id: settings
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup
    font: verdana-11px-rounded
]])

local st = "ScriptBot"
storage[st] = storage[st] or {
    enabled = false,
    scripts = {}
}
local config = storage[st]

local windowUI = setupUI([[
MainWindow
  size: 700 500
  text: IconScript
  style: iconwindow

  Label
    text: SCRIPTSLIST
    font: verdana-11px-rounded
    color: yellow
    anchors.top: parent.top
    anchors.left: parent.left
    margin-top: 20
    margin-left: 20

  TextList
    id: scriptsList
    size: 200 300
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 10
    margin-left: 20

  Label
    text: Config Here
    font: verdana-11px-rounded
    color: yellow
    anchors.top: parent.top
    anchors.left: scriptsList.right
    margin-top: 20
    margin-left: 20

  TextEdit
    id: configEdit
    multiline: true
    size: 200 100
    anchors.top: prev.bottom
    anchors.left: scriptsList.right
    margin-top: 10
    margin-left: 20

  Label
    text: Macro Name
    font: verdana-11px-rounded
    anchors.top: parent.top
    anchors.left: configEdit.right
    margin-top: 20
    margin-left: 20

  TextEdit
    id: macroNameEdit
    size: 100 20
    anchors.top: prev.bottom
    anchors.left: configEdit.right
    margin-top: 10
    margin-left: 20

  Label
    text: Milisegundos
    font: verdana-11px-rounded
    anchors.top: macroNameEdit.bottom
    anchors.left: configEdit.right
    margin-top: 10
    margin-left: 20

  TextEdit
    id: milisecondsEdit
    size: 100 20
    anchors.top: prev.bottom
    anchors.left: configEdit.right
    margin-top: 5
    margin-left: 20

  Label
    text: Script Here
    font: verdana-11px-rounded
    anchors.top: milisecondsEdit.bottom
    anchors.left: configEdit.right
    margin-top: 10
    margin-left: 20

  TextEdit
    id: scriptEdit
    multiline: true
    size: 200 100
    anchors.top: prev.bottom
    anchors.left: configEdit.right
    margin-top: 5
    margin-left: 20

  Label
    text: Item ID
    font: verdana-11px-rounded
    anchors.top: configEdit.bottom
    anchors.left: scriptsList.right
    margin-top: 10
    margin-left: 20

  TextEdit
    id: itemIdEdit
    size: 100 20
    anchors.top: prev.bottom
    anchors.left: scriptsList.right
    margin-top: 5
    margin-left: 20

  Label
    text: Icon Name
    font: verdana-11px-rounded
    anchors.top: itemIdEdit.bottom
    anchors.left: scriptsList.right
    margin-top: 10
    margin-left: 20

  TextEdit
    id: iconNameEdit
    size: 100 20
    anchors.top: prev.bottom
    anchors.left: scriptsList.right
    margin-top: 5
    margin-left: 20

  Label
    text: Link Icon
    font: verdana-11px-rounded
    anchors.top: iconNameEdit.bottom
    anchors.left: scriptsList.right
    margin-top: 10
    margin-left: 20

  TextEdit
    id: linkIconEdit
    size: 100 20
    anchors.top: prev.bottom
    anchors.left: scriptsList.right
    margin-top: 5
    margin-left: 20

  Label
    text: Pos X
    font: verdana-11px-rounded
    anchors.top: linkIconEdit.bottom
    anchors.left: scriptsList.right
    margin-top: 10
    margin-left: 20

  TextEdit
    id: posXEdit
    size: 40 20
    anchors.top: prev.bottom
    anchors.left: scriptsList.right
    margin-top: 5
    margin-left: 20

  Label
    text: Pos Y
    font: verdana-11px-rounded
    anchors.top: linkIconEdit.bottom
    anchors.left: posXEdit.right
    margin-top: 10
    margin-left: 10

  TextEdit
    id: posYEdit
    size: 40 20
    anchors.top: prev.bottom
    anchors.left: posXEdit.right
    margin-top: 5
    margin-left: 10

  Button
    id: addButton
    text: Adicionar
    size: 100 25
    anchors.top: scriptEdit.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    margin-top: 175

  Button
    id: removeButton
    text: Remover
    size: 100 25
    anchors.top: scriptEdit.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    margin-top: 100

  Button
    id: reloadButton
    text: Reload
    size: 100 25
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    margin-bottom: 10
    margin-left: 20

  Button
    id: closeButton
    text: Close
    size: 100 25
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    margin-bottom: 10
    margin-right: 20

]], g_ui.getRootWidget())

windowUI:hide()

local scripts = config.scripts

local function saveScripts()
    config.scripts = scripts
    storage[st] = config
end

local function loadScripts()
    windowUI.scriptsList:destroyChildren()
    for _, script in pairs(scripts) do
        local listItem = g_ui.createWidget('TextList', windowUI.scriptsList)
        listItem:setText("Script: " .. script.macroName)
        windowUI.scriptsList:addChild(listItem)
    end
end

local function downloadAndApply(urlImagen, loader)
    local function inDownloadImage(rutaArchivo, error)
        if error then
            warn("Erro ao baixar a Imagem " .. error)
            return
        else
            loader:setImageSource(rutaArchivo)
            loader:setWidth(50)
            loader:setHeight(50)
        end
    end

    HTTP.downloadImage(urlImagen, inDownloadImage)
end

local function createIcon(script)
    local macro = macro(tonumber(script.miliseconds), script.macroName, function()
        loadstring(script.script)()
    end)

    local iconWidget = addIcon(script.iconName, {item = tonumber(script.itemId), text = script.iconName}, macro)
    iconWidget:breakAnchors()
    iconWidget:move(tonumber(script.posX), tonumber(script.posY))
    iconWidget:setWidth(50)
    iconWidget:setHeight(50)
    
    if script.linkIcon and script.linkIcon ~= "" then
        downloadAndApply(script.linkIcon, iconWidget)
    end
    
    if script.config and script.config ~= "" then
        loadstring(script.config)()
    end
end

-- Carregar ícones ao iniciar
for _, script in ipairs(scripts) do
    createIcon(script)
end

-- Função para adicionar novo script e ícone
local function addScript()
    local config = windowUI.configEdit:getText()
    local itemId = windowUI.itemIdEdit:getText()
    local iconName = windowUI.iconNameEdit:getText()
    local linkIcon = windowUI.linkIconEdit:getText()
    local posX = windowUI.posXEdit:getText()
    local posY = windowUI.posYEdit:getText()
    local macroName = windowUI.macroNameEdit:getText()
    local miliseconds = windowUI.milisecondsEdit:getText()
    local script = windowUI.scriptEdit:getText()

    if iconName == "" or posX == "" or posY == "" or macroName == "" or miliseconds == "" or script == "" then
        warn("Preencha todos os campos obrigatórios.")
        return
    end

    local newScript = {
        config = config,
        itemId = itemId,
        iconName = iconName,
        linkIcon = linkIcon,
        posX = posX,
        posY = posY,
        macroName = macroName,
        miliseconds = miliseconds,
        script = script
    }

    table.insert(scripts, newScript)

    local listItem = g_ui.createWidget('TextList', windowUI.scriptsList)
    listItem:setText("Script: " .. macroName)
    windowUI.scriptsList:addChild(listItem)

    windowUI.configEdit:setText("")
    windowUI.itemIdEdit:setText("")
    windowUI.iconNameEdit:setText("")
    windowUI.linkIconEdit:setText("")
    windowUI.posXEdit:setText("")
    windowUI.posYEdit:setText("")
    windowUI.macroNameEdit:setText("")
    windowUI.milisecondsEdit:setText("")
    windowUI.scriptEdit:setText("")

    saveScripts()
    createIcon(newScript)
    warn("Script adicionado com sucesso.")
end

-- Função para remover script e ícone
local function removeScript()
    local selectedChild = windowUI.scriptsList:getFocusedChild()

    if not selectedChild then
        warn("Selecione um script para remover.")
        return
    end

    local scriptName = selectedChild:getText()
    local scriptIndex = nil

    for i, script in ipairs(scripts) do
        if "Script: " .. script.macroName == scriptName then
            scriptIndex = i
            break
        end
    end

    if scriptIndex then
        table.remove(scripts, scriptIndex)
        windowUI.scriptsList:removeChild(selectedChild)
        saveScripts()
        warn("Script removido com sucesso.")
    else
        warn("Erro ao encontrar o script para remover.")
    end
end

-- Botões e suas funções
ui.settings.onClick = function(widget)
    windowUI:show()
    windowUI:raise()
    windowUI:focus()
    loadScripts()
end

windowUI.closeButton.onClick = function(widget)
    windowUI:hide()
end

windowUI.reloadButton.onClick = function(widget)
    reload()
end

windowUI.addButton.onClick = addScript

windowUI.removeButton.onClick = removeScript

windowUI.scriptsList.onChildFocusChange = function(list, selectedChild)
    if selectedChild then
        for _, child in ipairs(list:getChildren()) do
            child:setColor("white")
        end
        selectedChild:setColor("yellow")
    end
end

-- Carregar scripts ao iniciar
loadScripts()

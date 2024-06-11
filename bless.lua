local ui = setupUI([[
Panel
  height: 19
  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('Bless')
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

local st = "BlessSystem"
storage[st] = storage[st] or {}
local config = storage[st]

local windowUI = setupUI([[
MainWindow
  size: 700 500
  text: Blessing System
  style: iconwindow

  Label
    text: Bless Command
    font: verdana-11px-rounded
    color: yellow
    anchors.top: parent.top
    anchors.left: parent.left
    margin-top: 20
    margin-left: 20

  TextEdit
    id: blessCommandEdit
    size: 200 30
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 10
    margin-left: 20

  Label
    text: Bless Not Money
    font: verdana-11px-rounded
    color: yellow
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 20
    margin-left: 20

  TextEdit
    id: blessNotMoneyEdit
    size: 200 30
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 10
    margin-left: 20

  Label
    text: Bless Money
    font: verdana-11px-rounded
    color: yellow
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 20
    margin-left: 20

  TextEdit
    id: blessMoneyEdit
    size: 200 30
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 10
    margin-left: 20

  Label
    text: Bless Price
    font: verdana-11px-rounded
    color: yellow
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 20
    margin-left: 20

  TextEdit
    id: blessPriceEdit
    size: 200 30
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 10
    margin-left: 20

  Label
    text: idGold
    font: verdana-11px-rounded
    color: yellow
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 20
    margin-left: 20

  TextEdit
    id: idGoldEdit
    size: 200 30
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 10
    margin-left: 20

  Label
    text: idDolar
    font: verdana-11px-rounded
    color: yellow
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 20
    margin-left: 20

  TextEdit
    id: idDolarEdit
    size: 200 30
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 10
    margin-left: 20

  Button
    id: closeButton
    text: Fechar
    size: 100 25
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    margin-bottom: 10
    margin-right: 20

]], g_ui.getRootWidget())

windowUI:hide()

ui.settings.onClick = function(widget)
    windowUI:show()
    windowUI:raise()
    windowUI:focus()
end

windowUI.closeButton.onClick = function(widget)
    windowUI:hide()
end

local CONFIG = {
    BLESS_COMMAND = {text = 'Comando para comprar a bless', ui = windowUI.blessCommandEdit, storageKey = 'blessCommand'}, -- Comando para comprar a bless
    BLESS_PRICE = {text = 'Preço da bless em golds', ui = windowUI.blessPriceEdit, storageKey = 'blessPrice'}, -- Preço da bless em golds
    BLESS_MONEY = {text = 'Mensagem se já tem bless', ui = windowUI.blessMoneyEdit, storageKey = 'blessMoney'}, -- Mensagem se já tem bless
    BLESS_NOTMONEY = {text = 'Mensagem se não tem gold suficiente', ui = windowUI.blessNotMoneyEdit, storageKey = 'blessNotMoney'}, -- Mensagem se não tem gold suficiente
    UPDATE_GOLD = false, -- Atualiza a quantidade de gold
    ID_GOLD = {text = 'ID do gold', ui = windowUI.idGoldEdit, storageKey = 'idGold'}, -- ID do gold
    ID_DOLLAR = {text = 'ID do dólar', ui = windowUI.idDolarEdit, storageKey = 'idDollar'},  -- ID do dólar
    TEXT_GOLD = 'Using one of ([0-9]+) gold bars...', -- Texto quando usa o gold
    NPC_NAME = '[NPC] Yama' -- Nome do NPC
}


-- Atribuindo valores aos TextEdits com base nas configurações
for key, value in pairs(CONFIG) do
    if type(value) == "table" and value.text ~= nil and value.storageKey ~= nil then
        value.ui:setText(storage.configValues[value.storageKey] or value.text)
        value.ui.onTextChange = function(widget, newText)
            storage.configValues[value.storageKey] = newText
        end
    end
end

-- Restante do script...

-- NÃO EDITE NADA ABAIXO DISSO.

storage.widgetPos = storage.widgetPos or {}
storage.configValues = storage.configValues or {}

local widgetConfig = [[
UIWidget
  background-color: black
  opacity: 0.8
  padding: 0 5
  focusable: true
  phantom: false
  draggable: true
  text-auto-resize: true
]]

local blessWidget = {}

for _, key in ipairs({'goldWidget', 'blessWidget'}) do
    blessWidget[key] = setupUI(widgetConfig, g_ui.getRootWidget())
    blessWidget[key]:setPosition(storage.widgetPos[key] or {0, 50})

    blessWidget[key].onDragEnter = function(widget, mousePos)
        if not modules.corelib.g_keyboard.isCtrlPressed() then
            return false
        end
        widget:breakAnchors()
        widget.movingReference = { x = mousePos.x - widget:getX(), y = mousePos.y - widget:getY() }
        return true
    end

    blessWidget[key].onDragMove = function(widget, mousePos, moved)
        local parentRect = widget:getParent():getRect()
        local x = math.min(math.max(parentRect.x, mousePos.x - widget.movingReference.x), parentRect.x + parentRect.width - widget:getWidth())
        local y = math.min(math.max(parentRect.y - widget:getParent():getMarginTop(), mousePos.y - widget.movingReference.y), parentRect.y + parentRect.height - widget:getHeight())
        widget:move(x, y)
        return true
    end

    blessWidget[key].onDragLeave = function(widget, pos)
        storage.widgetPos[key] = {}
        storage.widgetPos[key].x = widget:getX()
        storage.widgetPos[key].y = widget:getY()
        return true
    end
end

local goldCount = 0

onTextMessage(function(mode, text)
    if text:find(CONFIG.TEXT_GOLD) then
        goldCount = tonumber(text:match("%d+"))
        blessWidget['goldWidget']:setText('Golds: ' .. goldCount)
    end
end)

storage.haveBless = false

local blessScript = macro(100, "Bless", function()
    if not storage.haveBless then
        say(CONFIG.BLESS_COMMAND.ui:getText())
        delay(1000)
       blessWidget['blessWidget']:setText("Bless: OFF")
        blessWidget['blessWidget']:setColor("red")
    else
        blessWidget['blessWidget']:setText("Bless: ON")
        blessWidget['blessWidget']:setColor("green")
    end
end)

macro(1, function()
    if blessScript.isOff() then return end
    if CONFIG.UPDATE_GOLD then
        if findItem(tonumber(CONFIG.ID_GOLD.ui:getText())) and (not X or X <= os.time()) then
            use(tonumber(CONFIG.ID_GOLD.ui:getText()))
            delay(400)
            use(tonumber(CONFIG.ID_DOLLAR.ui:getText()))
            X = os.time() + 180
        end
    end
end)

onTextMessage(function(mode, text)
    if blessScript.isOff() then return end
    if text:lower():find(CONFIG.BLESS_NOTMONEY.ui:getText()) then
        storage.haveBless = false
    elseif text:lower():find(CONFIG.BLESS_MONEY.ui:getText()) then
        storage.haveBless = true
    end
end)

macro(200, function()
  local list = CaveBotList() 
  for index, child in ipairs(list:getChildren()) do
    if child.action == "goto" then
      -- Generate the label using the index
      local label = "goto" .. index
      
      -- Extract coordinates
      local x = child.value:split(",")[1]
      local y = child.value:split(",")[2]
      local z = child.value:split(",")[3]
      local p = {x=x, y=y, z=z}
      
      -- Get the tile
      local t = g_map.getTile(p)
      if t then
        -- Determine the color
        local color = child:isFocused() and "yellow" or "white"
        -- Set the label text on the tile
        t:setText(label, color)
      end
    end
  end
end)

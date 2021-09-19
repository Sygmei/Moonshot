function Local.Init(login, sprite, blinkingSize, placeholder)

    if login == nil then
        login = Nicknames[math.random(1, #Nicknames)];
    end
    print("i live")
    placeholder = placeholder or "";
    blinkingSize = blinkingSize or 0.6
    inputSprite = Engine.Scene:getSprite(sprite);
    fullLogin = login
    currentLogin = ""
    input_pos = inputSprite:getPosition():to(obe.Transform.Units.ScenePixels)
    input_size = inputSprite:getSize():to(obe.Transform.Units.ScenePixels)
    This.Sprite:setPosition(input_pos)
    This.Sprite:setSize(input_size)
    local screen_size = Engine.Window:getSize()
    canvas = obe.Canvas.Canvas(input_size.x, input_size.y)

    print("Input size", input_size.y)
    local fontSize = math.floor(input_size.y * 0.3)
    local fontPosX = input_size.x / 2;
    local fontPosY = input_size.y / 2 + 6;
    loginText = canvas:Text "login" {
        text = "",
        size = fontSize,
        color = obe.Graphics.Color.Gray,
        x = fontPosX,
        y = fontPosY,
        text = placeholder,
        align = {horizontal = "Center", vertical = "Center"}
    };
    selected = false

    cursorTimer = obe.Time.Chronometer()
    cursorTimer:setLimit(blinkingSize)
    printCursor = false
end

local function updateLogin(cursor)
    loginText.color = obe.Graphics.Color.Black;
    printCursor = cursor
    loginText.text = currentLogin .. (printCursor and "|" or "")
    diff = loginText.width - input_size.x
    if diff > 0 then
        loginText.x = -diff
    elseif loginText.x < 0 then
        loginText.x = 0
    end
    cursorTimer:start()
end

local function select()
    if selected then
        return
    end
    selected = true
    updateLogin(true)
end

local function unselect()
    if not selected then
        return
    end
    selected = false
    updateLogin(false)
    cursorTimer:stop()
end

function Object:check()
    if currentLogin == fullLogin then
        return true;
    else
        loginText.color = obe.Graphics.Color.Red;
    end
end

function Event.Cursor.Press(event)
    if inputSprite:contains(Engine.Cursor:getScenePosition()) then
        print("Select :D")
        select()
    else
        print("Unselect :(")
        unselect()
    end
end

function Event.Actions.Keyboard(event)
    if selected then
        if #currentLogin < #fullLogin then
            local length = #currentLogin
            currentLogin = currentLogin .. fullLogin:sub(length + 1, length + 1)
        end
        updateLogin(true)
    end
end

function Event.Keys.Backspace(event)
    if selected and event.state == obe.Input.InputButtonState.Pressed then
        if #currentLogin > 0 then
            local length = #currentLogin - 1
            currentLogin = currentLogin:sub(0, length)
        end
        updateLogin(true)
    end
end

function Event.Game.Render()
    canvas:render(This.Sprite);
end

function Event.Game.Update(dt)
    if selected and cursorTimer:over() then
        updateLogin(not printCursor)
    end
end

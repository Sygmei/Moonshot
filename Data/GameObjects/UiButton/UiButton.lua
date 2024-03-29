local Actions = {
    quit = function()
        os.exit();
    end,
    login = function()
        local login_input = Engine.Scene:getGameObject("login_input_go");
        local password_input = Engine.Scene:getGameObject("password_input_go");
        if login_input:check() and password_input:check() then
            Engine.Scene:loadFromFile("scenes://moonshot_dungeon_1.json.vili");
        end
    end
}

function Local.Init(x, y, width, height, name)
    Object.name = name;
    This.Sprite:loadTexture("Sprites/Ui/" .. name .. ".png");
    This.Sprite:setPosition(obe.Transform.UnitVector(x, y, obe.Transform.Units.ViewPercentage));
    This.Sprite:setSize(obe.Transform.UnitVector(width, height, obe.Transform.Units.ViewPercentage));
end

function Event.Actions.UiClick()
    print("Cursor", Engine.Cursor:getScenePosition());
    print("Button", This.Sprite:getPosition(), This.Sprite:getSize());
    if This.Sprite:contains(Engine.Cursor:getScenePosition()) then
        print("Clicked button", Object.name);
        Actions[Object.name]();
    end
end

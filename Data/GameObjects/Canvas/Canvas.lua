local canvas;

function Local.Init(zone, x, y)
    local zone = Engine.Scene:getGameObject(zone).Zone;
    This.Sprite:setPosition(zone:getPosition());
    This.Sprite:setSize(zone:getSize());
    local spriteSize = This.Sprite:getSize():to(obe.Transform.Units.ScenePixels);
    canvas = obe.Canvas.Canvas(spriteSize.x, spriteSize.y);
    local spritePos = This.Sprite:getPosition():to(obe.Transform.Units.ScenePixels);
    Object.text = canvas:Text "" {
        font = "Data/Fonts/SulphurPoint-Light.otf",
        x = x - spritePos.x,
        y = y - spritePos.y,
        unit = obe.Transform.Units.ScenePixels,
        align = {
            horizontal = "Center",
            vertical = "Center"
        },
        text = "",
        layer = 1,
        size = 110
    };
end

function Object:setText(text)
    Object.text.text =  text
end

function Object:removeText(text)
    if Object.text.text == text then
        Object.text.text =  ""
    end
end

function Event.Game.Render()
    canvas:render(This.Sprite);
end
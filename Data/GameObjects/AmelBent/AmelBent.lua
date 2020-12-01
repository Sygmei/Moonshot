function Local.Init(x, y)
    This.Sprite:hide();
    This.Sprite:setPosition(obe.Transform.UnitVector(x, y, obe.Transform.Units.ScenePixels), obe.Transform.Referential.Bottom);
    Object.sound = Engine.Audio:load(obe.System.Path("Sounds/invalid.ogg"), obe.Audio.LoadPolicy.Cache);
end

function Object:success()
    if Engine.Scene:getGameObject("gameManager").puzzle_pieces >= 6 then
        This.Sprite:show();
    else
        Object.sound:play();
    end
end

function Object:failure()
    This.Sprite:hide();
end
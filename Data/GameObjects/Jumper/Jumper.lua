Object.active = false;

function Local.Init(x, y, angle, speed, state)
    Object.sound = Engine.Audio:load(
        obe.System.Path("Sounds/airboost.ogg"), obe.Audio.LoadPolicy.Cache
    );
    Object.sound:setVolume(1.0);
    Object.active = state or false;
    Object.angle = angle or 90;
    Object.speed = speed or 7;
    This.Sprite:setPosition(
        obe.Transform.UnitVector(x, y, obe.Transform.Units.ScenePixels) -
            obe.Transform.UnitVector(0, This.Sprite:getSize().y), obe.Transform.Referential.TopLeft
    );
    if not Object.active then
        This.Sprite:setColor(obe.Graphics.Color(255, 255, 255, 50));
    end
end

function Object:success()
    Object.active = true;
    This.Sprite:setColor(obe.Graphics.Color.White);
end

function Object:failure()
    Object.active = false;
    This.Sprite:setColor(obe.Graphics.Color(255, 255, 255, 50));
end

function Object:use()
    This.Animator:setKey("jump");
    Object.sound:play();
end

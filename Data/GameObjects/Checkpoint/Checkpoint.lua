Object.active = false;

function Local.Init(x, y)
    Object.enabled = false;
    Object.SceneNode = This.SceneNode;
    This.Sprite:setPosition(obe.Transform.UnitVector(0, 0), obe.Transform.Referential.Center);
    This.SceneNode:setPosition(obe.Transform.UnitVector(x, y, obe.Transform.Units.ScenePixels));
end

local ROTATION_SPEED = 180;

function Event.Game.Update(event)
    This.Sprite:rotate(event.dt * ROTATION_SPEED);
end

function Object:enable()
    Object.enabled = true;
    This.Sprite:setColor(obe.Graphics.Color.Green);
end

function Object:disable()
    Object.enabled = false;
    This.Sprite:setColor(obe.Graphics.Color.White);
end

Object.active = false;

function Local.Init(x, y, name)
    local loot_info = LOOT_DB[name];
    Object.effect = loot_info.effect;
    Object.active = true;
    This.Sprite:loadTexture(loot_info.image);
    This.Sprite:setPosition(obe.Transform.UnitVector(x, y, obe.Transform.Units.ScenePixels), obe.Transform.Referential.Center);

    Object.base_position = This.Sprite:getPosition();
    Object.from_position = Object.base_position.y;
    Object.to_position = Object.from_position + 0.1;
    Object.tween = obe.Animation.ValueTweening(Object.from_position, Object.to_position, 1);
    Object.tween:ease(obe.Animation.Easing.InOutQuint);

    Object.direction = 1;
end

local SPEED = 0.1;
local DURATION = 1;

function Event.Game.Update(event)
    if not Object.active then
        return;
    end
    local result = Object.tween:step(event.dt);
    This.Sprite:setPosition(obe.Transform.UnitVector(Object.base_position.x, result));
    if Object.direction == 1 and This.Sprite:getPosition().y >= Object.to_position then
        Object.tween = obe.Animation.ValueTweening(Object.to_position, Object.from_position, DURATION);
        Object.tween:ease(obe.Animation.Easing.InOutQuint);
        Object.direction = -1;
    elseif Object.direction == -1 and This.Sprite:getPosition().y <= Object.from_position then
        Object.tween = obe.Animation.ValueTweening(Object.from_position, Object.to_position, DURATION);
        Object.tween:ease(obe.Animation.Easing.InOutQuint);
        Object.direction = 1;
    end
end
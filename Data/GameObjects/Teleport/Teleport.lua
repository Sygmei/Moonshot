local character;
local active = true;

function Local.Init(x, y, destination)
    Object.position = obe.Transform.UnitVector(x, y, obe.Transform.Units.ScenePixels):to(
        obe.Transform.Units.SceneUnits
    );
    Object.destination = destination;

    character = Engine.Scene:getGameObject("character");
end

local DISTANCE_THRESHOLD = 0.4;

function Event.Game.Update(event)
    if not active then
        return;
    end
    if character.Collider:getCentroid():distance(Object.position) < DISTANCE_THRESHOLD then
        Engine.Scene:loadFromFile(Object.destination);
    end
end

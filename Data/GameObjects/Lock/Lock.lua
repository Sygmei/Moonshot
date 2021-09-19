local character;
local active = true;

function Local.Init(x, y, key, gate)
    Object.position = obe.Transform.UnitVector(x, y, obe.Transform.Units.ScenePixels):to(
        obe.Transform.Units.SceneUnits
    );
    Object.key = key;
    Object.gate = Engine.Scene:getGameObject(gate);
    Object.sound = Engine.Audio:load(
        obe.System.Path("Sounds/unlock.ogg"), obe.Audio.LoadPolicy.Cache
    );

    character = Engine.Scene:getGameObject("character");
end

local DISTANCE_THRESHOLD = 0.4;

function Event.Game.Update(event)
    if not active then
        return;
    end
    if character.Collider:getCentroid():distance(Object.position) < DISTANCE_THRESHOLD then
        print("Lock detection occured");
        if character.keys[Object.key] then
            print("OPENING GATE");
            Object.gate:open();
            Object.sound:play();
            active = false;
        end
    end
end

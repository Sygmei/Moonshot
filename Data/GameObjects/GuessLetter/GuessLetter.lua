function Local.Init(x, y, cluster, letter)
    Object.letter = letter;
    Object.cluster = Engine.Scene:getGameObject(cluster);
    Object.index = Object.cluster:addTarget(Object);
    print("GuessLetter", x, y, letter)
    local sprite_size = This.Sprite:getSize();
    This.Sprite:setPosition(obe.Transform.UnitVector(0, 0), obe.Transform.Referential.Center);
    local base_position = obe.Transform.UnitVector(x, y, obe.Transform.Units.ScenePixels);
    base_position = base_position + obe.Transform.UnitVector(sprite_size.x / 2, -sprite_size.y / 2);
    This.SceneNode:setPosition(base_position);
    Object.sound = Engine.Audio:load(obe.System.Path("Sounds/keystroke.ogg"), obe.Audio.LoadPolicy.Cache);
    Object.character = Engine.Scene:getGameObject("character");
end

function Event.Actions.Keyboard(event)
    local distance_from_character = This.SceneNode:getPosition():distance(Object.character.Collider:getCentroid());
    print(Object.letter, "distance from character", distance_from_character);
    if distance_from_character > 2 then
        print("Too far, exitting", Object.letter);
        return;
    end
    print("Get involved buttons");
    local pressed_key;
    for k, v in pairs(event.action:getInvolvedButtons()) do
        if v:isPressed() then
            pressed_key = v:getName();
            break;
        end
    end
    print("Comparing", pressed_key, Object.letter);
    if pressed_key == Object.letter then
        print("Triggering cluster", Object.letter);
        Object:hit();
    end
end

function Object:hit()
    print("Hit key", Object.id);
    This.Sprite:setColor(obe.Graphics.Color(100, 100, 255));
    scheduleBackToNormal();
    Object.sound:play();
    if Object.cluster == nil then
        return
    end
    Object.cluster:targetHit(Object.index)
end

function Object:setCluster(cluster, index)
    Object.cluster = cluster
    Object.index = index
end

function scheduleBackToNormal()
    Engine.Events:schedule():after(2):run(function()
        This.Sprite:setColor(obe.Graphics.Color.White);
    end);
end

function Object:success()
    if Object.cluster == nil then
        return
    end
    This.Sprite:setColor(obe.Graphics.Color(100, 255, 100));
    scheduleBackToNormal();
end

function Object:failure()
    if Object.cluster == nil then
        return
    end
    This.Sprite:setColor(obe.Graphics.Color.Red);
    scheduleBackToNormal();
end
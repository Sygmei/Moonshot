function Local.Init(x, y, cluster, hits, rotation)
    Object.cluster = Engine.Scene:getGameObject(cluster);
    Object.index = Object.cluster:addTarget(Object);
    print("Target", x, y)
    local sprite_size = This.Sprite:getSize();
    This.Sprite:setPosition(obe.Transform.UnitVector(0, 0), obe.Transform.Referential.Center);
    local base_position = obe.Transform.UnitVector(x, y, obe.Transform.Units.ScenePixels);
    base_position = base_position + obe.Transform.UnitVector(sprite_size.x / 2, -sprite_size.y / 2);
    if rotation then
        This.Sprite:setRotation(-rotation, obe.Transform.Referential.TopLeft);
        if rotation == 90 then
            This.Sprite:move(obe.Transform.UnitVector(0, This.Sprite:getSize().y));
        end
    end
    This.Collider:setPositionFromCentroid(This.Sprite:getPosition(obe.Transform.Referential.Center));
    This.SceneNode:setPosition(base_position);
    Object.hits = hits or 1;
    Object.currentHit = 0;
    Object.sound = Engine.Audio:load(
        obe.System.Path("Sounds/impact.ogg"), obe.Audio.LoadPolicy.Cache
    );
end

function Object:hit()
    print("Hit target", Object.id);
    This.Sprite:setColor(obe.Graphics.Color(100, 100, 255));
    scheduleBackToNormal();
    Object.sound:play();
    if Object.cluster == nil then
        return
    end
    Object.currentHit = Object.currentHit + 1
    if Object.currentHit >= Object.hits then
        Object.cluster:targetHit(Object.index)
    end
end

function Object:setCluster(cluster, index)
    Object.cluster = cluster
    Object.index = index
end

function scheduleBackToNormal()
    Engine.Events:schedule():after(2):run(
        function()
            This.Sprite:setColor(obe.Graphics.Color.White);
        end
    );
end

function Object:success()
    if Object.cluster == nil then
        return
    end
    Object.currentHit = 0
    This.Sprite:setColor(obe.Graphics.Color(100, 255, 100));
    scheduleBackToNormal();
end

function Object:failure()
    if Object.cluster == nil then
        return
    end
    Object.currentHit = 0;
    This.Sprite:setColor(obe.Graphics.Color.Red);
    scheduleBackToNormal();
end

local NORMAL_SPEED = 6
local ORBIT_SPEED = 1
local SPEED = NORMAL_SPEED -- pxl/s
local LIFETIME = 10;

State = {FREE = 0, ATTRACTED = 1, ORBIT = 2}

local targets;
local moon;
local lifetime = 0;
local MAX_LIFETIME = 3;

Object.inactive = true;

function Local.Init(x, y, vecInit, through_bridge)
    local TILES = Engine.Scene:getTiles();
    local tile_size = obe.Transform.UnitVector(
        TILES:getWidth() * TILES:getTileWidth(), TILES:getHeight() * TILES:getTileHeight(),
            obe.Transform.Units.ScenePixels
    ):to(obe.Transform.Units.SceneUnits);
    Object.bounds = obe.Transform.Rect();
    Object.bounds:setSize(tile_size);
    Object.clock = 0;
    Object.inactive = false;
    Object.through_bridge = through_bridge or false;
    targets = {}
    discoverTargets()
    center = {x = x, y = y}
    oldCenter = {x = x, y = y}
    vecUnit = Vector2(vecInit.x, vecInit.y):normalize()
    while vecUnit == 0 do
        x = (obe.Utils.Math.randint(0, 1) * 2 - 1) * obe.Utils.Math.randfloat()
        y = (obe.Utils.Math.randint(0, 1) * 2 - 1) * obe.Utils.Math.randfloat()
        vecUnit = Vector2(x, y):normalize()
    end
    This.SceneNode:setPosition(obe.Transform.UnitVector(x, y), obe.Transform.Referential.Center)

    t = 0
    state = State.FREE
    direction = 1
    if vecUnit ~= 0 then
        checkAttraction()
        checkOrbit()
    end

    This.Collider:addTag(obe.Collision.ColliderTagType.Rejected, "Character");
    This.Collider:addTag(obe.Collision.ColliderTagType.Rejected, "Projectile");
    if through_bridge then
        This.Collider:addTag(obe.Collision.ColliderTagType.Rejected, "Bridge");
    end
end

function discoverTargets()
    for k, v in pairs(Engine.Scene:getAllGameObjects()) do
        if v.Collider ~= nil and v.Collider:doesHaveTag(obe.Collision.ColliderTagType.Tag, "Target") then
            table.insert(targets, v);
        end
    end
end

function getMoons()
    return Engine.Scene:getAllGameObjects("Moon");
end

function checkAttraction()
    if state == State.FREE then
        for i, m in pairs(getMoons()) do
            if m == moon then
                if m:active() and not m:captive(center.x, center.y) then
                    moon = nil
                end
            elseif m:captive(center.x, center.y) then
                state = State.ATTRACTED
                moon = m
                direction = moon:getDirection(center.x, center.y, vecUnit)
                ramp = moon:getRampCircle(center.x, center.y, vecUnit, direction)
                if ramp.circle ~= nil then
                    t = 0
                    initialAngle = moon:getAngle(center.x, center.y, ramp.circle)
                end
                if ramp.inverse then
                    direction = -direction
                end
            end
        end
    end
end

function checkOrbit()
    if state == State.ATTRACTED and moon:orbit(center.x, center.y) then
        state = State.ORBIT
        t = 0
        initialAngle = moon:getAngle(center.x, center.y)
        if ramp.inverse then
            direction = -direction
        end
    end
end

local function followCircle(circle, dt)
    local angularSpeed = SPEED / circle.radius;
    local angularVelocity = direction * angularSpeed;
    t = t + dt
    center.x = circle.radius * math.cos(t * angularVelocity + initialAngle) + circle.x
    center.y = circle.radius * math.sin(t * angularVelocity + initialAngle) + circle.y
end

function Object:delete()
    This.Sprite:setVisible(false);
    Object.inactive = true;
end

function Event.Game.Update(event)
    if Object.inactive then
        return;
    end
    Object.clock = Object.clock + event.dt;
    if Object.clock > LIFETIME then
        Object:delete();
    end

    if state == State.ORBIT then
        SPEED = ORBIT_SPEED;
    else
        SPEED = NORMAL_SPEED;
    end

    This.Sprite:rotate(SPEED * event.dt * 180, obe.Transform.Referential.Center);
    if moon ~= nil and not moon:active() then
        state = State.FREE
        vecUnit = Vector2(center.x - oldCenter.x, center.y - oldCenter.y):normalize()
    end
    oldCenter = {x = center.x, y = center.y}
    if state == State.ORBIT then
        local orbitPos = moon:getPosition()
        local orbitRadius = moon:getOrbitRadius()
        followCircle({radius = orbitRadius, x = orbitPos.x, y = orbitPos.y}, event.dt)
    elseif state == State.ATTRACTED and ramp.circle ~= nil then
        followCircle(ramp.circle, event.dt)
        checkOrbit()
    else
        center.x = center.x + vecUnit.x * SPEED * event.dt;
        center.y = center.y + vecUnit.y * SPEED * event.dt
        if state == State.ATTRACTED then
            checkOrbit()
        else
            checkAttraction()
        end
    end
    for _, target in pairs(targets) do
        local offset = obe.Transform.UnitVector(center.x - oldCenter.x, center.y - oldCenter.y);
        local max_dist_before_collision = This.Collider:getMaximumDistanceBeforeCollision(
            target.Collider, offset
        );

        if max_dist_before_collision ~= offset then
            print("Target hit", target.Collider:getCentroid());
            print("Positions center", center.x, center.y);
            print("Old position", oldCenter.x, oldCenter.y);
            target:hit()
            -- TODO: Fix this shit
            This.SceneNode:setPosition(
                obe.Transform.UnitVector(
                    0, 0, obe.Transform.Units.ScenePixels
                ), obe.Transform.Referential.Center
            )
            Object.inactive = true;
            return
        end
    end
    local collisions = This.Collider:getMaximumDistanceBeforeCollision(
                           obe.Transform.UnitVector(
            center.x - oldCenter.x, center.y - oldCenter.y
        )
                       ).colliders;
    if #collisions ~= 0 then
        This.Sprite:setVisible(false);
        Object.inactive = true;
    end
    local next_position = obe.Transform.UnitVector(center.x, center.y);
    if not Object.bounds:contains(next_position) then
        Object:delete();
    else
        This.SceneNode:setPosition(next_position, obe.Transform.Referential.Center);
    end
end

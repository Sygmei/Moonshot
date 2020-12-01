function getAllZones()
    local zoneObjects = Engine.Scene:getAllGameObjects("CameraZone");
    local zones = {};
    for _, zone in pairs(zoneObjects) do
        local clamp = zone.Clamp;
        for k, v in pairs({"x_min", "y_min", "x_max", "y_max"}) do
            if clamp[v] == nil then
                clamp[v] = Object.base_clamps[v];
            end
        end
        zones[zone.id] = {
            rect = zone.Zone,
            clamp = clamp,
            use_max = zone.use_max
        };
    end
    print(inspect(zones));
    return zones;
end

function detectZone()
    for zoneName, zone in pairs(Object.zones) do
        if zone.rect:contains(Object.actor:getCentroid()) then
            -- print("Inside", zoneName);
            Object.current_zone = zone;
            return;
        end
    end
    Object.current_zone = nil;
end

function scaleCamera()
    if Object.current_zone == nil then
        Object.target_scale = 1;
    else
        local window_size = Engine.Window:getSize();
        local window_ratio = window_size.x / window_size.y;
        local comp_func = math.min;
        if Object.current_zone.use_max then
            comp_func = math.max;
        end
        Object.target_scale = comp_func(Object.current_zone.rect.width / window_ratio, Object.current_zone.rect.height) / 2;
    end
end

function setClamps()
    if Object.current_zone == nil then
        Object.clamps = Object.base_clamps;
    else
        Object.clamps = Object.current_zone.clamp
    end
end

function Local.Init(actor, clamp_x_min, clamp_y_min, clamp_x_max, clamp_y_max)
    Object.current_scale = 1;
    Object.target_scale = 1;
    if actor then
        Object.actor = Engine.Scene:getCollider(actor);
    end
    Object.base_clamps = {
        x_min = clamp_x_min,
        y_min = clamp_y_min,
        x_max = clamp_x_max,
        y_max = clamp_y_max
    };
    Object.clamps = Object.base_clamps;
    if Object.actor then
        Engine.Scene:getCamera():setPosition(Object.actor:getCentroid(), obe.Transform.Referential.Center);
    end
    Object.zones = getAllZones();
    Object.base_parallax_sizes = {};
    for _, sprite in pairs(Engine.Scene:getAllSprites()) do
        if sprite:getPositionTransformer():getXTransformerName() == "Parallax" or sprite:getPositionTransformer():getXTransformerName() == "Position"  then
            Object.base_parallax_sizes[sprite:getId()] = sprite:getSize();
        end
    end
end

local CAMERA_SPEED = 4;
local CAMERA_SMOOTH = true;

function Event.Game.Update(event)
    print("Frame time / rate", event.dt, 1 / event.dt);
    if Object.actor == nil then
        return;
    end
    if CAMERA_SMOOTH then
        local current_camera_position = Engine.Scene:getCamera():getPosition(obe.Transform.Referential.Center);
        local actor_position = Object.actor:getCentroid();
        local new_position = (actor_position - current_camera_position) * CAMERA_SPEED * event.dt;
        Engine.Scene:getCamera():move(new_position);
    else
        Engine.Scene:getCamera():setPosition(Object.actor:getCentroid(), obe.Transform.Referential.Center);
    end
    local current_camera_position = Engine.Scene:getCamera():getPosition(obe.Transform.Referential.Center);
    local camera_center = Engine.Scene:getCamera():getPosition(obe.Transform.Referential.Center);
    local camera_topleft = Engine.Scene:getCamera():getPosition(obe.Transform.Referential.TopLeft);
    local camera_bottomright = Engine.Scene:getCamera():getPosition(obe.Transform.Referential.BottomRight);
    if Object.clamps.x_min ~= nil and camera_topleft.x < Object.clamps.x_min then
        current_camera_position.x = Object.clamps.x_min + (camera_center.x - camera_topleft.x);
    elseif Object.clamps.x_max ~= nil and camera_bottomright.x > Object.clamps.x_max then
        current_camera_position.x = Object.clamps.x_max + (camera_center.x - camera_bottomright.x);
    end
    if Object.clamps.y_min ~= nil and camera_topleft.y < Object.clamps.y_min then
        current_camera_position.y = Object.clamps.y_min + (camera_center.y - camera_topleft.y);
    elseif Object.clamps.y_max ~= nil and camera_bottomright.y > Object.clamps.y_max then
        current_camera_position.y = Object.clamps.y_max + (camera_center.y - camera_bottomright.y);
    end
    Engine.Scene:getCamera():setPosition(current_camera_position, obe.Transform.Referential.Center);

    detectZone();
    scaleCamera();
    setClamps();
    Object.current_scale = Object.current_scale + (Object.target_scale - Object.current_scale) * CAMERA_SPEED * event.dt
    -- Engine.Scene:getCamera():setSize(Object.target_scale, obe.Transform.Referential.Center);
    Engine.Scene:getCamera():setSize(Object.current_scale, obe.Transform.Referential.Center);
    allSprites = Engine.Scene:getAllSprites()
    for _, sprite in pairs(allSprites) do
        if sprite:getPositionTransformer():getXTransformerName() == "Parallax" or sprite:getPositionTransformer():getXTransformerName() == "Position" then
            local base_size = Object.base_parallax_sizes[sprite:getId()];
            sprite:setSize(base_size*Object.current_scale);
        end
    end
end

function Event.Actions.ToggleCameraSmoothing()
    CAMERA_SMOOTH = not CAMERA_SMOOTH;
end
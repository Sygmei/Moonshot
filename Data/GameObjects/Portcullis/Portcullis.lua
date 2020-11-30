local PORTCULLIS_TILESET_FIRST_TILE_ID;

local PORTCULLIS_CLOSE_TILE_ID;
local PORTCULLIS_OPEN_TILE_ID;
local PORTCULLIS_TOP_TILE_ID;
local PORTCULLIS_MIDDLE_TILE_ID;
local PORTCULLIS_BOTTOM_TILE_ID;

function setPortcullisState(enabled)
    local new_state = Object.state ~= enabled;
    local max_x = Object.tile_x + Object.portcullis_width - 1;
    local max_y = Object.tile_y + Object.portcullis_height - 1;
    for x = Object.tile_x, max_x, 1 do
        for y = Object.tile_y, max_y, 1 do
            Engine.Scene:getTiles():getLayer("Items"):setTile(x, y, 0);
            Engine.Scene:getTiles():getLayer("Items_front"):setTile(x, y, 0);
        end
    end
    for x = Object.tile_x, max_x, 1 do
        for y = Object.tile_y, max_y, 1 do
            local tile_id = 0;
            local layer_id = "Items";

            if new_state then
                if y == Object.tile_y and y ~= max_y then
                    tile_id = PORTCULLIS_TOP_TILE_ID;
                elseif y == max_y then
                    layer_id = "Items_front"
                    tile_id = PORTCULLIS_BOTTOM_TILE_ID;
                else
                    tile_id = PORTCULLIS_MIDDLE_TILE_ID;
                end
            else
                if y == Object.tile_y and y ~= max_y then
                    print("CLCL", y, Object.tile_y, max_y);
                    tile_id = PORTCULLIS_BOTTOM_TILE_ID;
                end
            end
            print("Setting", x, y, layer_id, tile_id);
            Engine.Scene:getTiles():getLayer(layer_id):setTile(x, y, tile_id);
        end
    end
end

function endState()
    Event.Game.Update = nil;
    Object.clock = 0;
    Object.step = 0;
end

local STEP_SPEED = 0.2;

function openPortculis(event)
    Object.clock = Object.clock + event.dt;
    if Object.clock < STEP_SPEED then
        return;
    end
    Object.clock = 0;
    local max_x = Object.tile_x + Object.portcullis_width - 1;
    local max_y = Object.tile_y + Object.portcullis_height - 1;
    local current_y = max_y - Object.step;
    local old_y = nil;
    if Object.step ~= 0 then
        old_y = max_y - Object.step + 1;
    end

    for x = Object.tile_x, max_x, 1 do
        Engine.Scene:getTiles():getLayer("Items"):setTile(x, current_y, 0);
        Engine.Scene:getTiles():getLayer("Items_front"):setTile(x, current_y, PORTCULLIS_OPEN_TILE_ID);
        print("OPEN", current_y);
        if old_y then
            Engine.Scene:getTiles():getLayer("Items_front"):setTile(x, old_y, 0);
            print("CLEAR", old_y);
        end
    end

    Object.step = Object.step + 1;
    if Object.step >= Object.portcullis_height then
        for x = Object.tile_x, max_x, 1 do
            Engine.Scene:getTiles():getLayer("Items"):setTile(x, current_y, PORTCULLIS_BOTTOM_TILE_ID);
            Engine.Scene:getTiles():getLayer("Items_front"):setTile(x, current_y, 0);
        end
        endState();
    end
end

function closePortculis(event)
    Object.clock = Object.clock + event.dt;
    if Object.clock < STEP_SPEED then
        return;
    end
    Object.clock = 0;
    local max_x = Object.tile_x + Object.portcullis_width - 1;
    local current_y = Object.tile_y + Object.step;
    local old_y = nil;
    if Object.step ~= 0 then
        old_y = Object.tile_y + Object.step - 1;
    end

    for x = Object.tile_x, max_x, 1 do
        Engine.Scene:getTiles():getLayer("Items"):setTile(x, current_y, 0);
        Engine.Scene:getTiles():getLayer("Items_front"):setTile(x, current_y, PORTCULLIS_CLOSE_TILE_ID);
        print("OPEN", current_y);
        if old_y then
            Engine.Scene:getTiles():getLayer("Items_front"):setTile(x, old_y, 0);
            Engine.Scene:getTiles():getLayer("Items"):setTile(x, old_y, PORTCULLIS_MIDDLE_TILE_ID);
            print("STABILIZE", old_y);
        end
    end

    Object.step = Object.step + 1;
    if Object.step >= Object.portcullis_height then
        for x = Object.tile_x, max_x, 1 do
            print("CLOSE", current_y)
            Engine.Scene:getTiles():getLayer("Items_front"):setTile(x, current_y, PORTCULLIS_BOTTOM_TILE_ID);
            Engine.Scene:getTiles():getLayer("Items"):setTile(x, current_y, 0);
        end
        endState();
    end
end

function Local.Init(x, y, width, height, state)
    local PORTCULLIS_TILESET_FIRST_TILE_ID = Engine.Scene:getTiles():getTilesets():tilesetFromId("portcullis"):getFirstTileId();

    PORTCULLIS_CLOSE_TILE_ID = PORTCULLIS_TILESET_FIRST_TILE_ID + 1;
    PORTCULLIS_OPEN_TILE_ID = PORTCULLIS_TILESET_FIRST_TILE_ID + 5;
    PORTCULLIS_TOP_TILE_ID = PORTCULLIS_TILESET_FIRST_TILE_ID + 0;
    PORTCULLIS_MIDDLE_TILE_ID = PORTCULLIS_TILESET_FIRST_TILE_ID + 2;
    PORTCULLIS_BOTTOM_TILE_ID = PORTCULLIS_TILESET_FIRST_TILE_ID + 4;
    print("Portcullis initialized");
    Object.state = state or false;
    Object.clock = 0;
    Object.step = 0;

    local tile_width = Engine.Scene:getTiles():getTileWidth();
    local tile_height = Engine.Scene:getTiles():getTileHeight();
    Object.tile_x = math.floor(x / tile_width);
    Object.tile_y = math.floor(y / tile_height);

    Object.portcullis_width = math.floor(width / tile_width);
    Object.portcullis_height = math.floor(height / tile_height);

    setPortcullisState(false);
end

function Object:success()
    print("Activating Portcullis");
    --[[if Object.state then
        Event.Game.Update = openPortculis;
        Object.state = false;
    else
        Event.Game.Update = closePortculis;
        Object.state = true;
    end]]
    Event.Game.Update = openPortculis;
    -- setPortcullisState(true);
end

function Object:failure()
end
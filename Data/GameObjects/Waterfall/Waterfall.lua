local WATERFALL_TILE_ID = {
    FALLING_LEFT = 0,
    FALLING_MIDDLE = 1,
    FALLING_RIGHT = 2,
    LEFT = 12,
    MIDDLE = 13,
    RIGHT = 14,
    BOTTOM_LEFT = 21,
    BOTTOM_MIDDLE = 22,
    BOTTOM_RIGHT = 23
}

local ANIMATION_TIME = 0.2;


function Local.Init(x, y, width, height)
    print("Waterfall initialized");

    Object.clock = ANIMATION_TIME;

    local tile_width = Engine.Scene:getTiles():getTileWidth();
    local tile_height = Engine.Scene:getTiles():getTileHeight();
    Object.tile_x = math.floor(x / tile_width);
    Object.tile_y = math.floor(y / tile_height);

    Object.waterfall_width = math.floor(width / tile_width);
    Object.waterfall_height = math.floor(height / tile_height);
    Object.state = false
end

function waterfall(event)
    Object.clock = Object.clock + event.dt;
    if Object.clock < ANIMATION_TIME then
        return;
    end
    Object.clock = 0;
    local max_x = Object.tile_x + Object.waterfall_width - 1;
    local current_y = Object.tile_y + Object.waterfall_height - 1;
    local new_y = current_y + 1;

    local prefix = "";
    local tile_id = Engine.Scene:getTiles():getLayer("Items"):getTile(Object.tile_x, current_y);
    local bridge_id_offset = Engine.Scene:getTiles():getTilesets():tilesetFromId("bridge_rock"):getFirstTileId();
    if tile_id >= bridge_id_offset and tile_id <= bridge_id_offset + 2 then
        print("stop the floow", current_y, tile_id, bridge_id_offset)
        prefix = "BOTTOM_";
        Object.state = false
        Object.clock = ANIMATION_TIME
    else
        Object.waterfall_height = Object.waterfall_height + 1;
    end
    local WATERFALL_SPRITESHEET_OFFSET = Engine.Scene:getTiles():getTilesets():tilesetFromId("waterfall"):getFirstTileId();

    for x = Object.tile_x, max_x, 1 do
        local suffix = "MIDDLE";
        if x == Object.tile_x then
            suffix = "LEFT";
        elseif x == max_x then
            suffix = "RIGHT";
        end
        print("Set tile to : "..prefix..suffix, x,current_y)
        Engine.Scene:getTiles():getLayer("Water"):setTile(x, current_y, WATERFALL_SPRITESHEET_OFFSET+WATERFALL_TILE_ID[prefix..suffix]);
        if prefix == "" then
            Engine.Scene:getTiles():getLayer("Water"):setTile(x, new_y, WATERFALL_SPRITESHEET_OFFSET+WATERFALL_TILE_ID["FALLING_"..suffix]);
        end
    end
end

function testWaterfall(event)
    local current_y = Object.tile_y + Object.waterfall_height - 1;
    local tile_id = Engine.Scene:getTiles():getLayer("Items"):getTile(Object.tile_x, current_y);
    local bridge_id_offset = Engine.Scene:getTiles():getTilesets():tilesetFromId("bridge_rock"):getFirstTileId();
    if tile_id < bridge_id_offset or tile_id > bridge_id_offset + 2 then
        print("flooow",current_y, tile_id, bridge_id_offset)
        Object.state = true
    end
end

function Event.Game.Update(event)
    if Object.state then
        waterfall(event)
    else
        testWaterfall(event)
    end
end
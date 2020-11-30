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
    Object.clock = ANIMATION_TIME;

    local tile_width = Engine.Scene:getTiles():getTileWidth();
    local tile_height = Engine.Scene:getTiles():getTileHeight();
    Object.tile_x = math.floor(x / tile_width);
    Object.tile_y = math.floor(y / tile_height);

    Object.waterfall_width = math.floor(width / tile_width);
    Object.waterfall_height = math.floor(height / tile_height);
    Object.state = false
end

function canGoThrough(x, y)
    local items_tile_id = Engine.Scene:getTiles():getLayer("Items"):getTile(x, y);
    local bridge_id_offset = Engine.Scene:getTiles():getTilesets():tilesetFromId("bridge_rock"):getFirstTileId();
    if items_tile_id ~= 0 and (items_tile_id < bridge_id_offset + 3 or items_tile_id > bridge_id_offset + 5)
    or Engine.Scene:getTiles():getLayer("Tile_Layer"):getTile(x, y) ~= 0
    or Engine.Scene:getTiles():getLayer("Tile_Layer_Back"):getTile(x, y) ~= 0 then
        return false;
    end
    return true;
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
    if not canGoThrough(Object.tile_x, current_y) then
        prefix = "BOTTOM_";
        Object.state = false
        Object.clock = ANIMATION_TIME
    else
        Object.waterfall_height = Object.waterfall_height + 1;
        local extincted_fire = false;
        for x = Object.tile_x - 1, max_x + 1, 1 do
            local tileId = Engine.Scene:getTiles():getLayer("Items_front"):getTile(x, Object.waterfall_height);
            if tileId ~= 0 and Engine.Scene:getTiles():getTilesets():tilesetFromTileId(tileId):getId() == "fire" then
                extincted_fire = true;
                Engine.Scene:getTiles():getLayer("Items_front"):setTile(x, Object.waterfall_height, 0);
            end
        end
        if extincted_fire then
            Engine.Scene:getGameObject("character"):DiscoverFires();
        end
    end
    local WATERFALL_SPRITESHEET_OFFSET = Engine.Scene:getTiles():getTilesets():tilesetFromId("waterfall"):getFirstTileId();

    for x = Object.tile_x, max_x, 1 do
        local suffix = "MIDDLE";
        if x == Object.tile_x then
            suffix = "LEFT";
        elseif x == max_x then
            suffix = "RIGHT";
        end
        Engine.Scene:getTiles():getLayer("Water"):setTile(x, current_y, WATERFALL_SPRITESHEET_OFFSET+WATERFALL_TILE_ID[prefix..suffix]);
        if prefix == "" then
            Engine.Scene:getTiles():getLayer("Water"):setTile(x, new_y, WATERFALL_SPRITESHEET_OFFSET+WATERFALL_TILE_ID["FALLING_"..suffix]);
        end
    end
end

function testWaterfall(event)
    local current_y = Object.tile_y + Object.waterfall_height - 1;
    if canGoThrough(Object.tile_x, current_y) then
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
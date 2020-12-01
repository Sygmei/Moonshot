local ENABLED_BRIDGE_LEFT_TILE_ID = 0;
local ENABLED_BRIDGE_CENTER_TILE_ID = 1;
local ENABLED_BRIDGE_RIGHT_TILE_ID = 2;
local DISABLED_BRIDGE_LEFT_TILE_ID = 3;
local DISABLED_BRIDGE_CENTER_TILE_ID = 4;
local DISABLED_BRIDGE_RIGHT_TILE_ID = 5;

function setBridgeState(enabled)
    local new_state = Object.state ~= enabled;
    print(Object.id, "new state is", new_state);
    local max_x = Object.tile_x + Object.bridge_width - 1;
    local max_y = Object.tile_y + Object.bridge_height - 1;
    local BRIDGE_TILE_OFFSET = Engine.Scene:getTiles():getTilesets():tilesetFromId("bridge_rock"):getFirstTileId();
    for x = Object.tile_x, max_x, 1 do
        for y = Object.tile_y, max_y, 1 do
            local tile_id;

            if new_state then
                if x == Object.tile_x and x ~= max_x then
                    tile_id = ENABLED_BRIDGE_LEFT_TILE_ID;
                elseif x == max_x then
                    tile_id = ENABLED_BRIDGE_RIGHT_TILE_ID;
                else
                    tile_id = ENABLED_BRIDGE_CENTER_TILE_ID;
                end
            else
                if x == Object.tile_x and x ~= max_x then
                    tile_id = DISABLED_BRIDGE_LEFT_TILE_ID;
                elseif x == max_x then
                    tile_id = DISABLED_BRIDGE_RIGHT_TILE_ID;
                else
                    tile_id = DISABLED_BRIDGE_CENTER_TILE_ID;
                end
            end
            Engine.Scene:getTiles():getLayer("Items"):setTile(x, y, BRIDGE_TILE_OFFSET + tile_id);
        end
    end
end


function Local.Init(x, y, width, height, state)
    print("Bridge initialized");
    Object.state = state or false;

    local tile_width = Engine.Scene:getTiles():getTileWidth();
    local tile_height = Engine.Scene:getTiles():getTileHeight();
    Object.tile_x = math.floor(x / tile_width);
    Object.tile_y = math.floor(y / tile_height);

    Object.bridge_width = math.floor(width / tile_width);
    Object.bridge_height = math.floor(height / tile_height);

    Object.rect = obe.Transform.Rect();
    Object.rect:setPosition(obe.Transform.UnitVector(x, y, obe.Transform.Units.ScenePixels));
    Object.rect:setSize(obe.Transform.UnitVector(width, height, obe.Transform.Units.ScenePixels));

    setBridgeState(false);
end

function Object:success()
    print(self.id, "bridge activated :)");
    setBridgeState(true);
    local character = Engine.Scene:getGameObject("character");
    local bbox = character.Collider:getBoundingBox();
    if bbox:intersects(Object.rect) then
        local offset = Object.rect:getPosition(obe.Transform.Referential.Top) - bbox:getPosition(obe.Transform.Referential.Bottom);
        character.SceneNode:move(obe.Transform.UnitVector(0, offset.y));
    end
end

function Object:failure()
    print(self.id, "bridge could not be activated :(");
    setBridgeState(false);
end
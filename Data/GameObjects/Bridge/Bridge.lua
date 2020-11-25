local BRIDGE_TILE_ID = 29;

function setBridgeState(enabled)
    local new_state = Object.state ~= enabled;
    for x = Object.tile_x, Object.tile_x + Object.bridge_width - 1, 1 do
        for y = Object.tile_y, Object.tile_y + Object.bridge_height - 1, 1 do
            if not new_state then
                Engine.Scene:getTiles():getLayer("Items"):setTile(x, y, 0);
            else
                Engine.Scene:getTiles():getLayer("Items"):setTile(x, y, BRIDGE_TILE_ID);
            end
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

    setBridgeState(false);
end

function Object:success()
    print(self.id, "bridge activated :)");
    setBridgeState(true);
end

function Object:failure()
    print(self.id, "bridge could not be activated :(");
    setBridgeState(false);
end
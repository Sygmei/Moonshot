Object.active = false;

function Local.Init(x, y, width, height)
    local tile_width = Engine.Scene:getTiles():getTileWidth();
    local tile_height = Engine.Scene:getTiles():getTileHeight();
    Object.tile_x = math.floor(x / tile_width);
    Object.tile_y = math.floor(y / tile_height);

    Object.gate_width = math.floor(width / tile_width);
    Object.gate_height = math.floor(height / tile_height);
end

function Object:open()
    local max_x = Object.tile_x + Object.gate_width - 1;
    local max_y = Object.tile_y + Object.gate_height - 1;
    for x = Object.tile_x, max_x, 1 do
        for y = Object.tile_y, max_y, 1 do
            Engine.Scene:getTiles():getLayer("Items_back"):setTile(x, y, 0);
        end
    end
end

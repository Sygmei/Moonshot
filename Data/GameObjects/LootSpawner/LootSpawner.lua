function Local.Init(x, y, loot)
    Object.x = x;
    Object.y = y;
    Object.loot = loot;
end

function Object:success()
    local camera_size = Engine.Scene:getCamera():getSize().y / 2;
    Engine.Scene:getCamera():setSize(1);
    Engine.Scene:createGameObject("Loot") {x = Object.x, y = Object.y, name = Object.loot};
    Engine.Scene:getGameObject("character"):DiscoverLoots();
    Engine.Scene:getCamera():setSize(camera_size);
end

function Object:failure()

end

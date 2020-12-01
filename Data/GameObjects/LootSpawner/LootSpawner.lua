function Local.Init(x, y, loot)
    Object.x = x;
    Object.y = y;
    Object.loot = loot;
end

function Object:success()
    Engine.Scene:createGameObject("Loot") {
        x = Object.x,
        y = Object.y,
        name = Object.loot
    };
    Engine.Scene:getGameObject("character"):DiscoverLoots();
end

function Object:failure()

end
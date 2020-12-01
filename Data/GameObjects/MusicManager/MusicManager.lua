function Local.Init(track)
    Object.ost = Engine.Audio:load(obe.System.Path("Music/".. track), obe.Audio.LoadPolicy.Stream);
    Object.ost:setVolume(0.2);
    Object.ost:setLooping(true);
    Object.ost:play();
end

function Event.Game.Update(event)
    if Engine.Scene:doesGameObjectExists("character") and Engine.Scene:getGameObject("character").slowed then
        Object.ost:setSpeed(0.5);
    else
        Object.ost:setSpeed(1);
    end
end

function Local.Delete()
    Object.ost:stop();
end
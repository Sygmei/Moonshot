function Local.Init()
    Object.ost = Engine.Audio:load(obe.System.Path("Sounds/Moonshot_OST__Title.mp3"), obe.Audio.LoadPolicy.Stream);
    Object.ost:play();
    Object.ost:setVolume(0.4);
end

function Local.Delete()
    Object.ost:stop();
end
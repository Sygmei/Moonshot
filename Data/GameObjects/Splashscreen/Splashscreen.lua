function Local.Init(image, next_scene)
    This.Sprite:loadTexture("Sprites/" .. image);
    Object.next_scene = next_scene;
end

function Event.Actions.Continue()
    Engine.Scene:loadFromFile(Object.next_scene);
end

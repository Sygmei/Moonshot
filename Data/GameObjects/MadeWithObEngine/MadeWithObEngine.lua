function Local.Init(next_scene)
    Object.next_scene = next_scene;
    print("Welcome to ObEngine");

    fade = Engine.Scene:getGameObject("fade");
    local window_size = Engine.Window:getSize():to(obe.Transform.Units.ScenePixels);
    print("Creating canvas of size", window_size.x, window_size.y);
    print("Sprite has size", This.Sprite:getSize());
    print("Sprite has position", This.Sprite:getPosition());
    canvas = obe.Canvas.Canvas(window_size.x, window_size.y);

    canvas:Rectangle "background" {
        width = 1,
        height = 1,
        unit = obe.Transform.Units.ViewPercentage,
        color = "#2d132c",
        layer = 2,
    };

    canvas:Text "madewithobengine" {
        font = "Data/Fonts/SulphurPoint-Light.otf",
        x = 0.65,
        y = 0.5,
        unit = obe.Transform.Units.ViewPercentage,
        align = {
            horizontal = "Center",
            vertical = "Center"
        },
        text = "Made with ÖbEngine",
        layer = 1,
        size = 110
    };

    canvas:Text "version" {
        x = 0.99,
        y = 1,
        unit = obe.Transform.Units.ViewPercentage,
        align = {
            horizontal = "Right",
            vertical = "Bottom"
        },
        text = obe.Config.OBENGINE_VERSION,
        layer = 1,
        size = 64
    };

    chrono = obe.Time.Chronometer();
    chrono:start();
    fade:fadeIn();
    Engine.Events:schedule():after(3):run(function() fade:fadeOut() end);
    Engine.Events:schedule():after(4):run(function() Engine.Scene:loadFromFile(Object.next_scene) end);
end

function Event.Game.Render()
    canvas:render(This.Sprite);
end
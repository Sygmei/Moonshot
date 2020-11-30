function Local.Init()
    canvas = obe.Canvas.Canvas(1, 1);
    rect = canvas:Rectangle("background") {
        width = 1,
        height = 1,
        color = "black",
    }
    canvas:render(This.Sprite);
    Object.fade = 0;
    Object.fadeSpeed = 300;
    Object.alpha = 255;
end

function Object:fadeIn()
    self.fade = -1;
end

function Object:fadeOut()
    self.fade = 1;
end

function Event.Game.Render()
    canvas:render(This.Sprite);
end

--[[function Event.Actions.FadeIn()
    Object:fadeIn();
end

function Event.Actions.FadeOut()
    Object:fadeOut();
end]]

function Event.Game.Update(event)
    if event.dt > 0.1 then event.dt = 0.1 end
    Object.alpha = Object.alpha + (event.dt * Object.fadeSpeed * Object.fade);
    if Object.fade > 0 and Object.alpha >= 255 then
        Object.fade = 0;
        Object.alpha = 255;
    elseif Object.fade < 0 and Object.alpha <= 0 then
        Object.fade = 0;
        Object.alpha = 0;
    end
    rect.color.a = Object.alpha;
end
function Local.Init(canvas, line_1, line_2, line_3, line_4, line_5, line_6)
    Object.canvas = Engine.Scene:getGameObject(canvas);
    Object.pos = {x = x, y = y};
    Object.text = "";
    for k, v in pairs({line_1, line_2, line_3, line_4, line_5, line_6}) do
        if v then
            Object.text = Object.text .. v .. "\n"
        end
    end
end

function Object:success()
    Object.canvas:setText(Object.text);
end

function Object:failure()
    Object.canvas:removeText(Object.text);
end

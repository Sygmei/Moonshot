function Local.Init(trigger_1, trigger_2, trigger_3, trigger_4, trigger_5, trigger_6)
    Object.triggers = {};
    for k, v in pairs({trigger_1, trigger_2, trigger_3, trigger_4, trigger_5, trigger_6}) do
        if v then
            table.insert(Object.triggers, Engine.Scene:getGameObject(v));
        end
    end
end

function Object:success()
    for k, v in pairs(Object.triggers) do
        v:success();
    end
end

function Object:failure()
    for k, v in pairs(Object.triggers) do
        v:failure();
    end
end
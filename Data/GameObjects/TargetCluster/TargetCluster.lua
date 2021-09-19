local chronoTrigger;
local resetTimer;
local nextTarget;
local sequenceStarted;

function Local.Init(
    trigger,
    timeout,
    resetTime,
    allow_multiple_successes,
    allow_failure_after_success,
    order_matter
)
    Object.trigger = Engine.Scene:getGameObject(trigger);
    Object.targets = {};
    for i, target in ipairs(Object.targets) do
        target:setCluster(Object, i)
    end
    chronoTrigger = obe.Time.Chronometer()
    if timeout then
        chronoTrigger:setLimit(timeout);
    end
    nextTarget = 1
    sequenceStarted = false
    if resetTime then
        resetTimer = obe.Time.Chronometer()
        resetTimer:setLimit(resetTime)
    end
    Object.timer_sound = Engine.Audio:load(
        obe.System.Path("Sounds/ticktock.ogg"), obe.Audio.LoadPolicy.Cache
    );
    Object.timer_sound:setLooping(true);

    Object.valid_sound = Engine.Audio:load(
        obe.System.Path("Sounds/valid.ogg"), obe.Audio.LoadPolicy.Cache
    );
    Object.invalid_sound = Engine.Audio:load(
        obe.System.Path("Sounds/invalid.ogg"), obe.Audio.LoadPolicy.Cache
    );
    Object.config = {
        allow_multiple_successes = allow_multiple_successes or false,
        allow_failure_after_success = allow_failure_after_success or false,
        order_matter = order_matter or false
    }
    Object.already_succeeded = false;
    Object.targets_hits = {}
end

function Object:addTarget(target)
    print("Cluster", self.id, "adding new target", target.id);
    table.insert(self.targets, target);
    Object.targets_hits[#self.targets] = false;
    return #self.targets;
end

function Object:failure()
    reset_target_hits();
    Object.timer_sound:stop();
    if Object.already_succeeded and not Object.config.allow_failure_after_success then
        return;
    end
    Object.invalid_sound:play();
    for i, target in ipairs(Object.targets) do
        target:failure()
    end
    chronoTrigger:stop()
    Object.trigger:failure()
    sequenceStarted = false
    if resetTimer then
        resetTimer:start()
        nextTarget = 0
    else
        nextTarget = 1
    end
end

function reset_target_hits()
    for k, _ in pairs(Object.targets_hits) do
        Object.targets_hits[k] = false;
    end
end

local function success()
    reset_target_hits();
    if Object.already_succeeded and not Object.config.allow_multiple_successes then
        return;
    end
    Object.already_succeeded = true;
    Object.timer_sound:stop();
    Object.valid_sound:play();
    for i, target in ipairs(Object.targets) do
        target:success()
    end
    chronoTrigger:stop()
    Object.trigger:success()
    sequenceStarted = false
    nextTarget = 1
end

function Object:targetHit(index)
    if nextTarget == 0 then
        return
    end
    if not sequenceStarted and index == 1 then
        if index == 1 or not Object.config.order_matter then
            sequenceStarted = true
            chronoTrigger:start()
            Object.timer_sound:play();
        end
    end
    if not sequenceStarted then
        Object:failure()
        return false
    end
    if Object.config.order_matter and nextTarget ~= index then
        Object:failure();
        return false;
    elseif not Object.config.order_matter and Object.targets_hits[index] then
        Object:failure();
        return false;
    end
    Object.targets_hits[index] = true;
    print("Target hits", inspect(Object.targets_hits));
    nextTarget = nextTarget + 1
    if Object.config.order_matter and nextTarget > #Object.targets then
        success()
    elseif not Object.config.order_matter then
        local missing_target = false;
        for k, v in pairs(Object.targets_hits) do
            if v ~= true then
                missing_target = true;
                break
            end
        end
        if not missing_target then
            success();
        end
    end
    return true
end

function Event.Game.Update(event)
    if sequenceStarted and chronoTrigger:over() then
        Object:failure()
    end
    if nextTarget == 0 and resetTimer and resetTimer:over() then
        resetTimer:stop()
        nextTarget = 1
    end
end

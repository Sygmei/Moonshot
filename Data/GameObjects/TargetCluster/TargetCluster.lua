local chronoTrigger;
local resetTimer;
local nextTarget;
local sequenceStarted;

function Local.Init(trigger, timeout, resetTime)
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
    Object.timer_sound = Engine.Audio:load(obe.System.Path("Sounds/ticktock.ogg"), obe.Audio.LoadPolicy.Cache);
    Object.timer_sound:setLooping(true);

    Object.valid_sound = Engine.Audio:load(obe.System.Path("Sounds/valid.ogg"), obe.Audio.LoadPolicy.Cache);
    Object.invalid_sound = Engine.Audio:load(obe.System.Path("Sounds/invalid.ogg"), obe.Audio.LoadPolicy.Cache);
end

function Object:addTarget(target)
    print("Cluster", self.id, "adding new target", target.id);
    table.insert(self.targets, target);
    return #self.targets;
end

function Object:failure()
    Object.timer_sound:stop();
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

local function success()
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
        sequenceStarted = true
        chronoTrigger:start()
        Object.timer_sound:play();
    end
    if not sequenceStarted or nextTarget ~= index then
        Object:failure()
        return false
    end
    nextTarget = nextTarget + 1
    if nextTarget > #Object.targets then
        success()
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
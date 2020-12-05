Directions = {
    Left = "left",
    Right = "right",
}
Actions = {
    "Left",
    "Right",
    "Jump"
}
Character = {};

function Object:DiscoverLadders()
    print("Discovering Ladders");
    Object.ladders = {};
    for k, v in pairs(Engine.Scene:getAllColliders()) do
        if v:doesHaveTag(obe.Collision.ColliderTagType.Tag, "Ladder") then
            table.insert(Object.ladders, v);
        end
    end
end

function Object:DiscoverSpikes()
    print("Discovering Spikes");
    Object.spikes = {};
    local colliders = Engine.Scene:getAllColliders();
    print("Collider size", #colliders);
    for k, v in pairs(colliders) do
        if v:doesHaveTag(obe.Collision.ColliderTagType.Tag, "Spike") then
            table.insert(Object.spikes, v);
        end
    end
end

function Object:DiscoverLoots()
    print("Discovering Loots");
    Object.loots = {};
    for k, v in pairs(Engine.Scene:getAllGameObjects("Loot")) do
        table.insert(Object.loots, v);
    end
end

function Object:DiscoverCheckpoints()
    print("Discovering Checkpoints");
    Object.checkpoints = {};
    for k, v in pairs(Engine.Scene:getAllGameObjects("Checkpoint")) do
        table.insert(Object.checkpoints, v);
    end
end

function Object:DiscoverJumpers()
    print("Discovering Jumpers");
    Object.jumpers = {};
    for k, v in pairs(Engine.Scene:getAllGameObjects("Jumper")) do
        table.insert(Object.jumpers, v);
    end
end

function Object:DiscoverFires()
    print("Discovering Fires");
    Object.fires = {};
    for k, v in pairs(Engine.Scene:getAllColliders()) do
        if v ~= nil and v:doesHaveTag(obe.Collision.ColliderTagType.Tag, "Fire") then
            table.insert(Object.fires, v);
        end
    end
end

function Object:DiscoverRestrictions()
    print("Discovering Restrictions");
    Object.restrictions = {};
    for k, v in pairs(Engine.Scene:getAllGameObjects("RestrictionZone")) do
        table.insert(Object.restrictions, v);
    end
end

function Object:DiscoverSlowmotions()
    print("Discovering Slowmotions");
    Object.slowmotions = {};
    for k, v in pairs(Engine.Scene:getAllGameObjects("SlowMotionZone")) do
        table.insert(Object.slowmotions, v);
    end
end

function Object:respawn()
    print("Respawn to", self.checkpoint);
    This.SceneNode:setPosition(self.checkpoint);
end

function Object:applyModifiers(modifiers)
    for modifier in modifiers:gmatch("(.-),") do
        print("Applying modifier", modifier);
        self.modifiers[modifier] = true;
    end
end

-- Local Init Function
function Local.Init(x, y, modifiers)
    Object.SceneNode = This.SceneNode;
    Object.sounds = {
        burn = Engine.Audio:load(obe.System.Path("Sounds/burn.ogg"), obe.Audio.LoadPolicy.Cache),
        spike_death = Engine.Audio:load(obe.System.Path("Sounds/spike_death.ogg"), obe.Audio.LoadPolicy.Cache),
        loot = Engine.Audio:load(obe.System.Path("Sounds/loot.ogg"), obe.Audio.LoadPolicy.Cache),
        restriction = Engine.Audio:load(obe.System.Path("Sounds/invalid.ogg"), obe.Audio.LoadPolicy.Cache)
    }
    Object.sprite_size = This.Sprite:getSize();
    --collectgarbage("stop")
    if (x == nil) then x = 0; end
    if (y == nil) then y = 0; end

    InitializeBindings();
    -- Initial Character Position
    This.SceneNode:setPosition(obe.Transform.UnitVector(x, y, obe.Transform.Units.ScenePixels));
    -- This.Collider:setPosition(obe.Transform.UnitVector(x, y, obe.Transform.Units.ScenePixels));
    -- This.Sprite:setPosition(obe.Transform.UnitVector(x, y, obe.Transform.Units.ScenePixels));
    Object.toDump = {x = x, y = y};

    Object.checkpoint = This.SceneNode:getPosition();

    -- Character's Collider tags
    This.Collider:addTag(obe.Collision.ColliderTagType.Rejected, "NotSolid");
    This.Collider:addTag(obe.Collision.ColliderTagType.Rejected, "Character");
    This.Collider:addTag(obe.Collision.ColliderTagType.Rejected, "Ladder");
    This.Collider:addTag(obe.Collision.ColliderTagType.Rejected, "Spike");
    This.Collider:addTag(obe.Collision.ColliderTagType.Rejected, "Target");
    This.Collider:addTag(obe.Collision.ColliderTagType.Rejected, "Projectile");
    This.Collider:addTag(obe.Collision.ColliderTagType.Rejected, "Fire");

    --cameraFollower = TriggerDatabase:createTriggerGroup(Private, "ActorsCamera"):addTrigger("Moved");

    -- This.Animator:load(obe.System.Path("Sprites/Character"));

    -- Character's toggles
    Object.isShooting = false;
    Object.isJumping = false;
    Object.isFalling = false;
    Object.isMoving = false;
    Object.isRunning = false;
    Object.isCrouching = false;
    Object.direction = Directions.Right;
    Object.speeds = { walk = 1.5, run = 3, jump = 4.7};

    --[[for k, v in pairs(Engine.Scene:getAllColliders()) do
        print("Collider", k, v:getId(), v:getParentId());
        if v:getParentId() == "tile_20" or v:getParentId() == "tile_16" then
            Engine.Scene:removeCollider(v:getId());
        end
    end
    print("New collider size", #Engine.Scene:getAllColliders());]]

    Object.ladders = {};
    Object:DiscoverLadders();

    Object.spikes = {};
    Object:DiscoverSpikes();

    Object.loots = {};
    Object:DiscoverLoots();

    Object.checkpoints = {};
    Object:DiscoverCheckpoints();

    Object.jumpers = {};
    Object:DiscoverJumpers();

    Object.fires = {};
    Object:DiscoverFires();

    Object.restrictions = {};
    Object:DiscoverRestrictions();

    Object.slowmotions = {};
    Object:DiscoverSlowmotions();
    Object.slowed = false;

    allColliders = Engine.Scene:getAllColliders();

    Trajectories = obe.Collision.TrajectoryNode(This.SceneNode);
    Trajectories:setProbe(This.Collider);
    Trajectories:addTrajectory("Fall"):setSpeed(0):setAngle(270):setAcceleration(12);
    Trajectories:addTrajectory("Jump"):setSpeed(0):setAngle(90):setAcceleration(-12):setStatic(true);
    Trajectories:addTrajectory("Move"):setSpeed(0):setAngle(0):setAcceleration(0);
    Trajectories:getTrajectory("Fall"):addCheck(function(self, offset)
        if not Object.isJumping and self:getStatic() and This.Collider:getMaximumDistanceBeforeCollision(offset).offset.y > 0 then
            self:setStatic(false);
            Object.isFalling = true;
        end
        for _, ladder in pairs(Object.ladders) do
            if This.Collider:doesCollide(ladder, obe.UnitVector(0, 0)) then
                self:setStatic(true);
                Object.isFalling = false;
            end
        end
        for _, spike in pairs(Object.spikes) do
            if This.Collider:doesCollide(spike, obe.Transform.UnitVector(0, 0)) then
                Character.Kill("spike_death");
            end
        end
    end);

    Trajectories:getTrajectory("Jump"):addCheck(function(self, offset)
        if self:getSpeed() <= 0 then
            Object.isJumping = false;
            self:setSpeed(0);
            self:setStatic(true);
        end
    end);

    Trajectories:getTrajectory("Fall"):onCollide(function(self)
        self:setSpeed(0);
        self:setStatic(true);
        Object.isFalling = false;
        Object.isJumping = false;
    end);

    Trajectories:getTrajectory("Jump"):onCollide(function(self)
        self:setSpeed(0);
        Object.isJumping = false;
    end);

    Trajectories:getTrajectory("Move"):addCheck(function(self, offset)
        local collision = This.Collider:getMaximumDistanceBeforeCollision(offset);
        if offset.x ~= 0 then
            if collision.offset.x == 0 then
                local collider = collision.colliders[1];
                local angle = obe.Utils.Math.normalize(collider:getSegment(0):getAngle(), 0, 360);
                if angle > 180 then
                    angle = angle - 180;
                end
                self:setAngle(angle);
            else
                local collision = This.Collider:getMaximumDistanceBeforeCollision(obe.Transform.UnitVector(0, 0.01));
                if #collision.colliders > 0 then
                    local angle = 0
                    for _, collider in pairs(collision.colliders) do
                        angle = obe.Utils.Math.normalize(collider:getSegment(0):getAngle(), 0, 360);
                        if angle == 0 or angle == 180 then
                            return
                        end
                    end
                    if angle < 180 then
                        angle = angle + 180;
                    end
                    self:setAngle(angle);
                end
            end
        end
    end);

    Object.shoot = {
        Animator = obe.Animation.Animator(),
        Sprite = Engine.Scene:createSprite("shoot_effect"),
        Clock = 0,
        MaxClock = 0.5
    };
    Object.shoot.Animator:load(obe.System.Path("Sprites/ShootEffect"));
    Object.shoot.Animator:setKey("shoot");
    -- Object.shoot.Animator:setTarget(Object.shoot.Sprite, obe.Animation.AnimatorTargetScaleMode.TextureSize);
    Object.shoot.Sprite:loadTexture("Sprites/ShootEffect/shoot/effect6.png");
    Object.shoot.Sprite:setPosition(This.Collider:getCentroid());
    Object.shoot.Sprite:setSize(obe.Transform.UnitVector(1, 1));
    Object.shoot.Sprite:setLayer(1);
    Object.shoot.Sprite:setVisible(false);

    Object.modifiers = {
        bullet_through_bridge = false,
        moon = false,
        projectile_count = 4
    };
    if modifiers then
        Object:applyModifiers(modifiers .. ",");
    end

    Object.keys = {};
    -- TODO: Move this out of Character
    Object.puzzle_pieces = 0;
end

function count_projectile()
    local count = 0;
    for k, v in pairs(Engine.Scene:getAllGameObjects("Projectile")) do
        if not v.inactive then
            count = count + 1;
        end
    end
    return count;
end

function checkRestriction(restriction)
    for k, v in pairs(Object.restrictions) do
        if v.Zone:intersects(This.Collider:getBoundingBox()) and v.restriction == restriction then
            return true;
        end
    end
    return false;
end

function Event.Actions.Shoot()
    if count_projectile() >= Object.modifiers.projectile_count then
        return;
    end
    if checkRestriction("projectile") then
        Object.sounds.restriction:play();
        return;
    end
    local cursorPos = Engine.Cursor:getScenePosition():to(obe.Transform.Units.SceneUnits);
    local pos = This.Collider:getCentroid()
    local relPos = pos - Engine.Scene:getCamera():getPosition():to(obe.Transform.Units.SceneUnits);
    local vecInit = obe.Transform.UnitVector(cursorPos.x - relPos.x, cursorPos.y - relPos.y);
    Engine.Scene:createGameObject("Projectile") {
        x=pos.x,
        y=pos.y,
        vecInit=vecInit,
        through_bridge=Object.modifiers.bullet_through_bridge
    };
    Object.isShooting = true;
    Object.shoot.Sprite:setVisible(true);
end

local moon_remover;
function Event.Actions.CreateMoon()
    local amount_of_moons = 0;
    for k, v in pairs(Engine.Scene:getAllGameObjects("Moon")) do
        if not v.deleted then
            amount_of_moons = amount_of_moons + 1;
        end
    end
    if Object.modifiers.moon and amount_of_moons < 1 then
        if checkRestriction("moon") then
            Object.sounds.restriction:play();
            return;
        end
        local realPos = (Engine.Scene:getCamera():getPosition() + Engine.Cursor:getScenePosition());
        Engine.Scene:createGameObject("Moon") {
            x=realPos.x,
            y=realPos.y
        };
    elseif amount_of_moons == 1 then
        print("Release moons :D")
        for k, v in pairs(Engine.Scene:getAllGameObjects("Moon")) do
            v:release();
        end
    end
    if moon_remover == nil then
        print("Add remover");
        moon_remover = Engine.Events:schedule();
        moon_remover:after(0.6):run(function()
            for k, v in pairs(Engine.Scene:getAllGameObjects("Moon")) do
                v:delete();
            end
            moon_remover = nil;
        end);
        print("Added remover", moon_remover);
    end
end

-- TODO: Fix Released: RMB event
function Event.Cursor.Release()
    if moon_remover ~= nil then
        print("Cancel remove moon")
        moon_remover:stop();
        moon_remover = nil;
    end
end

function Character.Kill(cause)
    print("Die of", cause);
    local death_sound = Object.sounds[cause];
    if death_sound ~= nil then
        death_sound:play();
    end
    Engine.Scene:getGameObject("gameManager"):death();
    Object:respawn();
end

function Character.Left()
    Object.isMoving = true;
    Object.direction = Directions.Left;
end

function Character.Right()
    Object.isMoving = true;
    Object.direction = Directions.Right;
end

function Character.Jump()
    if not Object.isJumping and not Object.isFalling then
        local jump_speed = Object.speeds.jump;
        local jump_angle = 90;
        for _, jumper in pairs(Object.jumpers) do
            if jumper.active and This.Collider:getBoundingBox():intersects(jumper.Sprite) then
                jump_speed = jumper.speed;
                jump_angle = jumper.angle;
                jumper:use();
                break;
            end
        end
        Trajectories:getTrajectory("Jump"):setAngle(jump_angle);
        Trajectories:getTrajectory("Jump"):setSpeed(jump_speed);
        Trajectories:getTrajectory("Jump"):setStatic(false);
        Object.isJumping = true;
        This.Animator:setKey("jump_" .. Object.direction);
    end
end

function InitializeBindings()
    for k, v in pairs(Actions) do
        Event.Actions[v] = Character[v];
    end
end

function Event.Game.Render()
    -- local newSize = This.Sprite:getSize();
    -- local textureSize = This.Sprite:getTexture():getSize();
    -- newSize.x = (textureSize.x / textureSize.y) * newSize.y;
    -- This.Sprite:setSize(newSize);
    -- This.Sprite:setPosition(This.Collider:getPosition());
end

local last_anim = "";
-- Local Update Function
function Event.Game.Update(event)
    -- print(This.Collider:getCentroid(), This.Sprite:getPosition(), This.Sprite:getSize());
    local dt = event.dt;
    local slowed = false;
    for k, v in pairs(Object.slowmotions) do
        if v.Zone:intersects(This.Collider:getBoundingBox()) then
            dt = dt * v.factor;
            slowed = true;
            break;
        end
    end
    Object.slowed = slowed;
    Trajectories:update(dt);

    -- Moving Character
    if last_anim ~= This.Animator:getKey() then
        -- print(last_anim, "=>", This.Animator:getKey());
        last_anim = This.Animator:getKey();
    end
    if Object.isFalling then
        This.Animator:setKey("fall_" .. Object.direction);
    end
    if Object.isMoving then
        Object:Move();
    else
        Trajectories:getTrajectory("Move"):setSpeed(0);
        if not Object.isJumping and not Object.isFalling then
            This.Animator:setKey("idle_" .. Object.direction);
        end
        -- This.Animator:setKey("IDLE_" .. Object.direction);
    end
    Object.isMoving = false;

    if Object.isShooting then
        -- Object.shoot.Animator:update();
        Object.shoot.Clock = Object.shoot.Clock + event.dt;
        Object.shoot.Sprite:setPosition(This.Collider:getCentroid(), obe.Transform.Referential.Center);
        local current_shoot_scale = (Object.shoot.Clock / Object.shoot.MaxClock) * 0.5;
        Object.shoot.Sprite:setSize(obe.Transform.UnitVector(0.01 + current_shoot_scale, 0.01 + current_shoot_scale), obe.Transform.Referential.Center);
        if Object.shoot.Clock >= Object.shoot.MaxClock then
            Object.shoot.Clock = 0;
            Object.isShooting = false;
            Object.shoot.Sprite:setVisible(false);
            Object.shoot.Sprite:setSize(obe.Transform.UnitVector(0.5, 0.5), obe.Transform.Referential.Center);
        end
    end

    for _, loot in pairs(Object.loots) do
        if This.Collider:getBoundingBox():intersects(loot.Sprite) and loot.active then
            loot.Sprite:setVisible(false);
            loot:effect(Object);
            Object.sounds.loot:play();
            loot.active = false;
        end
    end

    for _, checkpoint in pairs(Object.checkpoints) do
        if This.Collider:getBoundingBox():intersects(checkpoint.Sprite) and not checkpoint.enabled then
            Object.checkpoint = checkpoint.SceneNode:getPosition();
            print("New checkpoint", Object.checkpoint);
            for _, checkpoint2 in pairs(Object.checkpoints) do
                checkpoint2:disable();
            end
            checkpoint:enable();
            break;
        end
    end

    for _, fire in pairs(Object.fires) do
        if This.Collider:doesCollide(fire, obe.Transform.UnitVector(0, 0)) then
            Character.Kill("burn");
        end
    end
    if #This.Collider:doesCollide(obe.Transform.UnitVector(0, 0)).colliders > 0 then
        print("Unstuck from ground !");
        This.SceneNode:move(obe.Transform.UnitVector(0, -0.01)); -- Unstuck from ground
    end
    -- Engine.Scene:getCamera():setPosition(This.Collider:getCentroid(), obe.Transform.Referential.Center);
end

function Object.Dump()
    return Object.toDump;
end

function Object:getPosition()
    return This.Collider:getCentroid();
end

function Object:Move()
    local directionAngle = 0;
    local directionSpeed = 0;
    if not self.isJumping and not self.isFalling then
        This.Animator:setKey("run_" .. self.direction);
        if self.isRunning then
            -- This.Animator:setKey("RUN_" .. self.direction);
        else
            -- This.Animator:setKey("WALK_" .. self.direction);
        end
    end
    if self.isRunning then
        directionSpeed = self.speeds.run;
    else
        directionSpeed = self.speeds.walk;
    end
    if self.direction == Directions.Left then
        directionAngle = 180;
    elseif self.direction == Directions.Right then
        directionAngle = 0;
    else
        directionSpeed = 0;
    end
    Trajectories:getTrajectory("Move"):setAngle(directionAngle);
    Trajectories:getTrajectory("Move"):setSpeed(directionSpeed);
end

function Event.Actions.Reset()
    Engine.Scene:loadFromFile("Scenes/moonshot_dungeon_1.json.vili");
    Engine.Scene:getGameObject("gameManager"):reset();
end

function Event.Actions.Suicide()
    Character:Kill();
end
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
    for k, v in pairs(Engine.Scene:getAllColliders()) do
        if v:doesHaveTag(obe.Collision.ColliderTagType.Tag, "Ladder") then
            table.insert(Object.ladders, v);
        end
    end
end

function Object:DiscoverSpikes()
    for k, v in pairs(Engine.Scene:getAllColliders()) do
        if v:doesHaveTag(obe.Collision.ColliderTagType.Tag, "Spike") then
            table.insert(Object.spikes, v);
        end
    end
end

-- Local Init Function
function Local.Init(x, y)
    Object.sprite_size = This.Sprite:getSize();
    --collectgarbage("stop")
    if (x == nil) then x = 0; end
    if (y == nil) then y = 0; end

    InitializeBindings();
    -- Initial Character Position
    This.Collider:setPosition(obe.Transform.UnitVector(x, y, obe.Transform.Units.ScenePixels));
    This.Sprite:setPosition(obe.Transform.UnitVector(x, y, obe.Transform.Units.ScenePixels));
    Object.toDump = {x = x, y = y};

    -- Character's Collider tags
    This.Collider:addTag(obe.Collision.ColliderTagType.Tag, "Character");
    This.Collider:addTag(obe.Collision.ColliderTagType.Rejected, "NotSolid");
    This.Collider:addTag(obe.Collision.ColliderTagType.Rejected, "Character");
    This.Collider:addTag(obe.Collision.ColliderTagType.Rejected, "Ladder");
    This.Collider:addTag(obe.Collision.ColliderTagType.Rejected, "Spike");
    This.Collider:addTag(obe.Collision.ColliderTagType.Rejected, "Target");
    This.Collider:addTag(obe.Collision.ColliderTagType.Rejected, "Projectile");

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

    Object.ladders = {};
    Object:DiscoverLadders();

    Object.spikes = {};
    Object:DiscoverSpikes();

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
            if This.Collider:doesCollide(spike, obe.UnitVector(0, 0)) then
                print("DIEEEE")
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
                self:setAngle(math.abs(angle - 180));
            else
                --[[local collision = This.Collider:getMaximumDistanceBeforeCollision(obe.Transform.UnitVector(0, 0.01));
                if #collision.colliders > 0 then
                    local collider = collision.colliders[1];
                    local angle = obe.Utils.Math.normalize(collider:getSegment(0):getAngle(), 0, 360);
                    if angle ~= 0 then
                        print(1, angle)
                        if angle < 180 then
                            angle = angle + 180;
                        end
                        print(2, angle)
                        angle = 180 + math.abs(360 - angle);
                        print(3, angle);
                        self:setAngle(angle);
                    end
                end]]--
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
end

function Event.Actions.UseTile()
    local cursor_position = Engine.Cursor:getPosition():to(obe.Transform.Units.ScenePixels);
    local camera_position = Engine.Scene:getCamera():getPosition():to(obe.Transform.Units.ScenePixels);
    local final_position = camera_position + cursor_position;
    This.SceneNode:setPosition(final_position);
end

function Event.Actions.Shoot()
    local cursorPos = Engine.Cursor:getPosition();
    local pos = This.Collider:getCentroid():to(obe.Transform.Units.ScenePixels);
    local relPos = pos - Engine.Scene:getCamera():getPosition();
    local vecInit = obe.Transform.UnitVector(cursorPos.x - relPos.x, cursorPos.y - relPos.y, obe.Transform.Units.ScenePixels);
    Engine.Scene:createGameObject("Projectile") {
        x=pos.x,
        y=pos.y,
        vecInit=vecInit
    };
    Object.isShooting = true;
    Object.shoot.Sprite:setVisible(true);
end

function Event.Actions.CreateMoon()
    local realPos = (Engine.Scene:getCamera():getPosition() + Engine.Cursor:getPosition()):to(obe.Transform.Units.ScenePixels);
    Engine.Scene:createGameObject("Moon") {
        x=realPos.x,
        y=realPos.y
    };
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
    for k, v in pairs(Engine.Scene:getAllGameObjects("Moon")) do
        v:release();
    end
    if not Object.isJumping and not Object.isFalling then
        Trajectories:getTrajectory("Jump"):setSpeed(Object.speeds.jump);
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
    Trajectories:update(event.dt);

    -- Moving Character
    if last_anim ~= This.Animator:getKey() then
        print(last_anim, "=>", This.Animator:getKey());
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
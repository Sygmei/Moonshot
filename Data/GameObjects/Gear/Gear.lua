function Local.Init()
    Object.maxSpinSpeed = 270;
    Object.spinSpeed = 1;
    Object.moveSpeed = 0.1;
    Object.maxMoveSpeed = 20;
    Object.spin = false;
    Object.move = true;
    Object.sound = Engine.Audio:load(obe.System.Path("Sounds/gears.ogg"), obe.Audio.LoadPolicy.Cache);
    This.Sprite:setPosition(
        obe.Transform.UnitVector(1, 0.5, obe.Transform.Units.ViewPercentage),
        obe.Transform.Referential.Left
    );
end

function Event.Game.Update(event)
    if Object.move then
        This.Sprite:move(obe.Transform.UnitVector(-Object.moveSpeed, 0));
        local position = This.Sprite:getPosition();
        if position.x <= 0.25 then
            This.Sprite:setPosition(obe.Transform.UnitVector(0.25, position.y))
            Object.move = false;
            Object.spin = true;
            Object.sound:play();

        end
    end
    if Object.spin then
        if Object.spinSpeed < Object.maxSpinSpeed then
            Object.spinSpeed = Object.spinSpeed + (Object.spinSpeed * event.dt * 5);
        end
        This.Sprite:rotate(Object.spinSpeed * event.dt);
    end
end

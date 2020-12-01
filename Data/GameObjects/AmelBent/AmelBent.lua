function Local.Init(x, y)
    This.Sprite:hide();
    This.Sprite:setPosition(obe.Transform.UnitVector(x, y, obe.Transform.Units.ScenePixels), obe.Transform.Referential.Bottom);
end

function Object:success()
    This.Sprite:show();
end

function Object:failure()
    This.Sprite:hide();
end
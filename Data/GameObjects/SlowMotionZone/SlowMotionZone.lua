function Local.Init(x, y, width, height, factor)
    local position = obe.Transform.UnitVector(x, y, obe.Transform.Units.ScenePixels):to(
        obe.Transform.Units.SceneUnits
    );
    local size = obe.Transform.UnitVector(width, height, obe.Transform.Units.ScenePixels):to(
        obe.Transform.Units.SceneUnits
    );
    Object.Zone = obe.Transform.Rect();
    Object.Zone:setPosition(position);
    Object.Zone:setSize(size);
    Object.factor = factor;
end

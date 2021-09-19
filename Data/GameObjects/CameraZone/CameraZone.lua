function Local.Init(
    x, y, width, height, clamp_x_min, clamp_y_min, clamp_x_max, clamp_y_max, use_max
)
    local position = obe.Transform.UnitVector(x, y, obe.Transform.Units.ScenePixels):to(
        obe.Transform.Units.SceneUnits
    );
    local size = obe.Transform.UnitVector(width, height, obe.Transform.Units.ScenePixels):to(
        obe.Transform.Units.SceneUnits
    );
    Object.use_max = use_max or false;
    Object.Zone = obe.Transform.Rect();
    Object.Zone:setPosition(position);
    Object.Zone:setSize(size);
    Object.Clamp = {};
    if clamp_x_min ~= nil then
        Object.Clamp.x_min = position.x;
    end
    if clamp_y_min ~= nil then
        Object.Clamp.y_min = position.y;
    end
    if clamp_x_max ~= nil then
        Object.Clamp.x_max = position.x + size.x;
    end
    if clamp_y_max ~= nil then
        Object.Clamp.y_max = position.y + size.y;
    end
    print("CLAMP", inspect(Object.Clamp));
end

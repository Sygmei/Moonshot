local CAPTATION_RADIUS = 0.9;
local ORBIT_RADIUS = 0.37;
local SENSIBILITY = 0.0037 * 2;


function Local.Init(x, y)
    active = true
    Object.deleted = false;

    center = {x=x, y=y}
    This.Sprite:setPosition(obe.Transform.UnitVector(x,y), obe.Transform.Referential.Center)
end

function Object:delete()
    This:deleteObject();
end

function Object:active()
    return active
end

function Object:release()
    active = not active
    if not active then
        This.Sprite:setColor(obe.Graphics.Color("blue"))
    else
        This.Sprite:setColor(obe.Graphics.Color("white"))
    end
end

local function inDist(x, y, radius)
    local dist = math.sqrt((x-center.x)*(x-center.x)+(y-center.y)*(y-center.y))
    if dist <= radius + SENSIBILITY then
        return true
    end
    return false
end


function Object:captive(x, y)
    if not active then
        return false
    end
    return inDist(x, y, CAPTATION_RADIUS)
end

function Object:orbit(x, y)
    if not active then
        return false
    end
    return inDist(x, y, ORBIT_RADIUS)
end

function Object:getOrbitRadius()
    return ORBIT_RADIUS
end

function Object:getPosition()
    return center
end

local function lineEquation(x, y, vecUnit)
    if vecUnit.x == 0 then
        return {x=x}
    end
    local a = vecUnit.y/vecUnit.x
    local b = y-a*x
    return {a=a, b=b}
end

local function getDistFromLine(x, y, vecUnit)
    local line = lineEquation(x, y, vecUnit)
    if line.a == nil then
        return math.abs(x-center.x)
    end
    return math.abs(center.y-line.a*center.x-line.b) / math.sqrt(1+line.a*line.a)
end

local function getRampRadius(x, y, vecUnit, inOrbit)
    local dist = math.sqrt((x-center.x)*(x-center.x)+(y-center.y)*(y-center.y))
    if inOrbit then
        return (dist*dist - ORBIT_RADIUS*ORBIT_RADIUS) / (2*(ORBIT_RADIUS-getDistFromLine(x, y, vecUnit)))
    else
        return (dist*dist - ORBIT_RADIUS*ORBIT_RADIUS) / (2*(getDistFromLine(x, y, vecUnit)-ORBIT_RADIUS))
    end
end

local function getPotentialRampCircle(x, y, vecUnit, direction, inOrbit)
    local radius = getRampRadius(x, y, vecUnit, inOrbit)
    local vecPerpendicular
    if direction == 1 and inOrbit == true or direction == -1 and inOrbit == false then
        vecPerpendicular = Vector2(vecUnit.y, -vecUnit.x)
    else
        vecPerpendicular = Vector2(-vecUnit.y, vecUnit.x)
    end
    return {radius = radius, x = x+vecPerpendicular.x*radius, y = y+vecPerpendicular.y*radius}
end

local function nbIntersections(line)
    local delta = 0
    if line.a == nil then
        delta = ORBIT_RADIUS - math.abs(line.x-center.x)
    else
        delta = ORBIT_RADIUS*ORBIT_RADIUS*(1+line.a*line.a)-(center.y-line.a*center.x-line.b)*(center.y-line.a*center.x-line.b)
    end
    if delta < 0 then
        return 0
    elseif delta == 0 then
        return 1
    else
        return 2
    end
end

function Object:getRampCircle(x, y, vecUnit, direction)
    local res = {inverse=false, circle=nil}
    local inOrbit = false
    local n = nbIntersections(lineEquation(x, y, vecUnit))
    if n == 1 then
        return res
    elseif n == 2 then
        res.inverse = true
        inOrbit = true
    end
    res.circle=getPotentialRampCircle(x, y, vecUnit, direction, inOrbit)
    return res
end

function Object:getAngle(x, y, circle)
    if circle then
        return math.atan(y - circle.y, x - circle.x)
    else
        return math.atan(y - center.y, x - center.x)
    end
end

function Object:getDirection(x, y, vecUnit)
    local direction = 1
    local vecThreshold = Vector2(center.x - x, center.y - y):normalize()
    local angThreshold = math.atan(vecThreshold.x, vecThreshold.y)
    local ang = math.atan(vecUnit.x, vecUnit.y)
    local diff = (ang-angThreshold+(4*math.pi))%(2*math.pi)

    if diff > math.pi then
        direction = -1
    end
    return direction
end
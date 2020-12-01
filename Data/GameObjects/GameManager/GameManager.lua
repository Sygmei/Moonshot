local SKULL_ICON_PERMANENT;
local PUZZLE_PIECE_PERMANENT;

function Local.Init()
    SKULL_ICON_PERMANENT = Engine.Scene:createSprite("skull_icon_permanent");
    SKULL_ICON_PERMANENT:setParentId(Object.id);
    SKULL_ICON_PERMANENT:loadTexture("Sprites/skull.png");

    PUZZLE_PIECE_PERMANENT = Engine.Scene:createSprite("puzzle_piece_icon_permanent");
    PUZZLE_PIECE_PERMANENT:setParentId(Object.id);
    PUZZLE_PIECE_PERMANENT:loadTexture("Sprites/Loot/puzzle_piece.png");

    local window_size = Engine.Window:getSize():to(obe.Transform.Units.ScenePixels);
    Object.canvas = obe.Canvas.Canvas(window_size.x, window_size.y);
    Object.deaths = 0;
    Object.deaths_icon = Object.canvas:Rectangle "death_icon" {
        texture = "Sprites/skull.png",
        x = 0,
        y = 0,
        width = 48,
        height = 48,
        unit = obe.Transform.Units.ScenePixels
    };
    Object.deaths_text = Object.canvas:Text "deaths" {
        text = "Deaths : " .. tostring(Object.deaths),
        size = 22,
        color = obe.Graphics.Color.White,
        x = 60,
        y = 24,
        align = {
            vertical = "Center"
        },
        unit = obe.Transform.Units.ScenePixels
    }

    Object.puzzle_pieces = 0;
    Object.puzzle_pieces_icon = Object.canvas:Rectangle "puzzle_piece_icon" {
        texture = "Sprites/Loot/puzzle_piece.png",
        x = 0,
        y = 60,
        width = 48,
        height = 48,
        unit = obe.Transform.Units.ScenePixels
    };
    Object.puzzle_pieces_text = Object.canvas:Text "puzzle_pieces" {
        text = "Puzzle pieces : " .. tostring(Object.puzzle_pieces),
        size = 22,
        color = obe.Graphics.Color.White,
        x = 60,
        y = 24 + 60,
        align = {
            vertical = "Center"
        },
        unit = obe.Transform.Units.ScenePixels
    }
end

function Object:death()
    self.deaths = self.deaths + 1;
    self.deaths_text.text = "Deaths : " .. tostring(Object.deaths);
end

function Object:puzzle_piece_obtained()
    self.puzzle_pieces = self.puzzle_pieces + 1;
    self.puzzle_pieces_text.text = "Puzzle pieces : " .. tostring(Object.puzzle_pieces);
end

--[[function Event.Scene.Loaded()
    Object.deaths_icon = "Sprites/skull.png";
    Object.puzzle_pieces_icon = "Sprites/Loot/puzzle_piece.png";
end]]

function Event.Game.Render()
    Object.canvas:render(This.Sprite);
end
LOOT_DB = {
    bullet_through_bridge = {
        image = "Sprites/Loot/bullet_through_bridge.png",
        effect = function(self, character)
            character.modifiers.bullet_through_bridge = true;
        end
    },
    puzzle_piece = {
        image = "Sprites/Loot/puzzle_piece.png",
        effect = function(self, character)
            character.puzzle_pieces = character.puzzle_pieces + 1;
            print(character.puzzle_pieces);
        end
    },
    key = {
        image = "Sprites/Loot/key.png",
        effect = function(self, character)
            print("Got a key :)", self.id);
            character.keys[self.id] = true;
        end
    },
    moon = {
        image = "Sprites/Loot/moon.png",
        effect = function(self, character)
            print("Got a moon :)", self.id);
            character.modifiers.moon = true;
        end
    },
}
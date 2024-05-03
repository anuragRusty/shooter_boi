love.graphics.setDefaultFilter("nearest","nearest");
CURSOR = love.mouse.newCursor("assets/spritesheets/crosshair.png",8,8);
FONT = love.graphics.newFont("assets/font/vt323.ttf",32);
love.graphics.setFont(FONT);
love.mouse.setCursor(CURSOR);

Scale = 2;
GameState = "Ideal"; --Ideal Paused Running GameOver

TILE = 32;
MAP_TILE = 48;
TILE_SIZE = TILE*Scale;
MAP_WIDTH = MAP_TILE*30;
MAP_HEIGHT = MAP_TILE*15;
RED = {0.65, 0.2,0.2, 1};
WHITE = {1,1,1,1}

Anim8 = require("/libs/anim8/anim8");
Sti = require("/libs/sti");
Entity = require("entity");
Weapon = require("weapon");
Spear = require("spear");
Gun = require("gun");
Bullet = require("bullet");
Enemy = require("enemy");

require("player");
require("wave");
require("camera");

function love.load()
    World = love.physics.newWorld(0,0,false);
    World:setCallbacks(BeginContact, EndContact, PreSolve, PostSolve)
    love.physics.setMeter(TILE_SIZE)
    Map = Sti("map/dugeon.lua",{"box2d"});
    Map.layers.solid.visible = false;
    Map:box2d_init(World);

    Wave:load();
    Player:load();
    Camera:load(MAP_WIDTH,MAP_HEIGHT,Scale);
end

function love.update(dt)
    World:update(dt);
    Camera:update(Player.x,Player.y,Scale);
    Player:update(dt);
    --Wave:update(dt);
end

function love.draw()
    Camera:apply();
    Map:draw(-Camera.x,-Camera.y,Scale,Scale);
    Player:draw();
    --Wave:draw();
    Player:drawStatus();    
    Camera:clear();
end

function love.wheelmoved(x,y)
    Player:changeGun(x,y);
end

function BeginContact(fixture1, fixture2,contact)
    BulletBeginContact(fixture1,fixture2,contact);
    Wave:beginContact(fixture1,fixture2,contact);
 end
  
 function EndContact(fixture1,fixture2,contact)
    Wave:endContact(fixture1,fixture2,contact);
 end
 
 function PreSolve()
 end
 
 function PostSolve()
 end

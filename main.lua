love.graphics.setDefaultFilter("nearest", "nearest");
CURSOR = love.mouse.newCursor("assets/spritesheets/crosshair.png",8,8);
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
Gun = require("gun");
Bullet = require("bullet");
Enemy = require("enemy");

require("player");
require("wave");
require("camera");

local function beginContact(fixture1, fixture2,contact)
   BulletBeginContact(fixture1,fixture2,contact);
end

local function endContact()
end

local function preSolve()
end

local function postSolve()
end

function love.load()
    World = love.physics.newWorld(0,0);
    World:setCallbacks(beginContact, endContact, preSolve, postSolve)
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
    Wave:update(dt);
end

function love.draw()
    Camera:apply();
    Map:draw(-Camera.x,-Camera.y,Scale,Scale);
    Player:draw();
    Wave:draw();
    Player:drawStatus();    
    Camera:clear();
end

function love.wheelmoved(x,y)
    Player:changeGun(x,y);
end


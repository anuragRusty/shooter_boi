Wave = {};

function Wave:load()
    self.enemies = {};
    self.count = math.random(1,5);
    self:GenEnemies(self.count);
end

function Wave:update(dt)
    for i,enemy in pairs(self.enemies) do
        enemy:update(dt);
        if enemy.state == 'dead' and not enemy.shoted then
            enemy.body:destroy();
            enemy.weapon.body:destroy();
            table.remove(self.enemies,i);
            Player.score = Player.score + 10;
        end
    end
    self:reGenEnemies();
end

function Wave:reGenEnemies()
     if #self.enemies == 0 then
        self.count = math.random(1,4);
        self:GenEnemies(self.count);
     end
end

function Wave:GenEnemies(count)
    for i = 1,count,1 do
        local enemy = Enemy:new(PUMPKIN);
        table.insert(self.enemies,enemy);
    end

    for _,enemy in pairs(self.enemies) do
        enemy:load();
    end
end

function Wave:draw()
    for _,enemy in pairs(self.enemies) do
        enemy:draw();
    end
end
require('map')
require('lua-enumerable')

function love.load()
  music = love.audio.newSource("theme.mp3")
  love.audio.play(music)

  screen_width = map.width * map.tilewidth
  screen_height = map.height * map.tileheight

  world = love.physics.newWorld(0, 0, screen_width, screen_height)

  --world:setGravity(0, 700) --the x component of the gravity will be 0, and the y component of the gravity will be 700
  world:setMeter(64) --the height of a meter in this world will be 64px
  world:setCallbacks(add, persist, rem, result)

  objects = {} -- table to hold all our physical objects
  --let's create a ball for each target
  objects.balls = table.collect(get_targets(), function(x) return spawn_ball(x) end)
  table.each(objects.balls, function (ball,i) ball.shape:setData(i) end)
  --initial graphics setup
  -- love.graphics.setBackgroundColor(57, 57, 59) -- substantial gray
  love.graphics.setBackgroundColor(255, 255, 255)
  love.graphics.setMode(screen_width, screen_height, false, true, 0)
end

function love.update(dt)
  move_balls(dt)
  world:update(dt)
end

function love.draw()
  love.graphics.setColor(249, 56, 29) --set the drawing color to red for the ball
  table.each(objects.balls, function(ball)
                              love.graphics.circle("fill", ball.body:getX(), ball.body:getY(), ball.shape:getRadius(), 16)
                            end)
end

function get_targets()
  local layer = map.layers[1]
  local targets = {}
  table.each(layer.data, function(p, i)
                           if p == 2 then
                             local target = {}
                             target.x = (i % layer.width) * map.tilewidth
                             target.y = (math.floor(i / layer.width)) * map.tileheight
                             table.push(targets, target)
                           end
                         end)
  return targets
end

function get_targets()
  local layer = map.layers[1]
  local targets = {}
  table.each(layer.data, function(p, i)
                           if p == 2 then
                             local target = {}
                             target.x = (i % layer.width) * map.tilewidth
                             target.y = (math.floor(i / layer.width)) * map.tileheight
                             print("x=" .. target.x .. " y=" .. target.y)
                             table.push(targets, target)
                           end
                         end)
  return targets
end

function move_balls(dt)
  table.each(objects.balls, function(ball)
                              if ball.passive_dt > 0 then
                                ball.passive_dt = ball.passive_dt - dt
                              else
                                move_ball(ball)
                              end
                            end)
end

function move_ball(ball)
  local diff_x = math.abs(ball.body:getX() - ball.target.x)
  local diff_y = math.abs(ball.body:getY() - ball.target.y)

  if diff_x < 2 and diff_y < 2 then
    ball.body:setPosition(ball.target.x, ball.target.y)
    ball.body:putToSleep()
  else
    local x1 = ball.body:getX()
    local y1 = ball.body:getY()
    local x2 = ball.target.x
    local y2 = ball.target.y

    local angle = math.angle(x1,y1,x2,y2)
    local dx, dy = math.calc_destination(x1, y1, angle, ball.speed)--225)
    ball.body:setLinearVelocity(dx-x1, dy-y1)
  end
end

function math.dist(x1,y1, x2,y2)
  return ((x2-x1)^2+(y2-y1)^2)^0.5
end

function math.angle(x1, y1, x2, y2)
  return math.atan2(y2-y1,x2-x1)
end

function math.clamp(low, n, high)
  return math.min(math.max(n, low), high)
end

function math.calc_destination(x1, y1, angle, distance)
  return x1 + (distance * math.cos(angle)), y1 + (distance * math.sin(angle))
end

function spawn_ball(target)
  local ball = {}
  ball.body = love.physics.newBody(world, math.random(1,screen_width), math.random(1,screen_height), 5, 0)
  ball.body:setLinearDamping( 0.5 )
  ball.shape = love.physics.newCircleShape(ball.body, 0, 0, 4)
  ball.target = target
  ball.speed = math.clamp(50, math.dist(ball.body:getX(), ball.body:getY(), target.x, target.y) / 2, 500)
  ball.passive_dt = 0
  return ball
end

function add(a, b, coll) -- a colliding with b at an angle of coll:getNormal()
  --objects.balls[b].passive_dt = 0.5
end

function persist(a, b, coll) -- a touching b
end

function rem(a, b, coll) -- a uncolliding with b
end

function result(a, b, coll) -- a hit b resulting with coll:getNormal()
end

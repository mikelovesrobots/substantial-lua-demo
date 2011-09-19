require('map')
require('lua-enumerable')

function love.load()
  reverse_direction = false

  screen_width = map.width * map.tilewidth
  screen_height = map.height * map.tileheight

  world = love.physics.newWorld(0, 0, screen_width, screen_height)

  --world:setGravity(0, 700) --the x component of the gravity will be 0, and the y component of the gravity will be 700
  world:setMeter(64) --the height of a meter in this world will be 64px

  objects = {} -- table to hold all our physical objects
  --let's create a ball for each target
  objects.balls = table.collect(get_targets(), function(x) return spawn_ball(x) end)

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
                              local diff_x = math.abs(ball.body:getX() - ball.target.x)
                              local diff_y = math.abs(ball.body:getY() - ball.target.y)

                              if diff_x < 2 and diff_y < 2 then
                                ball.body:setPosition(ball.target.x, ball.target.y)
                                ball.body:putToSleep()
                              else
                                local x = 160
                                local y = 160

                                if ball.body:getX() > ball.target.x then
                                  x = x * -1
                                end

                                if ball.body:getY() > ball.target.y then
                                  y = y * -1
                                end

                                ball.body:setLinearVelocity(x, y)
                              end
                            end)
end

function math.clamp(low, n, high) return math.min(math.max(n, low), high) end
function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end

function spawn_ball(target)
  local ball = {}
  ball.body = love.physics.newBody(world, math.random(1,screen_width), math.random(1,screen_height), 5, 0)
  ball.body:setLinearDamping( 0.5 )
  ball.shape = love.physics.newCircleShape(ball.body, 0, 0, 4)
  ball.target = target
  return ball
end


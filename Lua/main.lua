-- Ball
local ball = {}
ball.position_x = 300
ball.position_y = 300
ball.speed_x = 200
ball.speed_y = 200
ball.radius = 10
ball.tap = 0

local scoreA = 0
local scoreB = 0
function ball.update( dt )
  if (ball.position_y > love.graphics.getHeight()+100) then
    ball.position_x = 500
    ball.position_y = 500
    ball.speed_x = -200
    ball.speed_y = -200
    scoreA = scoreA+1
  end
  if (ball.position_y < -100) then
    ball.position_x = 100
    ball.position_y = 100
    ball.speed_x = 200
    ball.speed_y = 200
    scoreB = scoreB+1
  end
   ball.position_x = ball.position_x + ball.speed_x * dt
   ball.position_y = ball.position_y + ball.speed_y * dt


end

function ball.draw()
   local segments_in_circle = 16
   love.graphics.circle( 'line',
			 ball.position_x,
			 ball.position_y,
			 ball.radius,
			 segments_in_circle )
end

function ball.rebound( shift_ball_x, shift_ball_y )
   local min_shift = math.min( math.abs( shift_ball_x ),
			       math.abs( shift_ball_y ) )
   if math.abs( shift_ball_x ) == min_shift then
      shift_ball_y = 0
   else
      shift_ball_x = 0
   end
   ball.position_x = ball.position_x + shift_ball_x
   ball.position_y = ball.position_y + shift_ball_y
   if shift_ball_x ~= 0 then
      ball.speed_x  = -(ball.speed_x)
   end
   if shift_ball_y ~= 0 then
      ball.speed_y  = -(ball.speed_y)
   end
end

function ball.rebound_platform( shift_ball_x, shift_ball_y )
   local min_shift = math.min( math.abs( shift_ball_x ),
			       math.abs( shift_ball_y ) )
   if math.abs( shift_ball_x ) == min_shift then
      shift_ball_y = 0
   else
      shift_ball_x = 0
   end
   ball.position_x = ball.position_x + shift_ball_x
   ball.position_y = ball.position_y + shift_ball_y
   if shift_ball_x ~= 0 then
      ball.speed_x  = -(ball.speed_x + ball.tap * 0)
   end
   if shift_ball_y ~= 0 then
      ball.speed_y  = -(ball.speed_y + ball.tap * 0)
   end
   ball.speed_x  = ball.speed_x  * 1.1
   ball.speed_y  = ball.speed_y  * 1.1
end

-- Platform
local platform = {}
platform.width = 100
platform.height = 10
platform.position_x = 500
platform.position_y = love.graphics.getHeight()- 50 - platform.height
platform.speed_x = 400


function platform.update( dt )
   if love.keyboard.isDown("right") then
      platform.position_x = platform.position_x + (platform.speed_x * dt)
   end
   if love.keyboard.isDown("left") then
      platform.position_x = platform.position_x - (platform.speed_x * dt)
   end
end

function platform.draw()
   love.graphics.rectangle( 'line',
			    platform.position_x,
			    platform.position_y,
			    platform.width,
			    platform.height )
end

-- Platform2
local platform2 = {}
platform2.width = 100
platform2.height = 10
platform2.position_x = 600
platform2.position_y = 40
platform2.speed_x = 400

function platform2.update( dt )
   if love.keyboard.isDown('d') then
      platform2.position_x = platform2.position_x + (platform2.speed_x * dt)
   end
   if love.keyboard.isDown('a') then
      platform2.position_x = platform2.position_x - (platform2.speed_x * dt)
   end
end

function platform2.draw()
   love.graphics.rectangle( 'line',
			    platform2.position_x,
			    platform2.position_y,
			    platform2.width,
			    platform2.height )
end


-- Walls
local walls = {}
walls.wall_thickness = 20
walls.current_level_walls = {}

function walls.new_wall( position_x, position_y, width, height )
   return( { position_x = position_x,
	     position_y = position_y,
	     width = width,
	     height = height } )
end

function walls.update_wall( single_wall )
end

function walls.draw_wall( single_wall )
   love.graphics.rectangle( 'line',
			    single_wall.position_x,
			    single_wall.position_y,
			    single_wall.width,
			    single_wall.height )
end

function walls.construct_walls()
   local left_wall = walls.new_wall(
      0,
      0,
      walls.wall_thickness,
      love.graphics.getHeight()
   )
   local right_wall = walls.new_wall(
      love.graphics.getWidth() - walls.wall_thickness,
      0,
      walls.wall_thickness,
      love.graphics.getHeight()
   )
   walls.current_level_walls["left"] = left_wall
   walls.current_level_walls["right"] = right_wall
end

function walls.update( dt )
   for _, wall in pairs( walls.current_level_walls ) do
      walls.update_wall( wall )
   end
end

function walls.draw()
   for _, wall in pairs( walls.current_level_walls ) do
      walls.draw_wall( wall )
   end
end

-- Collisions
local collisions = {}

function collisions.resolve_collisions()
   collisions.ball_platform_collision( ball, platform )
   collisions.ball_platform_collision( ball, platform2 )
   collisions.ball_walls_collision( ball, walls )
end

function collisions.check_rectangles_overlap( a, b )
   local overlap = false
   local shift_b_x, shift_b_y = 0, 0
   if not( a.x + a.width < b.x  or b.x + b.width < a.x  or
	   a.y + a.height < b.y or b.y + b.height < a.y ) then
      overlap = true
      if ( a.x + a.width / 2 ) < ( b.x + b.width / 2 ) then
	 shift_b_x = ( a.x + a.width ) - b.x
      else
	 shift_b_x = a.x - ( b.x + b.width )
      end
      if ( a.y + a.height / 2 ) < ( b.y + b.height / 2 ) then
	 shift_b_y = ( a.y + a.height ) - b.y
      else
	 shift_b_y = a.y - ( b.y + b.height )
      end
   end
   return overlap, shift_b_x, shift_b_y
end

function collisions.ball_platform_collision( ball, platform )
   local overlap, shift_ball_x, shift_ball_y
   local a = { x = platform.position_x,
	       y = platform.position_y,
	       width = platform.width,
	       height = platform.height }
   local b = { x = ball.position_x - ball.radius,
	       y = ball.position_y - ball.radius,
	       width = 2 * ball.radius,
	       height = 2 * ball.radius }
   overlap, shift_ball_x, shift_ball_y =
      collisions.check_rectangles_overlap( a, b )
   if overlap then
      ball.tap = ball.tap+1
      ball.rebound_platform( shift_ball_x, shift_ball_y )
   end
end

function collisions.ball_walls_collision( ball, walls )
   local overlap, shift_ball_x, shift_ball_y
   local b = { x = ball.position_x - ball.radius,
	       y = ball.position_y - ball.radius,
	       width = 2 * ball.radius,
	       height = 2 * ball.radius }
   for _, wall in pairs( walls.current_level_walls ) do
      local a = { x = wall.position_x,
		  y = wall.position_y,
		  width = wall.width,
		  height = wall.height }
      overlap, shift_ball_x, shift_ball_y =
      	 collisions.check_rectangles_overlap( a, b )
      if overlap then
	 ball.rebound( shift_ball_x, shift_ball_y )
      end
   end
end

function love.load()
  walls.construct_walls()
end

function love.update( dt )
   ball.update( dt )
   platform.update( dt )
   platform2.update( dt )
   walls.update( dt )
   collisions.resolve_collisions()
end

function love.draw()
   ball.draw()
   platform.draw()
   platform2.draw()
   walls.draw()

   love.graphics.print({"score A: ",scoreA}, love.graphics.getWidth()/2-50, love.graphics.getHeight()/2-50)
   love.graphics.print({"score B: ",scoreB}, love.graphics.getWidth()/2+50, love.graphics.getHeight()/2+50)
   love.graphics.print({"Player 1 \nKeys: A - D"}, love.graphics.getWidth()-150, 10)
   love.graphics.print({"Player 2 \nKeys: Arrow Keys"}, love.graphics.getWidth()-150, love.graphics.getHeight()-50)
   love.graphics.print(ball.tap, love.graphics.getWidth()/2, love.graphics.getHeight()/2)
   love.graphics.print({"Speed X: ",ball.speed_x, "\nSpeed Y: ", ball.speed_y}, 30, 10)
end


love.window.setTitle( "Paddle Strike" )

function love.keyreleased( key, code )
   if  key == 'escape' then
      love.event.quit()
   end
end

function love.quit()
  print("Thanks for playing! Come back soon!")
end

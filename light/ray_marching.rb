#!/usr/bin/env ruby
require 'curses'
require 'matrix'
include Curses

# Message: install ncursesw and reinstall curses gem if unicode is not supported.

init_screen
curs_set(0)  # Invisible cursor
noecho
stdscr.nodelay=true

begin
  # stdscr.box("|", "-")
  w, h = cols, lines

  set = lambda { |x, y| setpos(y, x); addstr("\u2588") }
  set_gray = lambda { |x, y, g| setpos(y, x); b = "\u2581".bytes; b[2] += g.to_i; addstr(b.pack("c*").force_encoding('utf-8')) }
  clr = lambda { |x, y| setpos(y, x); addstr(" ") }

  ball = lambda { |p, c, s| (p-c).magnitude - s  }

  last = Time.now
  fps_count = 0
  fps = 0
  loop do
    fps_count += 1
    if Time.now-last >= 1 then fps = fps_count; fps_count = 0; last = Time.now end

    light = Vector[2*Math::sin(Time.now.to_f), Math::cos(Time.now.to_f), 0]
    marching = lambda do |ro, rd|
      dist = 0.0
      10.times do
        current = ro + rd * dist
        close = ball[Vector[0, 0, 2], current, 1]
        if close < 0.1 then
          # return 8 - 8*((ro+rd*(dist+close))[2] - 1)
          point = ro + rd*(dist+close)
          normal = (point-Vector[0,0,2]).normalize
          light_dir = (light - point).normalize
          v = light_dir.dot(normal)
          return ([v, 0].max) * 7
        end
        if close > 10 then break end
        dist += close
      end
      false
    end

    (0...w).each do |x|
      (0...h).each do |y|
        color = marching[Vector[0, 0, -1], Vector[2.0*x/(w-1)-1, (2.3)*(1.0*h/w)*(2.0*y/h-1), 1.0]]
        if color then set_gray[x, y, color] else clr[x, y] end
      end
    end

    setpos 0, 0
    addstr "FPS: #{fps}"

    refresh

    j = getch
    if j == "q" then break end
  end
rescue => ex
  close_screen
  p ex
end

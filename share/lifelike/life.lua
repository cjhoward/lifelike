-- Copyright (C) 2018  Christopher James Howard
-- 
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see <http://www.gnu.org/licenses/>.

require 'cairo'

function rand_real(a, b)
	return a + (b - a) * math.random()
end

initialized = false

function conky_init(w, h, c, o, r, g, b, a, t)	
	width = tonumber(w)
	height = tonumber(h)
	cell_size = tonumber(c)
	cell_border_width = tonumber(o)
	cell_r = tonumber(r)
	cell_g = tonumber(g)
	cell_b = tonumber(b)
	cell_a = tonumber(a)
	max_ticks = tonumber(t)

	math.randomseed(os.time())
	grid_width = math.floor(width / cell_size) + 2
	grid_height = math.floor(height / cell_size) + 2
	grid_x = math.floor((width - math.floor(width / cell_size) * cell_size) / 2)
	grid_y = math.floor((height - math.floor(height / cell_size) * cell_size) / 2)
	grid_size = grid_width * grid_height
	back_index = 0
	front_index = 1
	ticks = 0
	buffers = {}
	buffers[0] = {}
	buffers[1] = {}
	for y = 0, grid_height - 1 do
		for x = 0, grid_width - 1 do
			i = y * grid_width + x
			
			if x == 0 or y == 0 or x == grid_width - 1 or y == grid_height - 1 then
				buffers[back_index][i] = 0
			else
				buffers[back_index][i] = math.floor(rand_real(0, 1) + 0.5)
			end
			
			buffers[front_index][i] = buffers[back_index][i]
		end
	end

	initialized = true
	return ""
end

function conky_main()
	if conky_window == nil or not initialized then
		return
	end
	
	-- Iterate life
	for y = 1, grid_height - 2 do
		for x = 1, grid_width - 2 do
			local i = y * grid_width + x

			-- Sum neighbors
			local n = buffers[back_index][i - grid_width - 1] + buffers[back_index][i - grid_width] + buffers[back_index][i - grid_width + 1] + buffers[back_index][i - 1] + buffers[back_index][i + 1] + buffers[back_index][i + grid_width - 1] + buffers[back_index][i + grid_width] + buffers[back_index][i + grid_width + 1]

			-- Determine life
			if ((buffers[back_index][i] == 1 and (n == 2 or n == 3)) or (buffers[back_index][i] == 0 and n == 3)) then
				buffers[front_index][i] = 1
			else
				buffers[front_index][i] = 0
			end
		end
	end

	-- Setup cairo
	local cs = cairo_xlib_surface_create(conky_window.display,
		conky_window.drawable,
		conky_window.visual,
		conky_window.width,
		conky_window.height)
	cr = cairo_create(cs)
	cairo_set_antialias(cr, CAIRO_ANTIALIAS_NONE)
	
	-- Draw grid
	cairo_set_source_rgba(cr, cell_r, cell_g, cell_b, cell_a);
	for y = 1, grid_height - 2 do
		for x = 1, grid_width - 2 do
			local i = y * grid_width + x
			if buffers[front_index][i] == 1 then
				cairo_rectangle(cr, grid_x + (x - 1) * cell_size + cell_border_width, grid_y + (y - 1) * cell_size + cell_border_width, cell_size - cell_border_width * 2, cell_size - cell_border_width * 2);
			end
		end
	end
	cairo_fill(cr)

	-- Cleanup cairo
	cairo_destroy(cr)
	cairo_surface_destroy(cs)
	cr=nil

	-- Swap buffers
	back_index = (back_index + 1) % 2
	front_index = (front_index + 1) % 2
	ticks = ticks + 1

	-- Reset game
	if ticks >= max_ticks then
		for y = 0, grid_height - 1 do
			for x = 0, grid_width - 1 do
				i = y * grid_width + x
			
				if x == 0 or y == 0 or x == grid_width - 1 or y == grid_height - 1 then
					buffers[back_index][i] = 0
				else
					buffers[back_index][i] = math.floor(rand_real(0, 1) + 0.5)
				end
			
				buffers[front_index][i] = buffers[back_index][i]
			end
		end
		ticks = 0
	end
end

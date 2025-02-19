package main

import "core:mem"
import "core:fmt"
import sdl "vendor:sdl3"

window: ^sdl.Window
renderer: ^sdl.Renderer

SDL_INIT_FLAGS :: sdl.InitFlags {sdl.InitFlag.VIDEO, sdl.InitFlag.EVENTS}
WINDOW_TITLE :: "Blank Page MUD Client"
WINDOW_WIDTH :: 1280
WINDOW_HEIGHT :: 720
// WINDOW_FLAGS ::

main :: proc() {
	// Tracking allocator code adapted from Karl Zylinski's tutorials.
	track: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track, context.allocator)
	context.allocator = mem.tracking_allocator(&track)

	defer {
		for _, entry in track.allocation_map {
			fmt.eprintf("%v leaked %v bytes.\n", entry.location, entry.size)
		}
		for entry in track.bad_free_array {
			fmt.eprintf("%v bad free.\n", entry.location)
		}
		mem.tracking_allocator_destroy(&track)
	}

	startup()
	defer shutdown()

	game_should_close: bool
	event: sdl.Event
	for !game_should_close {
		for sdl.PollEvent(&event) {
			#partial switch event.type {
				case .QUIT:
					game_should_close = true
			}
		}
	}
}

startup :: proc() {
	if !sdl.Init(SDL_INIT_FLAGS) {
		panic("Failed to initialize SDL3!")
	}

	window = sdl.CreateWindow(WINDOW_TITLE, WINDOW_WIDTH, WINDOW_HEIGHT, nil)
	if window == nil {
		sdl.Quit()
		panic("Failed to create SDL3 window!")
	}

	renderer = sdl.CreateRenderer(window, nil)
	if renderer == nil {
		sdl.DestroyWindow(window)
		sdl.Quit()
		panic("Failed to create SDL3 renderer!")
	}
}

shutdown :: proc() {
	sdl.DestroyRenderer(renderer)
	sdl.DestroyWindow(window)
	sdl.Quit()
}

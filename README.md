# Birdanoid
A Roblox movement/gameplay project built around responsive aerial movement, state-based character control, and custom player mechanics.

## Overview
Birdanoid was developed as a gameplay-focused project centered around smooth movement and responsive player control.

The project uses a custom movement controller rather than relying entirely on Roblox's default character behavior, allowing movement states and transitions to be handled explicitly.

## Architecture

- **State-driven movement** — player behavior is separated into Grounded, Air, and Flying states.
- **Context-based state evaluation** — movement state is determined from a shared context containing player input and environmental information.
- **Custom character controller** — movement behavior is processed independently from Roblox's default controls.
- **Responsive movement mechanics** — includes features such as coyote time to make movement feel more forgiving.
- **Separation of responsibilities** — state evaluation, movement behavior, and input handling are kept separate rather than being contained in one large controller.
- **Typed Luau** — gameplay modules use Luau typing to make data contracts and behavior clearer.

## What I worked on
I designed and implemented the gameplay architecture, movement controller, state machine, and supporting client-side systems.

## Movement Features

- Ground movement
- Air movement (tilt included)
- Flying
- Jumping
- Coyote time
- Input-based movement transitions

## State Machine
The movement system evaluates the player's current context each update and determines the appropriate state.

```lua
local state = stateMachine:Step(deltaTime, context)

if state == "Grounded" then
	-- Ground movement
elseif state == "Air" then
	-- Air movement
elseif state == "Flying" then
	-- Flight movement
end
```
This keeps movement behavior explicit and prevents individual mechanics from depending on scattered boolean state.


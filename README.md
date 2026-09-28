# ADHD desktop buddy

##  Core ADHD-Friendly Design Principles

### Non-Intrusive Body Doubling

- Passive Presence: Sitting quietly at the corner of the screen or on top of active windows provides the sensation of a "study buddy" without interrupting flow state.

- ToDo: State Mirroring: The pet can reflect work states (e.g., sleeping quietly while a focus timer runs, getting excited when a session completes). I have the animation in the sprite sheet anyway.

### Frictionless Task Management

- ToDo: Micro-Checklists: Simple, single-click task lists anchored to the pet reduce cognitive load and decision paralysis.

- Visual Timers: ~~Integrated Pomodoro or~~ flexible countdown timers display progress visually through pet animations (e.g., a plant pet growing as time elapses) rather than aggressive digital clocks.

- ToDo: Pomodoro timer

### Dopamine & Gamification Loops

- ToDo: Immediate Feedback: Completing a focus session or checking off a task awards treats, accessories, or room items, providing immediate dopamine hits.

- Avoid harsh punishments for missed goals or inactive days, as shame mechanisms trigger avoidance in ADHD users.

### Sensory & Attention Controls

- ToDo: Customisable Sound & Animation: Options to mute audio, slow down animations, or enable a "stealth mode" prevent sensory overload and active distraction.

- ToDo: Break Prompts: Gentle, non-jarring visual cues (e.g., the pet stretching or holding up a water glass) encourage hydration and physical breaks without breaking deep focus abruptly.

- Positive feedback: Hydrate, You're doing great, Stretch, etc.

### Key Feature Breakdown / ToDos

| Feature Category | Implementation | ADHD benefits | State |
| ----------- | ----------- | ----------- | ----------- |
| Focus Companion | 15 minutes timer with bells | Reduces time blindness | Done |
| Micro-Rewards | Pet XP per completed work session | Replaces delayed gratification with immediate reward | Desirable |
| Self-Care Cues | Positive words | Assists with working mood and wellbeing | Done |
| Parking lot for thoughts | One-click pop-up pad attached to the pet interface | Captures distracting off-topic thoughts instantly from your Paste buffer | Desirable |

### Improvements

- ToDo: Bell is too loud, should be changed or selectable.

- ToDo: Interactive Minigames: If I implement the Pomodoro timer, I can insert stuff like simple Sudoku solvable in in 5 minutes or less.

## Transparency trick

### Project setting checklist
- Rendering Method -> Compatibility
- Project -> Project settings
- Enable Advanced
- Display -> Window
- Mode: Windowed
- Borderless: On
- Transparent: On
- Always on top: On
- Per Pixel Transparency -> Allowed: True
- Rendering -> Viewport
- Transparent Background: On

### In case Godot debug window doesn't apply transparency settings (Ctrl+F4)
- Press Ctrl+F4 or click on "Game" at the editor top-center.
- Click on Embedding Options (Last icon on the Game window bar)
- Embed Game on Next Play: Off
- Press F5 again to run the project.
- After being satisfied with debugging - press F8 to exit the app.

### Make the whole thing scale to full screen
- ToDo: Not sure I need this.
- Project -> Project settings -> Advanced
- Display -> Window -> Mode -> Fullscreen
- Stretch -> Mode -> viewport
- Aspect -> expand

### Programatically:
```
func toggle_fullscreen() -> void:
	var current_mode = DisplayServer.window_get_mode()
	if current_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
```

### ToDo:

- Test on several Linux distros.

### Acknowledgements

- [Free sound effects - bells](https://mixkit.co/free-sound-effects/bell/)
- [Squirrel sprite map from Elthen itch.io](https://elthen.itch.io/2d-pixel-art-squirrel-sprites)
- [Kenney's Godot UI theme](https://azagaya.itch.io/kenneys-ui-theme)
- License files in [media/](media/)


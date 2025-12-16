# VR Solar System Explorer

**Ruben Kenny**  
**Student ID:** C22393366  
**Module:** XR  
**Lecturer:** Bryan Duggan  

**GitHub Repository:**  
https://github.com/Roonaldo100/XRC22393366

**Video Link:**  
https://youtube.com/shorts/YK0knIGWrhM?feature=share

**Screenshots**
![SunView](screenshots/sun_view)
---

## Project Description

This project allows the user to traverse the solar system in **virtual reality**.

The planets and the Sun are set to a **realistic scale**. For example, if the Earth is set to a scale of `5`, the Sun is set to `545`, which is **109× larger**, matching the real-life ratio between the Sun and Earth.

Planets also orbit realistically. Earth takes `365 / constant_x` seconds to orbit the Sun, while Mercury (88 Earth days in real life) takes `88 / constant_x` seconds to orbit the Sun in-game.

Planet distances are also scaled realistically. Given a real-life surface-to-surface distance of `x` million kilometers between a planet and the Sun, its initial position is calculated using: 
sun_position - sun_radius - x - planet_radius


Together, these systems create a **scaled, realistic version of the solar system** that the player can freely explore.

The user can also interact with planets to hear **audio snippets containing factual information**, supporting **SDG 4: Quality Education**.

Additionally, a **small alien shooter mode** is included for entertainment, which the user can toggle on and off.

---

## Instructions for Use

### Movement
- Move forward/backward using the **left joystick**
- Look around using the **right joystick**
- Move up and down using the **Y/X buttons** on the left controller

### Controls
- Pause/Unpause planetary orbit using the **A button**
- Activate/Deactivate alien shooter mode using the **B button**
  - Shoot the alien using the **left trigger** when pointing at it

### Interaction
- At close range, point at and use the **left trigger** to hear audio facts about the planet/Sun
- Point at a planet/Sun and press the **right trigger** to teleport to it

---

## How it Works

The ratio of planets to the Earth or Sun is stored in a singleton/global script called `SolarSettings`. Planets are scaled according to these settings to maintain realistic system-wide scale. This is done by scaling against dictionary values holding their relative values.

Planets orbit around the Sun at a constant radius based on their initial distance from the Sun, orbiting about the x and z axis. This is done mathematically using a segment of the `_process` function in the planet script.

The player’s movement and teleportation is handled using the `xr_tools` library with slight modifications. For example, the default teleport arc was modified to allow long-distance teleportation in a straight line.

The alien is spawned dynamically via an `AlienManager`. When the **B button** is clicked, the system calls the manager, and the alien is instantiated at a random point on a circle **100 units from the user** on the x and z axis. When the alien dies or the mode is turned off, it is cleared from the queue and a new one spawns (if the mode remains on).

Planets are lit by an omnidirectional light source located at the Sun. The Sun itself is not lit by this, so its emission is increased to simulate uniform brightness. This lighting setup ensures only the side of a planet facing the Sun is lit at any time.

---

## Scripts in the Project

### Self-Written

### Modified from XRTools

### Taken Directly From XRTools

---

## References

### Movement
- https://www.youtube.com/watch?v=HvuyLvIYw_s&t=13s
- https://www.youtube.com/watch?v=BrNZs4XzU0w&t=585s

### Teleportation
- https://www.youtube.com/watch?v=E8snzj36sQg&pp=0gcJCSkKAYcqIYzv

### Button Recognition
- https://docs.godotengine.org/en/stable/classes/class_xrcontroller3d.html

### Action Mapping
- https://docs.godotengine.org/en/stable/tutorials/xr/xr_action_map.html

---

## What I’m Most Proud Of

- Mathematically setting up the solar system so it is to scale and can be rescaled by changing Earth/global variables, while orbiting correctly using sin/cos and delta over time.
- Modifying `xr_tools` to work as required:
  - Straight and long-distance teleportation  
  - Recognizing body collision on pointer scripts for audio/alien shooting  
  - Preventing movement glitches upon teleporting
- Creating dynamically instantiated aliens that approach the user using normalization, managed safely via queue freeing, while allowing sounds to finish even after the alien is removed.

---

## What I Learned

- How to set up scene positions using script logic and mathematics instead of manually adjusting inspector values.
- How to communicate between scripts and use a global/singleton to share system-wide values.
- How to use `xr_toolkit` for controller interaction and viewport setup in XR.
- How to use dictionary values and child hierarchies to apply a script across multiple nodes rather than attaching it individually to each.



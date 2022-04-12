--[[

original readme:

# MARUFIGHT ー 丸戦
An evolution simulation designed to create a diverse and dynamic ecosystem with simple and understandable rules. Written in Lua with [LOVE2D](https://love2d.org/).



![](marufight.gif)



# How it works

- A maru (circular creature) creates a clone of itself if it touches a yellow food pellet.
- A maru creates a clone of itself if it pokes a maru with its nose, popping it.
- A maru dies of old age after 60 seconds.
- Each time a maru is born as a clone, it has a chance of mutating from its parent's "DNA".



That's the basics! Everything you see is an outcome of these simple rules.



### More details

Each maru is controlled by a simple three layer neural network which governs its behaviour. Its network is given simple information about the direction of the nearest non-family (killable) maru and food pellet. 

Each maru also has a size and color that can be mutated within a set boundary.

When the population of the world dips below a certain threshold, randomly generated maru are spawned in until the threshold is met in a process called "seeding". This process also populates the world at the beginning.

When a maru is created through seeding, it is assigned a random color, family name, brain, and size. A maru created through seeding is also generation zero of its lineage.

The neurons in a maru's brain all use sigmoid activation functions.

A maru's nose "retracts" when it rotates too quickly, rendering it unable to pop other marus. This is to prevent spinning constantly as a viable predatory strategy.



# How to run

- Download [LOVE2D](https://love2d.org/)
- Download and extract this repo (or clone it)
- Drag the extracted repo into the LOVE2D application icon



Right click and drag to move the camera. The camera can also be moved with the WASD keys and left shift.

Click on a maru to view its brain and statistics.

Press 'F' to toggle follow mode. This mode will center the camera on whichever maru has the most amount of offspring as of that moment.

Press 'Space' to pause.

]]
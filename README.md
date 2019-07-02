# r/RoguelikeDev Does The Complete Roguelike Tutorial 2019
![RoguelikeDev Does the Complete Roguelike Tutorial Event Logo](https://i.imgur.com/3MAzEp1.png)

I'm using [Nim](https://nim-lang.org/) and [libtcod_nim](https://github.com/Vladar4/libtcod_nim) and not exactly doing a 1:1 reproduction of the tutorial, but I'm trying to follow the same progression. So you can expect me to be implementing the same things the tutorial is teaching each week.

I'm storing my weekly developments in branches, while I advance in the master branch. (I've no clue if that's a good idea.)

---

I don't really know where I'm going with this, I'm just making it up as I go. The main purpose is for me to exercise my knowledge of Nim and learn a few more things, and to experiment with whatever else comes up. This is also a nice opportunity to force myself to go all the way through, rather than wasting time with implementation details (and premature optimizations!), which is a recurring problem I have.

So far the idea is kinda sorta like... there's a forest... and in that forest there's a village. So that means there ~~will~~ should be villagers. I'm thinking of laying out some sort of treasure here and there, and some baddies. I'm also thinking there should be a graveyard, for whatever reason. I have quite a few ideas, but none definitive. 

Maybe that forest is the main hub for a traditional dungeon crawler, or maybe it's a starting point for a more outdoor adventure. We will see.

---

#### **TODO:**
- [ ] add an ini settings file (Nim compiles fast, but I'm still sick of recompiling)
- [ ] add mobs (part 5)
- [ ] make some entities stay visible outside of fov (after being discovered)
- [ ] make AI to connect houses (I'm thinking of tunnelers)
- [ ] improve the tile colors
- [ ] add a camera, so I can make maps a bit bigger 
- [ ] add diagonal movement
- [ ] add prefabs
- [ ] add multi-tile entities

#### **Done**
- [x] add option for using faded-color or single-color for tiles outside fov (settings.nim)
- [x] add way to recreate the map (Space key)
- [x] add way to deactivate fov (F2 key)
- [x] add fov
- [x] add basic map generation
- [x] make the @ move

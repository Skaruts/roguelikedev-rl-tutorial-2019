# r/RoguelikeDev Does The Complete Roguelike Tutorial 2019
![RoguelikeDev Does the Complete Roguelike Tutorial Event Logo](https://i.imgur.com/3MAzEp1.png)

I'm using Nim and libtcod and not exactly doing a 1:1 reproduction of the tutorial, though I'm trying to follow the same progression. So you can expect me to be implementing the same things the tutorial is teaching each week.

I'm storing the weekly developments in branches, while I advance in the master branch.

---

I've no clue where I'm going with this. I'm just making it up as I go. The main purpose is for me to exercise my knowledge of Nim, and to experiment with whatever comes up. This is also a nice opportunity to force myself to go all the way through, rather than wasting time with implementation details (and premature optimizations), which is a recurring problem I have.

So far the idea is more or less kinda sorta like...
There's a forest. In that forest there's a village. So that means there -will- should be villagers. I'm thinking of laying out some sort of treasure here and there, and some baddies. I'm also thinking there should be a graveyard, for whatever reason. I have quite a few ideas, but none definitive.

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

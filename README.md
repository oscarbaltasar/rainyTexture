# rainyTexture
A module created for the Figura mod

## Information on this repository

This repository is an example Figura avatar that you can import directly into your figura avatar folder. For the module itself, read the following:  
- RainyTexture.lua: The module itself, you'll probably want to copy this into your own avatar
- script.lua: an example script with a simple logic to alter the rain colour every tick

## Information on the module
This module works on textures, not on models. All models that use that same texture will see the same effect at no more cost.  Updating a whole positions array is a costly procedure, this is why this module will divide the texture into columns and work individually from there. If you want you can disable columns using a true/false list in the creation of the rainyTexture.  
The more pixel there are on screen the more resources this will consume, if you care for performance as much as me you'll probably want to do some tricks by disabling columns, reducing the spawn cooldown and reducing speed for bigger textures.  
This example shows a 32x32 texture being updated on each tick. This can consume anywhere between 2000 and 6000 instructions per tick.
Windower compatibility shim for Ashita
--------------------------------------

This module tries to implement the lua environment
a Windower addon expects to find.

Only a small subset of the available functionality is implemented.
Most libraries and the resources are from Windower 4 itself.

It has been tested with only one addon so far: battlemod.
As such it should be considered experimental software.

How to use:

1. copy or link the windower folder inside the addon folder.
2. add a require 'windower.shim' line to the main addon lua
   This line must be the first require statement in the lua code

See the battlemod addon included in this repo as example.

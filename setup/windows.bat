@echo off
color 0a
@echo on
echo Wait a bit, might take a lil long depending on your internet speed.

haxelib --quiet install flixel 5.6.2
haxelib --quiet install flixel-addons 3.2.2
haxelib --quiet install flixel-tools 1.5.1
haxelib --quiet install lime 8.1.3
haxelib --quiet install openfl 9.3.3
haxelib --quiet install hscript 2.6.0
haxelib --quiet install hscript-iris 1.1.3
haxelib --quiet install tjson 1.4.0
haxelib --quiet install hxdiscord_rpc 1.2.4
haxelib --quiet install hxcpp
haxelib --quiet install hxcpp-debug-server
haxelib --quiet --skip-dependencies hxvlc 2.0.1
haxelib --quiet git flxanimate https://github.com/Dot-Stuff/flxanimate 768740a56b26aa0c072720e0d1236b94afe68e3e
haxelib --quiet git funkin.vis https://github.com/FunkinCrew/funkVis 22b1ce089dd924f15cdc4632397ef3504d464e90
haxelib --quiet git grig.audio https://gitlab.com/haxe-grig/grig.audio.git cbf91e2180fd2e374924fe74844086aab7891666
haxelib run lime setup

echo Donezo! Go ahead, enjoy compiling my shitty fork.
pause
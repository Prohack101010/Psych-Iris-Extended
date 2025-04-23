#!/bin/sh
# SETUP FOR MAC AND LINUX SYSTEMS!!!
# REMINDER THAT YOU NEED HAXE INSTALLED PRIOR TO USING THIS
# https://haxe.org/download
cd ..
echo Makking the main haxelib and setuping folder in same time..
haxelib setup ~/haxelib
echo Installing dependencies...
echo This might take a few moments depending on your internet speed.
haxelib install openfl 9.3.3 --quiet
haxelib git linc_luajit https://github.com/PsychExtendedThings/linc_luajit --quiet
haxelib install tjson --quiet
haxelib git flixel https://github.com/MobilePorting/flixel 5.6.1 --quiet
haxelib install flixel-addons 3.2.2 --quiet
haxelib install flixel-ui 2.4.0 --quiet
haxelib git SScript https://github.com/PsychExtendedThings/SScript --quiet
haxelib git hscript-iris https://github.com/PsychExtendedThings/hscript-iris --quiet
haxelib install hscript 2.4.0 --quiet
haxelib git hxCodec https://github.com/MobilePorting/hxCodec-0.6.3 --quiet
haxelib git hxcpp https://github.com/MobilePorting/hxcpp --quiet
haxelib git lime https://github.com/MobilePorting/lime --quiet
haxelib install openfl 9.3.3 --quiet
haxelib git flxanimate https://github.com/ShadowMario/flxanimate.git dev --quiet
haxelib git funkin.vis https://github.com/beihu235/funkVis-FrequencyFixed main --quiet
haxelib git grig.audio https://gitlab.com/haxe-grig/grig.audio.git 57f5d47f2533fd0c3dcd025a86cb86c0dfa0b6d2 --quiet
echo Finished!
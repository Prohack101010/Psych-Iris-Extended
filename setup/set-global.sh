#!/bin/bash
cd ..
echo Setting dependencies...
haxelib dev linc_luajit /root/haxelib/linc_luajit/git
#haxelib dev extension-androidtools /root/haxelib/extension-androidtools/git -It's dead
haxelib dev tjson /root/haxelib/tjson/1,4,0
haxelib dev flixel /root/haxelib/flixel/git
haxelib dev flixel-addons /root/haxelib/flixel-addons/3,2,2
haxelib dev flixel-ui /root/haxelib/flixel-ui/2,4,0
haxelib dev SScript /root/haxelib/SScript/git
haxelib dev hscript-iris /root/haxelib/hscript-iris/git
haxelib dev hscript /root/haxelib/hscript/2,4,0
haxelib dev hxCodec /root/haxelib/hxCodec/git
haxelib dev hxcpp /root/haxelib/hxcpp/git
haxelib dev lime /root/haxelib/lime/git
haxelib dev openfl /root/haxelib/openfl/9,3,3
haxelib dev flxanimate /root/haxelib/flxanimate/git
haxelib dev funkin.vis /root/haxelib/funkin,vis/git
haxelib dev grig.audio /root/haxelib/grig,audio/git
echo Finished!
package statelua;

import flixel.FlxSprite;
import flixel.FlxG;

using StringTools;

//
// This is simply where i store deprecated functions for it to be more organized.
// I would suggest not messing with these, as it could break mods.
//

class DeprecatedFunctions
{
	public static function implement(funk:StateLua)
	{
		var lua:State = funk.lua;
		// DEPRECATED, DONT MESS WITH THESE SHITS, ITS JUST THERE FOR BACKWARD COMPATIBILITY
		Lua_helper.add_callback(lua, "objectPlayAnimation", function(obj:String, name:String, forced:Bool = false, ?startFrame:Int = 0) {
			StateLua.luaTrace("objectPlayAnimation is deprecated! Use playAnim instead", false, true);
			if(ScriptState.instance.getLuaObject(obj,false) != null) {
				ScriptState.instance.getLuaObject(obj,false).animation.play(name, forced, false, startFrame);
				return true;
			}

			var spr:FlxSprite = Reflect.getProperty(LuaUtils.getTargetInstance(), obj);
			if(spr != null) {
				spr.animation.play(name, forced, false, startFrame);
				return true;
			}
			return false;
		});
		Lua_helper.add_callback(lua, "characterPlayAnim", function(character:String, anim:String, ?forced:Bool = false) {
			StateLua.luaTrace("characterPlayAnim is deprecated! Use playAnim instead", false, true);
			switch(character.toLowerCase()) {
				case 'dad':
					if(ScriptState.instance.dad.animOffsets.exists(anim))
						ScriptState.instance.dad.playAnim(anim, forced);
				case 'gf' | 'girlfriend':
					if(ScriptState.instance.gf != null && ScriptState.instance.gf.animOffsets.exists(anim))
						ScriptState.instance.gf.playAnim(anim, forced);
				default:
					if(ScriptState.instance.boyfriend.animOffsets.exists(anim))
						ScriptState.instance.boyfriend.playAnim(anim, forced);
			}
		});
		Lua_helper.add_callback(lua, "luaSpriteMakeGraphic", function(tag:String, width:Int, height:Int, color:String) {
			StateLua.luaTrace("luaSpriteMakeGraphic is deprecated! Use makeGraphic instead", false, true);
			if(ScriptState.instance.modchartSprites.exists(tag)) {
				var colorNum:Int = Std.parseInt(color);
				if(!color.startsWith('0x')) colorNum = Std.parseInt('0xff' + color);

				ScriptState.instance.modchartSprites.get(tag).makeGraphic(width, height, colorNum);
			}
		});
		Lua_helper.add_callback(lua, "luaSpriteAddAnimationByPrefix", function(tag:String, name:String, prefix:String, framerate:Int = 24, loop:Bool = true) {
			StateLua.luaTrace("luaSpriteAddAnimationByPrefix is deprecated! Use addAnimationByPrefix instead", false, true);
			if(ScriptState.instance.modchartSprites.exists(tag)) {
				var cock:ModchartSprite = ScriptState.instance.modchartSprites.get(tag);
				cock.animation.addByPrefix(name, prefix, framerate, loop);
				if(cock.animation.curAnim == null) {
					cock.animation.play(name, true);
				}
			}
		});
		Lua_helper.add_callback(lua, "luaSpriteAddAnimationByIndices", function(tag:String, name:String, prefix:String, indices:String, framerate:Int = 24) {
			StateLua.luaTrace("luaSpriteAddAnimationByIndices is deprecated! Use addAnimationByIndices instead", false, true);
			if(ScriptState.instance.modchartSprites.exists(tag)) {
				var strIndices:Array<String> = indices.trim().split(',');
				var die:Array<Int> = [];
				for (i in 0...strIndices.length) {
					die.push(Std.parseInt(strIndices[i]));
				}
				var pussy:ModchartSprite = ScriptState.instance.modchartSprites.get(tag);
				pussy.animation.addByIndices(name, prefix, die, '', framerate, false);
				if(pussy.animation.curAnim == null) {
					pussy.animation.play(name, true);
				}
			}
		});
		Lua_helper.add_callback(lua, "luaSpritePlayAnimation", function(tag:String, name:String, forced:Bool = false) {
			StateLua.luaTrace("luaSpritePlayAnimation is deprecated! Use playAnim instead", false, true);
			if(ScriptState.instance.modchartSprites.exists(tag)) {
				ScriptState.instance.modchartSprites.get(tag).animation.play(name, forced);
			}
		});
		Lua_helper.add_callback(lua, "setLuaSpriteCamera", function(tag:String, camera:String = '') {
			StateLua.luaTrace("setLuaSpriteCamera is deprecated! Use setObjectCamera instead", false, true);
			if(ScriptState.instance.modchartSprites.exists(tag)) {
				ScriptState.instance.modchartSprites.get(tag).cameras = [LuaUtils.cameraFromString(camera)];
				return true;
			}
			StateLua.luaTrace("Lua sprite with tag: " + tag + " doesn't exist!");
			return false;
		});
		Lua_helper.add_callback(lua, "setLuaSpriteScrollFactor", function(tag:String, scrollX:Float, scrollY:Float) {
			StateLua.luaTrace("setLuaSpriteScrollFactor is deprecated! Use setScrollFactor instead", false, true);
			if(ScriptState.instance.modchartSprites.exists(tag)) {
				ScriptState.instance.modchartSprites.get(tag).scrollFactor.set(scrollX, scrollY);
				return true;
			}
			return false;
		});
		Lua_helper.add_callback(lua, "scaleLuaSprite", function(tag:String, x:Float, y:Float) {
			StateLua.luaTrace("scaleLuaSprite is deprecated! Use scaleObject instead", false, true);
			if(ScriptState.instance.modchartSprites.exists(tag)) {
				var shit:ModchartSprite = ScriptState.instance.modchartSprites.get(tag);
				shit.scale.set(x, y);
				shit.updateHitbox();
				return true;
			}
			return false;
		});
		Lua_helper.add_callback(lua, "getPropertyLuaSprite", function(tag:String, variable:String) {
			StateLua.luaTrace("getPropertyLuaSprite is deprecated! Use getProperty instead", false, true);
			if(ScriptState.instance.modchartSprites.exists(tag)) {
				var killMe:Array<String> = variable.split('.');
				if(killMe.length > 1) {
					var coverMeInPiss:Dynamic = Reflect.getProperty(ScriptState.instance.modchartSprites.get(tag), killMe[0]);
					for (i in 1...killMe.length-1) {
						coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
					}
					return Reflect.getProperty(coverMeInPiss, killMe[killMe.length-1]);
				}
				return Reflect.getProperty(ScriptState.instance.modchartSprites.get(tag), variable);
			}
			return null;
		});
		Lua_helper.add_callback(lua, "setPropertyLuaSprite", function(tag:String, variable:String, value:Dynamic) {
			StateLua.luaTrace("setPropertyLuaSprite is deprecated! Use setProperty instead", false, true);
			if(ScriptState.instance.modchartSprites.exists(tag)) {
				var killMe:Array<String> = variable.split('.');
				if(killMe.length > 1) {
					var coverMeInPiss:Dynamic = Reflect.getProperty(ScriptState.instance.modchartSprites.get(tag), killMe[0]);
					for (i in 1...killMe.length-1) {
						coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
					}
					Reflect.setProperty(coverMeInPiss, killMe[killMe.length-1], value);
					return true;
				}
				Reflect.setProperty(ScriptState.instance.modchartSprites.get(tag), variable, value);
				return true;
			}
			StateLua.luaTrace("setPropertyLuaSprite: Lua sprite with tag: " + tag + " doesn't exist!");
			return false;
		});
		Lua_helper.add_callback(lua, "musicFadeIn", function(duration:Float, fromValue:Float = 0, toValue:Float = 1) {
			FlxG.sound.music.fadeIn(duration, fromValue, toValue);
			StateLua.luaTrace('musicFadeIn is deprecated! Use soundFadeIn instead.', false, true);

		});
		Lua_helper.add_callback(lua, "musicFadeOut", function(duration:Float, toValue:Float = 0) {
			FlxG.sound.music.fadeOut(duration, toValue);
			StateLua.luaTrace('musicFadeOut is deprecated! Use soundFadeOut instead.', false, true);
		});
	}
}
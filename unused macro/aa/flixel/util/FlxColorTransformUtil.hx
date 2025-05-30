package flixel.util;

import openfl.geom.ColorTransform;

class FlxColorTransformUtil
{
	public inline static function setMultipliers(transform:ColorTransform, red:Float, green:Float, blue:Float, alpha:Float):ColorTransform
	{
		transform.redMultiplier = red;
		transform.greenMultiplier = green;
		transform.blueMultiplier = blue;
		transform.alphaMultiplier = alpha;

		return transform;
	}

	public inline static function setOffsets(transform:ColorTransform, red:Float, green:Float, blue:Float, alpha:Float):ColorTransform
	{
		transform.redOffset = red;
		transform.greenOffset = green;
		transform.blueOffset = blue;
		transform.alphaOffset = alpha;

		return transform;
	}

	/**
	 * Returns whether red, green, or blue multipliers are set to anything other than 1.
	 */
	public inline static function hasRGBMultipliers(transform:ColorTransform):Bool
	{
		return transform.redMultiplier != 1 || transform.greenMultiplier != 1 || transform.blueMultiplier != 1;
	}

	/**
	 * Returns whether red, green, blue, or alpha multipliers are set to anything other than 1.
	 */
	public inline static function hasRGBAMultipliers(transform:ColorTransform):Bool
	{
		return transform.redMultiplier != 1 || transform.greenMultiplier != 1 || transform.blueMultiplier != 1 || transform.alphaMultiplier != 1;
	}

	/**
	 * Returns whether red, green, or blue offsets are set to anything other than 0.
	 */
	public inline static function hasRGBOffsets(transform:ColorTransform):Bool
	{
		return transform.redOffset != 0 || transform.greenOffset != 0 || transform.blueOffset != 0;
	}

	/**
	 * Returns whether red, green, blue, or alpha offsets are set to anything other than 0.
	 */
	public inline static function hasRGBAOffsets(transform:ColorTransform):Bool
	{
		return transform.redOffset != 0 || transform.greenOffset != 0 || transform.blueOffset != 0 || transform.alphaOffset != 0;
	}
}

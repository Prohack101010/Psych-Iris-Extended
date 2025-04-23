package scripting.macros;

/**
 * Macros containing additional help functions to expand HScript capabilities.
 */
class Macros {
	public static function initMacros() {
		if(Context.defined("hl"))
			HashLinkFixer.init();
	}
}
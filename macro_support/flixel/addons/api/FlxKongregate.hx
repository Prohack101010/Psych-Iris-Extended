package flixel.addons.api;

#if flash
import openfl.display.DisplayObject;
import openfl.display.Loader;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.URLRequest;
import openfl.system.Security;
import flixel.FlxG;

/**
 * Allows for easy access to the Kongregate API
 *
 * Todo: Add in the functions for Chat Integration - you can still use them via the FlxKongregate.api object.
 *
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
 */
class FlxKongregate
{
	/**
	 * The Kongregate API object. You can make calls directly to this once the API has connected.
	 */
	public static var api:Dynamic;

	/**
	 * True if the API has loaded otherwise false. Loaded is not the same thing as connected, it just means it's ready for the connection.
	 */
	public static var hasLoaded:Bool = false;

	/**
	 * Is the game running locally in Shadow API mode (true) or from Kongregates servers (false)
	 */
	public static var isLocal:Bool = false;

	static inline var SHADOW_API:String = "http://www.kongregate.com/flash/API_AS3_Local.swf";
	static var _apiLoader:Loader;
	static var _loadCallback:Dynamic;

	/**
	 * Loads the Kongregate API and if successful connects to the service.
	 * Note that your game must have access to Stage by this point.
	 *
	 * @param   Callback    This function is called if the API loads successfully. Do not call any API function until this has happened.
	 */
	public static function init(Callback:Dynamic):Void
	{
		var parameters:Dynamic;

		try
		{
			parameters = FlxG.stage.loaderInfo.parameters;
		}
		catch (e:String)
		{
			throw "FlxKongregate: No access to FlxG.stage - only call this once your game has access to the display list";
			return;
		}

		var apiPath:String;

		if (parameters.kongregate_api_path)
		{
			Security.allowDomain(parameters.kongregate_api_path);
			apiPath = parameters.kongregate_api_path;
		}
		else
		{
			Security.allowDomain(SHADOW_API);
			apiPath = SHADOW_API;
			isLocal = true;
		}

		_loadCallback = Callback;

		_apiLoader = new Loader();
		_apiLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, apiLoadComplete, false, 0, true);
		_apiLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, apiLoadError, false, 0, true);
		_apiLoader.load(new URLRequest(apiPath));

		FlxG.stage.addChild(_apiLoader);
	}

	/**
	 * Remove the API from memory (when possible) and removes it from the display list also
	 */
	public static function disconnect():Void
	{
		api = null;

		hasLoaded = false;

		FlxG.stage.removeChild(_apiLoader);
	}

	static function apiLoadComplete(E:Event):Void
	{
		api = (cast E.target).content;

		hasLoaded = true;

		Security.allowDomain(api.loaderInfo.url);

		if ((_loadCallback is Dynamic))
		{
			_loadCallback.call();
		}
	}

	static function apiLoadError(E:IOErrorEvent):Void
	{
		FlxG.log.add("Error loading Kongregate API:" + E);
	}

	/**
	 * Use the addLoadListener function to register an event listener which will be triggered when content of the specified type is loaded by the user.
	 * These MUST be set-up *before* you call FlxKongregate.connect()
	 * See: http://www.kongregate.com/developer_center/docs/shared-content-api
	 *
	 * @param   ContentType     Type of content to listen for
	 * @param   Callback        Function to call when content load request has been made
	 */
	public static function addLoadListener(ContentType:String, Callback:Void->Void):Void
	{
		api.sharedContent.addLoadListener(ContentType, Callback);
	}

	/**
	 * Register an event listener with the API. Useful for capturing guest to user login requests for example.
	 * See: http://www.kongregate.com/developer_center/docs/handling-guests
	 *
	 * @param   ContentType     The event to listen for (i.e. "login")
	 * @param   Callback        Funcation to call when this event is received
	 */
	public static function addEventListener(ContentType:String, Callback:Void->Void):Void
	{
		api.services.addEventListener(ContentType, Callback);
	}

	/**
	 * Connect to the Kongregate API. This should be called only after the init callback reports a succesful load of the API
	 */
	public static function connect():Void
	{
		if (hasLoaded)
		{
			api.services.connect();
		}
	}

	/**
	 * The isGuest function can be called to determine if the player is currently signed into Kongregate or not
	 */
	public static function isGuest():Bool
	{
		return api.services.isGuest();
	}

	/**
	 * You can use the getUsername() function to retrieve the username of the current player. It will begin with Guest if the user is not signed in.
	 */
	public static function getUserName():String
	{
		return api.services.getUsername();
	}

	/**
	 * You can use the getUserId() function to retrieve the unique user id of the current player. It will return 0 if the user is not signed in.
	 */
	public static function getUserId():Float
	{
		try
		{
			return api.services.getUserId();
		}
		catch (e:String)
		{
			return 0;
		}

		return 0;
	}

	/**
	 * If you are using the Authentication API you can use the getGameAuthToken function to get the player's game authentication token.
	 */
	public static function getGameAuthToken():String
	{
		return api.services.getGameAuthToken();
	}

	/**
	 * If the player is a guest, and you want to display the sign-in/registration UI to them you can use the showSignInBox function.
	 */
	public static function showSignInBox():Void
	{
		if (api.services.isGuest())
		{
			api.services.showSignInBox();
		}
	}

	/**
	 * This call works the same way as showSigninBox, but it focuses the registration form rather than the sign-in form.
	 */
	public static function showRegistrationBox():Void
	{
		if (api.services.isGuest())
		{
			api.services.showRegistrationBox();
		}
	}

	/**
	 * If a player is logged-in and you want to allow them to post a shout on their profile page, you may bring up the shout box, optionally populated with some initial content.
	 *
	 * @param   Message		The optional initial content
	 */
	public static function showShoutBox(Message:String = ""):Void
	{
		if (api.services.isGuest() == false)
		{
			api.services.showShoutBox(Message);
		}
	}

	/**
	 * If you need to resize your game's enclosing container, you may do so with resizeGame call. The enclosing iframe will resize around your game.
	 * Games may not be resized smaller than their initial dimensions. This call requires special permission from Kongregate to use.
	 *
	 * @param   Width	New width (in pixels) of the container
	 * @param   Height	New height (in pixels) of the container
	 */
	public static function resizeGame(Width:Int, Height:Int):Void
	{
		api.services.resizeGame(Width, Height);
	}

	/**
	 * Submit a statistic to the Kongregate server. Make sure you have defined the stat before calling this.
	 * See the Kongregate API documentation for details.
	 *
	 * @param   Name	The name of the statistic
	 * @param   Value	The value to submit (will be converted to an integer server-side)
	 */
	public static function submitStats(Name:String, Value:Float):Void
	{
		api.stats.submit(Name, Value);
	}

	/**
	 * Submit a score to the Kongregate server. Make sure you have defined the stat before calling this.
	 * See the Kongregate API documentation for details.
	 *
	 * @param   Score	The value of the score
	 * @param   Mode	What game mode this score is for, like "Hard" or "Normal"
	 */
	public static function submitScore(Score:Float, Mode:String):Void
	{
		api.scores.submit(Score, Mode);
	}

	/**
	 * Bring up the "purchase items" dialog box by using the purchaseItems method on the microtransaction services object.
	 * Your game must be in the Kongregate Microtransactions beta to use this function.
	 * See: http://www.kongregate.com/developer_center/docs/microtransaction-client-api
	 *
	 * @param   Items       The array of item identifier strings or item/metadata objects.
	 * @param   Callback    The callback function
	 */
	public static function purchaseItem(Items:Array<Dynamic>, Callback:Void->Void):Void
	{
		api.mtx.purchaseItems(Items, Callback);
	}

	/**
	 * Request the inventory of any user.
	 * Your game must be in the Kongregate Microtransactions beta to use this function.
	 * See: http://www.kongregate.com/developer_center/docs/microtransaction-client-api
	 *
	 * @param   Username    The username to request inventory for, or null for the current player
	 * @param   Callback    The callback function
	 */
	public static function requestUserItemList(Username:String, Callback:Void->Void):Void
	{
		api.mtx.requestUserItemList(Username, Callback);
	}

	/**
	 * Display the Kred purchasing Dialog.
	 * Your game must be in the Kongregate Microtransactions beta to use this function.
	 * See: http://www.kongregate.com/developer_center/docs/microtransaction-client-api
	 *
	 * @param   PurchaseMethod   The purchase method to display. Should be "offers" or "mobile"
	 */
	public static function showKredPurchaseDialog(PurchaseMethod:String):Void
	{
		api.mtx.showKredPurchaseDialog(PurchaseMethod);
	}

	/**
	 * The browse function causes a list of shared content to appear in the user's browser.
	 * This will allow them to view, rate, or load shared content for your game.
	 * See: http://www.kongregate.com/developer_center/docs/shared-content-api
	 *
	 * @param   ContentType     Type of content to browse
	 * @param   SortOrder       Optional constant specifying how to sort content (see API docs)
	 * @param   Label           Optional, only browse content saved with the specified label
	 */
	public static function browseSharedContent(ContentType:String, ?SortOrder:String, ?Label:String):Void
	{
		api.sharedContent.browse(ContentType, SortOrder, Label);
	}

	/**
	 * Use the save function to submit shared content on the Kongregate back-end.
	 * See: http://www.kongregate.com/developer_center/docs/shared-content-api
	 *
	 * @param   ContentType		Type of content the user wishes to save, 12 characters max.
	 * @param   Content			Value of content to be saved. We strongly recommend keeping these values under 100K.
	 * @param   Callback		Function to call when save has finished.
	 * @param   Thumb			Optional but highly recommended! Send us a DisplayObject that we will snapshotted and used as a thumbnail for the content.
	 * @param   Label			Optional, label for sub-classing the shared content.
	 */
	public static function saveSharedContent(ContentType:String, Content:String, Callback:Void->Void, ?Thumb:DisplayObject, ?Label:String):Void
	{
		api.sharedContent.save(ContentType, Content, Callback, Thumb, Label);
	}

	/**
	 * Export a DisplayObject to be converted to a user avatar. It is highly recommended that avatars be at least 40 x 40px.
	 * See: http://www.kongregate.com/developer_center/docs/avatar-api
	 *
	 * @param   Avatar      Can be null, but highly recommended that you send yourself. If null, we will snapshot the stage.
	 * @param   Callback    Function to call when content load request has been made
	 */
	public static function submitAvatar(Avatar:DisplayObject, Callback:Void->Void):Void
	{
		api.images.submitAvatar(Avatar, Callback);
	}
}
#end

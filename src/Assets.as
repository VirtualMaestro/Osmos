/**
 * User: VirtualMaestro
 * Date: 08.08.13
 * Time: 17:22
 */
package
{
	import bb.render.textures.BBTexture;

	import treefortress.sound.SoundAS;

	/**
	 */
	public class Assets
	{
		//** IMAGES **//
		[Embed(source="../assets/osmosSplash.jpg")]
		static private var osmosSplashImg:Class;

		[Embed(source="../assets/ironFloor.jpg")]
		static private var floorImg:Class;

		[Embed(source="../assets/ball.png")]
		static private var ballImg:Class;

		//** SOUNDS **//
		[Embed(source="../assets/hitWall.mp3")]
		static private var hitWallSnd:Class;

		[Embed(source="../assets/loop.mp3")]
		static private var loopSnd:Class;

		[Embed(source="../assets/win.mp3")]
		static private var winSnd:Class;

		[Embed(source="../assets/lose.mp3")]
		static private var loseSnd:Class;

		[Embed(source="../assets/absorption.mp3")]
		static private var absorptionSnd:Class;

		//
		static public var BACKGROUND_SPLASH_ID:String = "BACKGROUND_SPLASH_ID";
		static public var BACKGROUND_PLAY_ID:String = "BACKGROUND_PLAY_ID";
		static public var BACKGROUND_LOSE_ID:String = "BACKGROUND_LOSE_ID";
		static public var BACKGROUND_WIN_ID:String = "BACKGROUND_WIN_ID";
		static public var SPHERE_ID:String = "SPHERE_ID";
		static public var FLOOR_ID:String = "FLOOR_ID";

		//
		static public var HIT_WALL_SND:String = "HIT_WALL_SND";
		static public var MAIN_LOOP_SND:String = "MAIN_LOOP_SND";
		static public var WIN_SND:String = "WIN_SND";
		static public var LOSE_SND:String = "LOSE_SND";
		static public var ABSORPTION_SND:String = "ABSORPTION_SND";

		/**
		 */
		static public function init():void
		{
			// Textures
			BBTexture.createFromAsset(osmosSplashImg, BACKGROUND_SPLASH_ID);
			BBTexture.createFromAsset(floorImg, FLOOR_ID, false);
			BBTexture.createFromColorRect(800, 600, BACKGROUND_PLAY_ID);
			BBTexture.createFromColorRect(400, 200, BACKGROUND_LOSE_ID, 0xaaFF0000);
			BBTexture.createFromColorRect(400, 200, BACKGROUND_WIN_ID, 0xaa00FF00);
			BBTexture.createFromAsset(ballImg, SPHERE_ID);

			// Sounds
			SoundAS.addSound(HIT_WALL_SND, new hitWallSnd());
			SoundAS.addSound(MAIN_LOOP_SND, new loopSnd());
			SoundAS.addSound(WIN_SND, new winSnd());
			SoundAS.addSound(LOSE_SND, new loseSnd());
			SoundAS.addSound(ABSORPTION_SND, new absorptionSnd());
		}
	}
}

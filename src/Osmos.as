package
{

	import bb.config.BBConfig;
	import bb.core.BabyBox;
	import bb.mouse.constants.BBMouseActions;
	import bb.signals.BBSignal;
	import bb.vo.BBColor;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	import modules.GameLoop;
	import modules.PhysicsInteractionHandler;

	/**
	 */
	[SWF(width="800", height="600", frameRate="30")]
	public class Osmos extends Sprite
	{
		private var _babyBox:BabyBox;
		public function Osmos()
		{
			 if (stage) loadSettings();
			else addEventListener(Event.ADDED_TO_STAGE, loadSettings);
		}

		/**
		 */
		private function loadSettings(p_event:Event = null):void
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, parseSettings);
			loader.load(new URLRequest("settings.txt"));
		}

		/**
		 */
		private function parseSettings(p_event:Event):void
		{
			var loader:URLLoader = (p_event.target as URLLoader);
			loader.removeEventListener(Event.COMPLETE, parseSettings);

			var settings:Object = JSON.parse(loader.data);

			var hero:Object = settings.hero;
			var heroColor:Object = hero.color;
			Config.heroColor.setARGB255(parseInt(heroColor.alpha), parseInt(heroColor.red), parseInt(heroColor.green), parseInt(heroColor.blue));
			Config.heroMaxSpeed = parseFloat(settings.hero.maxSpeed);
			Config.heroAcceleration = parseFloat(settings.hero.acceleration);

			var enemy:Object = settings.enemy;
			var startColor:Object = enemy.colorStart;
			var endColor:Object = enemy.colorEnd;
			Config.startEnemyColor.setARGB255(parseInt(startColor.alpha), parseInt(startColor.red), parseInt(startColor.green), parseInt(startColor.blue));
			Config.endEnemyColor.setARGB255(parseInt(endColor.alpha), parseInt(endColor.red), parseInt(endColor.green), parseInt(endColor.blue));
			Config.numEnemies = parseInt(enemy.quantity);
			Config.minSphereRadius = parseFloat(enemy.minRadius);
			Config.maxSphereRadius = parseFloat(enemy.maxRadius);

			Config.worldWidth = parseInt(settings.world.width);
			Config.worldHeight = parseInt(settings.world.height);

			//
			initEngine();
		}

		/**
		 */
		private function initEngine():void
		{
			_babyBox = BabyBox.get();
			var config:BBConfig = new BBConfig(800, 600, 40);
			config.physicsEnable = true;
			config.setGravity(0,0);
			config.handEnable = true;
			config.debugMode = false;
			config.mouseSettings = BBMouseActions.UP | BBMouseActions.DOWN;
			config.mouseNodeSettings = BBMouseActions.UP | BBMouseActions.DOWN;
			config.isCulling = true;

			_babyBox.onInitialized.add(startGame);
			_babyBox.init(stage, config);
		}

		/**
		 */
		private function startGame(p_signal:BBSignal):void
		{
			_babyBox.addModule(GameLoop);
			_babyBox.addModule(PhysicsInteractionHandler);
		}
	}
}

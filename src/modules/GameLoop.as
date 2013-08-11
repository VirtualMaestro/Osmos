/**
 * User: VirtualMaestro
 * Date: 08.08.13
 * Time: 17:04
 */
package modules
{
	import actors.SphereFactory;
	import actors.components.SphereLogic;

	import bb.camera.BBCamerasModule;
	import bb.camera.components.BBCamera;
	import bb.core.BBNode;
	import bb.layer.BBLayerModule;
	import bb.layer.constants.BBLayerNames;
	import bb.modules.BBModule;
	import bb.physics.components.BBPhysicsBody;
	import bb.prototyping.BBPrototyping;
	import bb.render.components.BBSprite;
	import bb.render.textures.BBTexture;
	import bb.signals.BBSignal;
	import bb.vo.BBColor;
	import bb.world.BBWorldModule;

	import bb_fsm.BBFSM;

	import de.polygonal.ds.DLL;
	import de.polygonal.ds.DLLNode;

	import flash.geom.Rectangle;

	import modules.gameStates.LoseState;
	import modules.gameStates.SplashState;
	import modules.gameStates.WinState;

	import nape.geom.Vec3;
	import nape.phys.BodyType;

	import vm.math.numbers.NumberUtil;
	import vm.math.rand.RandUtil;

	/**
	 */
	public class GameLoop extends BBModule
	{
		private var _fsm:BBFSM;
		private var _layerModule:BBLayerModule;
		private var _world:BBWorldModule;
		private var _enemyBalls:DLL;
		private var _hero:BBNode;
		private var _heroLogic:SphereLogic;

		private var _colorRange:int = 500;
		private var _totalArea:int;
		private var _gradient:Array;

		private var _isAbsorption:Boolean = false;
		private var _delayUpdateColors:int;

		/**
		 */
		public function GameLoop()
		{
			super();

			_enemyBalls = new DLL();
			_gradient = BBColor.getGradientStrip(Config.startEnemyColor.color, Config.endEnemyColor.color, _colorRange);
			_delayUpdateColors = Config.delayUpdateColors;

			onReadyToUse.add(initGame);
		}

		/**
		 */
		private function initGame(p_signal:BBSignal):void
		{
			_world = getModule(BBWorldModule) as BBWorldModule;

			Assets.init();
			initLayersAndCameras();
			initGameState();
		}

		/**
		 */
		private function initLayersAndCameras():void
		{
			var cameraBack:BBCamera = BBCamera.get(BBLayerNames.BACKEND);
			var cameraMain:BBCamera = BBCamera.get(BBLayerNames.MAIN);
			var cameraMenu:BBCamera = BBCamera.get(BBLayerNames.MENU);
			cameraMenu.mouseEnable = true;

			_layerModule = getModule(BBLayerModule) as BBLayerModule;
			_layerModule.add(BBLayerNames.BACKEND, true).attachCamera(cameraBack);
			_layerModule.add(BBLayerNames.MAIN, true).attachCamera(cameraMain);
			_layerModule.add(BBLayerNames.MENU, true).attachCamera(cameraMenu);

			//
			_layerModule.addTo(BBLayerNames.BACKGROUND, BBLayerNames.MAIN);
			_layerModule.addTo(BBLayerNames.MIDDLEGROUND, BBLayerNames.MAIN);
			_layerModule.addTo(BBLayerNames.FOREGROUND, BBLayerNames.MAIN);

			//
			cameraMain.border = new Rectangle(-Config.worldWidth / 2, -Config.worldHeight / 2, Config.worldWidth, Config.worldHeight);
		}

		/**
		 */
		private function initGameState():void
		{
			_fsm = BBFSM.get(this, SplashState);
			updateEnable = true;
		}

		/**
		 */
		public function createLevel():void
		{
			clearLevel();
			createFloor();
			createWalls();
			generateSpheres();
//			createHero();
			updateEnemiesColors();
		}

		/**
		 */
		private function createFloor():void
		{
			var floorTexture:BBTexture = BBTexture.getTextureById(Assets.FLOOR_ID);

			var numWidth:int = Math.ceil(Config.worldWidth / floorTexture.width);
			var numHeight:int = Math.ceil(Config.worldHeight / floorTexture.height);
			var ltX:Number = -Config.worldWidth / 2;
			var ltY:Number = -Config.worldHeight / 2;
			var ltYt:Number = ltY;
			var sprite:BBSprite;

			for (var i:int = 0; i < numWidth; i++)
			{
				for (var j:int = 0; j < numHeight; j++)
				{
					sprite = BBSprite.getWithNode(floorTexture);
					sprite.node.transform.setPosition(ltX, ltYt);
					_world.add(sprite.node, BBLayerNames.BACKGROUND);

					ltYt += 600;
				}

				ltX += 800;
				ltYt = ltY;
			}
		}

		/**
		 */
		public function clearLevel():void
		{
			_world.clear(BBLayerNames.MIDDLEGROUND);
			_world.clear(BBLayerNames.BACKGROUND);
			_world.clear(BBLayerNames.MENU);
			_world.clear(BBLayerNames.BACKEND);

			_enemyBalls.clear();
			_isAbsorption = false;
			_delayUpdateColors = Config.delayUpdateColors;
			_totalArea = 0;
		}

		/**
		 */
		private function createWalls():void
		{
			var bottomWall:BBNode = BBPrototyping.getBox(Config.worldWidth, 50, "", 0xff78513D, BodyType.STATIC, Config.wallsMaterial, Config.wallsCollisionFilter);
			bottomWall.transform.setPosition(0, Config.worldHeight / 2);
			(bottomWall.getComponent(BBPhysicsBody) as BBPhysicsBody).body.cbTypes.add(Config.wallCb);
			_world.add(bottomWall, BBLayerNames.MIDDLEGROUND);

			var topWall:BBNode = BBPrototyping.getBox(Config.worldWidth, 50, "", 0xff78513D, BodyType.STATIC, Config.wallsMaterial, Config.wallsCollisionFilter);
			topWall.transform.setPosition(0, -Config.worldHeight / 2);
			(topWall.getComponent(BBPhysicsBody) as BBPhysicsBody).body.cbTypes.add(Config.wallCb);
			_world.add(topWall, BBLayerNames.MIDDLEGROUND);

			var leftWall:BBNode = BBPrototyping.getBox(50, Config.worldHeight, "", 0xff78513D, BodyType.STATIC, Config.wallsMaterial, Config.wallsCollisionFilter);
			leftWall.transform.setPosition(-Config.worldWidth / 2, 0);
			(leftWall.getComponent(BBPhysicsBody) as BBPhysicsBody).body.cbTypes.add(Config.wallCb);
			_world.add(leftWall, BBLayerNames.MIDDLEGROUND);

			var rightWall:BBNode = BBPrototyping.getBox(50, Config.worldHeight, "", 0xff78513D, BodyType.STATIC, Config.wallsMaterial, Config.wallsCollisionFilter);
			rightWall.transform.setPosition(Config.worldWidth / 2, 0);
			(rightWall.getComponent(BBPhysicsBody) as BBPhysicsBody).body.cbTypes.add(Config.wallCb);
			_world.add(rightWall, BBLayerNames.MIDDLEGROUND);
		}

		/**
		 */
		private function generateSpheres():void
		{
			var spheresData:Vector.<Vec3> = SphereFactory.getSpheresData();
			var sphereData:Vec3;
			var enemy:BBNode;
			var numSpheres:int = spheresData.length;

			createHero(spheresData[0]);

			for (var i:int = 1; i < numSpheres; i++)
			{
				sphereData = spheresData[i];
				enemy = SphereFactory.createSphere(sphereData.z);
				enemy.transform.setPosition(sphereData.x, sphereData.y);
				_world.add(enemy, BBLayerNames.MIDDLEGROUND);
				addEnemySphereToList(enemy);

				_totalArea += (enemy.getComponent(SphereLogic) as SphereLogic).area;
			}
		}

		/**
		 */
		private function addEnemySphereToList(p_sphere:BBNode):void
		{
			p_sphere.addProperty("node", _enemyBalls.append(p_sphere));
			var logic:SphereLogic = p_sphere.getComponent(SphereLogic) as SphereLogic;
			logic.onAbsorption.add(enemyAbsorptionHandler);
			logic.onActorDestroy.add(removeFromList);
		}

		/**
		 */
		private function enemyAbsorptionHandler(p_signal:BBSignal):void
		{
			if (!hero.isDisposed) updateEnemyColor(p_signal.dispatcher.node);
		}

		/**
		 */
		private function removeFromList(p_signal:BBSignal):void
		{
			var enemyActor:BBNode = (p_signal.dispatcher as SphereLogic).node;
			var dllNode:DLLNode = enemyActor.getProperty("node") as DLLNode;
			dllNode.unlink();
			enemyActor.removeProperty("node");
		}

		/**
		 */
		private function createHero(p_sphereData:Vec3):void
		{
			_hero = SphereFactory.createSphere(p_sphereData.z);
			_hero.transform.setPosition(p_sphereData.x, p_sphereData.y);
			_hero.transform.color = Config.heroColor.color;
			_world.add(_hero, BBLayerNames.MIDDLEGROUND);

			_heroLogic = _hero.getComponent(SphereLogic) as SphereLogic;
			_heroLogic.onAbsorption.add(heroAbsorptionHandler);
			_heroLogic.onActorDestroy.add(heroDestroyed);
			_totalArea += _heroLogic.area;

			(getModule(BBCamerasModule) as BBCamerasModule).getCameraByName(BBLayerNames.MAIN).follow = _hero;
		}

		/**
		 */
		private function heroAbsorptionHandler(p_signal:BBSignal):void
		{
			_isAbsorption = true;
		}

		/**
		 */
		private function heroDestroyed(p_signal:BBSignal):void
		{
			_fsm.changeState(LoseState);
		}

		/**
		 */
		public function get hero():BBNode
		{
			return _hero;
		}

		/**
		 */
		private function updateEnemiesColors():void
		{
			var headEnemies:DLLNode = _enemyBalls.head;
			while (headEnemies)
			{
				updateEnemyColor(headEnemies.val as BBNode);
				headEnemies = headEnemies.next;
			}
		}

		/**
		 */
		private function updateEnemyColor(p_enemy:BBNode):void
		{
			var halfRange:int = _gradient.length / 2;
			var heroArea:Number = _heroLogic.area;
			var sphereLogic:SphereLogic;
			var diffArea:Number;
			var diffColor:Number;
			var newEnemyColor:int;

			sphereLogic = p_enemy.getComponent(SphereLogic) as SphereLogic;
			diffArea = sphereLogic.area - heroArea;
			diffColor = NumberUtil.convertToRange(diffArea, 0, _totalArea, 0, _colorRange * 2);
			newEnemyColor = halfRange + diffColor;
			if (newEnemyColor < 0) newEnemyColor = 0;
			else if (newEnemyColor > _gradient.length - 1) newEnemyColor = _gradient.length - 1;
			p_enemy.transform.color = _gradient[newEnemyColor];
		}

		/**
		 */
		override public function update(p_deltaTime:int):void
		{
			_fsm.update(p_deltaTime);

			if (_isAbsorption)
			{
				if (_delayUpdateColors <= 0)
				{
					_isAbsorption = false;
					updateEnemiesColors();
					_delayUpdateColors = Config.delayUpdateColors;

					if ((_totalArea - _heroLogic.area) < _heroLogic.area)
					{
						_fsm.changeState(WinState);
					}
				}

				_delayUpdateColors -= p_deltaTime;
			}
		}
	}
}

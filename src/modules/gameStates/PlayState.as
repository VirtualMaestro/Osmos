/**
 * User: VirtualMaestro
 * Date: 08.08.13
 * Time: 17:40
 */
package modules.gameStates
{
	import bb.camera.BBCamerasModule;
	import bb.core.BBNode;
	import bb.core.BBTransform;
	import bb.layer.constants.BBLayerNames;
	import bb.mouse.BBMouseModule;
	import bb.mouse.events.BBMouseEvent;
	import bb.physics.BBPhysicsModule;
	import bb.physics.components.BBPhysicsBody;
	import bb.signals.BBSignal;
	import bb.world.BBWorldModule;

	import bb_fsm.BBState;

	import modules.GameLoop;

	import nape.geom.Vec2;

	import treefortress.sound.SoundAS;

	use namespace SoundAS;

	/**
	 */
	public class PlayState extends BBState
	{
		private var _world:BBWorldModule;
		private var _cursorX:Number = 0;
		private var _cursorY:Number = 0;
		private var _hero:BBNode;
		private var _heroPhysics:BBPhysicsBody;
		private var _heroTransform:BBTransform;
		private var _direction:Vec2;
		private var _speedMax:Number = 20;
		private var _acceleration:Number = 1;
		private var _currentSpeed:Number = 0;

		/**
		 */
		public function PlayState()
		{
			super();

			_speedMax = Config.heroMaxSpeed;
			_acceleration = Config.heroAcceleration;
		}

		/**
		 */
		override public function enter():void
		{
			_world = (agent as GameLoop).getModule(BBWorldModule) as BBWorldModule;

			var cameraModule:BBCamerasModule = (agent as GameLoop).getModule(BBCamerasModule) as BBCamerasModule;
			cameraModule.getCameraByName(BBLayerNames.MENU).mouseEnable = false;
			cameraModule.getCameraByName(BBLayerNames.MAIN).mouseEnable = true;

			var mouseModule:BBMouseModule = (agent as GameLoop).getModule(BBMouseModule) as BBMouseModule;
			mouseModule.onDown.add(mouseHandler);
			mouseModule.onUp.add(mouseHandler);

			var gameLoop:GameLoop = agent as GameLoop;
			gameLoop.createLevel();

			//
			_hero = gameLoop.hero;
			_heroPhysics = _hero.getComponent(BBPhysicsBody) as BBPhysicsBody;
			_heroTransform = _hero.transform;
			_direction = Vec2.get();

			gameLoop.updateEnable = true;
			(gameLoop.getModule(BBPhysicsModule) as BBPhysicsModule).updateEnable = true;

			//
			SoundAS.playLoop(Assets.MAIN_LOOP_SND, 1);
		}

		/**
		 */
		private function mouseHandler(p_signal:BBSignal):void
		{
			var event:BBMouseEvent = p_signal.params as BBMouseEvent;

			switch (event.type)
			{
				case BBMouseEvent.DOWN:
				{
					updateEnable = true;
					_cursorX = event.worldX;
					_cursorY = event.worldY;
					break;
				}

				case BBMouseEvent.UP:
				{
					updateEnable = false;
					_currentSpeed = 0;
					break;
				}
			}
		}

		/**
		 */
		override public function update(p_deltaTime:int):void
		{
			_currentSpeed += _acceleration;
			if (_currentSpeed > _speedMax) _currentSpeed = _speedMax;

			_direction.setxy(_heroTransform.x - _cursorX, _heroTransform.y - _cursorY);
			_direction.normalise();
			_direction.muleq(_currentSpeed);
			_heroPhysics.body.applyImpulse(_direction);
		}

		/**
		 */
		override public function exit():void
		{
			(agent as GameLoop).updateEnable = false;
			((agent as GameLoop).getModule(BBPhysicsModule) as BBPhysicsModule).updateEnable = false;

			var cameraModule:BBCamerasModule = (agent as GameLoop).getModule(BBCamerasModule) as BBCamerasModule;
			cameraModule.getCameraByName(BBLayerNames.MENU).mouseEnable = true;
			cameraModule.getCameraByName(BBLayerNames.MAIN).mouseEnable = false;

			var mouseModule:BBMouseModule = (agent as GameLoop).getModule(BBMouseModule) as BBMouseModule;
			mouseModule.onDown.remove(mouseHandler);
			mouseModule.onUp.remove(mouseHandler);

			_world = null;
		}
	}
}

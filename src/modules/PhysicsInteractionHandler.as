/**
 * User: VirtualMaestro
 * Date: 08.08.13
 * Time: 20:25
 */
package modules
{
	import actors.components.SphereLogic;

	import bb.modules.BBModule;
	import bb.physics.BBPhysicsModule;
	import bb.physics.components.BBPhysicsBody;
	import bb.signals.BBSignal;

	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.CbTypeIterator;
	import nape.callbacks.CbTypeList;
	import nape.callbacks.InteractionCallback;

	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;

	import nape.callbacks.Listener;
	import nape.callbacks.OptionType;
	import nape.phys.Body;
	import nape.shape.Circle;

	import nape.space.Space;

	import treefortress.sound.SoundAS;

	/**
	 */
	public class PhysicsInteractionHandler extends BBModule
	{
		/**
		 */
		private var _space:Space;

		/**
		 */
		public function PhysicsInteractionHandler()
		{
			super();

			onReadyToUse.add(readyToUse);
		}

		/**
		 */
		private function readyToUse(p_signal:BBSignal):void
		{
			_space = (getModule(BBPhysicsModule) as BBPhysicsModule).space;
			initHandlers();
		}

		/**
		 */
		private function initHandlers():void
		{
			var onCollisionBallsListener:InteractionListener = new InteractionListener(CbEvent.ONGOING, InteractionType.SENSOR, Config.sphereCb, Config.sphereCb, onCollisionBallsHandler);
			var endCollisionBallsListener:InteractionListener = new InteractionListener(CbEvent.END, InteractionType.SENSOR, Config.sphereCb, Config.sphereCb, endCollisionBallsHandler);
			var collisionBallWallListener:InteractionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, Config.sphereCb, Config.wallCb, collisionBallWallHandler);

			_space.listeners.add(onCollisionBallsListener);
			_space.listeners.add(endCollisionBallsListener);
			_space.listeners.add(collisionBallWallListener);
		}

		/**
		 */
		private function onCollisionBallsHandler(p_cb:InteractionCallback):void
		{
			var body1:Body = p_cb.int1 as Body;
			var body2:Body = p_cb.int2 as Body;

			if (body1.shapes.length == 0 || body2.shapes.length == 0) return;

			var physics1:BBPhysicsBody = body1.userData.bb_component as BBPhysicsBody;
			var physics2:BBPhysicsBody = body2.userData.bb_component as BBPhysicsBody;

			var enemyLogic1:SphereLogic = physics1.node.getComponent(SphereLogic) as SphereLogic;
			var enemyLogic2:SphereLogic = physics2.node.getComponent(SphereLogic) as SphereLogic;

			if (enemyLogic1.area > enemyLogic2.area) enemyLogic1.absorb(physics2);
			else if (enemyLogic1.area < enemyLogic2.area) enemyLogic2.absorb(physics1);
		}

		/**
		 */
		private function endCollisionBallsHandler(p_cb:InteractionCallback):void
		{
			var body1:Body = p_cb.int1 as Body;
			var body2:Body = p_cb.int2 as Body;

			var physics1:BBPhysicsBody = body1.userData.bb_component as BBPhysicsBody;
			var physics2:BBPhysicsBody = body2.userData.bb_component as BBPhysicsBody;

			if (physics1.node && !physics1.node.isDisposed && physics1.node.isComponentExist(SphereLogic)) (physics1.node.getComponent(SphereLogic) as SphereLogic).finishAbsorption();
			if (physics2.node && !physics2.node.isDisposed && physics2.node.isComponentExist(SphereLogic)) (physics2.node.getComponent(SphereLogic) as SphereLogic).finishAbsorption();
		}

		/**
		 */
		private function collisionBallWallHandler(p_cb:InteractionCallback):void
		{
			SoundAS.playFx(Assets.HIT_WALL_SND, 0.3);
		}
	}
}

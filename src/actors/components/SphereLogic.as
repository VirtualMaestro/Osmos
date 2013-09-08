/**
 * User: VirtualMaestro
 * Date: 08.08.13
 * Time: 19:30
 */
package actors.components
{
	import bb.core.BBComponent;
	import bb.physics.components.BBPhysicsBody;
	import bb.render.components.BBSprite;
	import bb.signals.BBSignal;

	import nape.geom.Vec2;
	import nape.shape.Circle;

	import treefortress.sound.SoundAS;
	import treefortress.sound.SoundInstance;

	import vm.math.rand.RandUtil;

	/**
	 */
	public class SphereLogic extends BBComponent
	{
		static private const speed:Number = 40;
		static private const minBallArea:Number = 30;

		private var _onAbsorption:BBSignal;
		private var _onActorDestroy:BBSignal;

		private var _physics:BBPhysicsBody;
		private var _circleShape:Circle;

		public var area:Number = 0;

		private var _absorptionSnd:SoundInstance;

		private var _isAbsorption:Boolean = false;

		/**
		 */
		public function SphereLogic()
		{
			super();

			onAdded.add(addedToNode);
		}

		/**
		 */
		private function addedToNode(p_signal:BBSignal):void
		{
			_physics = node.getComponent(BBPhysicsBody) as BBPhysicsBody;
			_physics.body.applyImpulse(Vec2.weak(RandUtil.getRandRange(-speed, speed), RandUtil.getRandRange(-speed, speed)));
			_circleShape = _physics.body.shapes.at(0) as Circle;
			area = _circleShape.area;
			_absorptionSnd = SoundAS.getSound(Assets.ABSORPTION_SND);
		}

		/**
		 */
		public function absorb(p_enemy:BBPhysicsBody):void
		{
			_isAbsorption = true;

			var enemyCircle:Circle = p_enemy.body.shapes.at(0) as Circle;
			var speedAbsorption:Number = (enemyCircle.area / 5) + area * 0.005;
			var absorbArea:Number = speedAbsorption > minBallArea ? speedAbsorption : enemyCircle.area;

			area += absorbArea;
			var newRadius:Number = Math.sqrt(area / Math.PI);
			var diffRadius:Number = newRadius - _circleShape.radius;
			var coef:Number = diffRadius / _circleShape.radius;

			var graphic:BBSprite = node.getComponent(BBSprite) as BBSprite;
			var physics:BBPhysicsBody = node.getComponent(BBPhysicsBody) as BBPhysicsBody;

			physics.setScale(physics.scaleX + coef, physics.scaleY + coef);
			coef = physics.body.bounds.width / graphic.getTexture().width;
			graphic.offsetScaleX = graphic.offsetScaleY = coef;

			//
			(p_enemy.node.getComponent(SphereLogic) as SphereLogic).exhaustion(absorbArea);

			//
			if (!_absorptionSnd.isPlaying) _absorptionSnd.play();
		}

		/**
		 */
		public function finishAbsorption():void
		{
			if (_isAbsorption)
			{
				_isAbsorption = false;
				onAbsorption.dispatch();
			}
		}

		/**
		 */
		public function exhaustion(p_area:Number):void
		{
			area -= p_area;
			if (area > minBallArea)
			{
				var newRadius:Number = Math.sqrt(area / Math.PI);
				var diffRadius:Number = newRadius - _circleShape.radius;
				var coef:Number = diffRadius / _circleShape.radius;

				var graphic:BBSprite = node.getComponent(BBSprite) as BBSprite;
				var physics:BBPhysicsBody = node.getComponent(BBPhysicsBody) as BBPhysicsBody;

				physics.setScale(physics.scaleX + coef, physics.scaleY + coef);
				coef = physics.body.bounds.width / graphic.getTexture().width;
				graphic.offsetScaleX = graphic.offsetScaleY = coef;
			}
			else
			{
				onActorDestroy.dispatch();
				node.dispose();
			}
		}

		/**
		 */
		public function get onAbsorption():BBSignal
		{
			if (_onAbsorption == null) _onAbsorption = BBSignal.get(this);
			return _onAbsorption;
		}

		/**
		 */
		public function get onActorDestroy():BBSignal
		{
			if (_onActorDestroy == null) _onActorDestroy = BBSignal.get(this);
			return _onActorDestroy;
		}

		/**
		 */
		override public function dispose():void
		{
			if (_onAbsorption) _onAbsorption.dispose();
			_onAbsorption = null;

			if (_onActorDestroy) _onActorDestroy.dispose();
			_onActorDestroy = null;

			_absorptionSnd.stop();
			_absorptionSnd = null;

			_physics = null;
			_circleShape = null;

			super.dispose();

			if (cacheable)
			{
				onAdded.add(addedToNode);
			}
		}
	}
}

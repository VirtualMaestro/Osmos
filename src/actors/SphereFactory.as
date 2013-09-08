/**
 * User: VirtualMaestro
 * Date: 08.08.13
 * Time: 18:23
 */
package actors
{
	import actors.components.SphereLogic;

	import bb.core.BBNode;
	import bb.physics.components.BBPhysicsBody;
	import bb.render.components.BBSprite;
	import bb.render.textures.BBTexture;

	import nape.geom.Vec2;
	import nape.geom.Vec3;
	import nape.phys.BodyType;

	import utils.CirclePacker;

	import vm.math.rand.RandUtil;

	/**
	 */
	public class SphereFactory
	{
		/**
		 */
		static public function createSphere(p_radius:int = 0):BBNode
		{
			var radius:Number = p_radius > 0 ? p_radius : RandUtil.getIntRange(Config.minSphereRadius, Config.maxSphereRadius);
			var enemy:BBNode = BBNode.get("");
			var texture:BBTexture = BBTexture.getTextureById(Assets.SPHERE_ID);
			var sprite:BBSprite = BBSprite.get(texture);
			sprite.offsetScaleX = Number(radius * 2 / texture.width);
			sprite.offsetScaleY = Number(radius * 2 / texture.height);

			var physics:BBPhysicsBody = BBPhysicsBody.get(BodyType.DYNAMIC);
			physics.addCircle(radius, "", null, Config.sphereMaterial, Config.sphereCollisionFilter).sensorEnabled = true;
			physics.body.cbTypes.add(Config.sphereCb);

			enemy.addComponent(physics);
			enemy.addComponent(SphereLogic);
			enemy.addComponent(sprite);

			return enemy;
		}

		/**
		 */
		static public function getSpheresData():Vector.<Vec3>
		{
			return CirclePacker.getSpheres(Vec2.get(), Config.numEnemies + 1, Config.minSphereRadius, Config.maxSphereRadius,
					(Math.min(Config.worldWidth, Config.worldHeight) / 4));
		}
	}
}

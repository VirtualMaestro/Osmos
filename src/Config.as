/**
 * User: VirtualMaestro
 * Date: 08.08.13
 * Time: 19:48
 */
package
{
	import bb.physics.utils.BBPhysicFilter;
	import bb.physics.utils.BBPhysicalMaterials;
	import bb.vo.BBColor;

	import nape.callbacks.CbType;
	import nape.dynamics.InteractionFilter;
	import nape.phys.Material;

	public class Config
	{
		static private var sphereCollisionGroup:int = BBPhysicFilter.getCollisionGroup();
		static private var sphereSensorGroup:int = BBPhysicFilter.getSensorGroup();
		static private var wallsCollisionGroup:int = BBPhysicFilter.getCollisionGroup();

		static public var sphereCollisionFilter:InteractionFilter = BBPhysicFilter.getFilter(sphereCollisionGroup, [wallsCollisionGroup], null, sphereSensorGroup, [sphereSensorGroup]);
		static public var wallsCollisionFilter:InteractionFilter = BBPhysicFilter.getFilter(wallsCollisionGroup, [sphereCollisionGroup]);

		static public var sphereCb:CbType = new CbType();
		static public var wallCb:CbType = new CbType();

		static public var wallsMaterial:Material = BBPhysicalMaterials.rubber;
		static public var sphereMaterial:Material = BBPhysicalMaterials.rubber;

		static public var numEnemies:int = 100;
		static public var worldWidth:int = 1000;
		static public var worldHeight:int = 1000;

		static public var startEnemyColor:BBColor = new BBColor(1, 0, 0, 1);
		static public var endEnemyColor:BBColor = new BBColor(1, 1, 0, 0);
		static public var heroColor:BBColor = new BBColor(1, 1, 0, 0);

		static public var heroMaxSpeed:Number = 20;
		static public var heroAcceleration:Number = 1;

		static public var minSphereRadius:int = 10;
		static public var maxSphereRadius:int = 30;

		static public var delayUpdateColors:int = 1000;
	}
}

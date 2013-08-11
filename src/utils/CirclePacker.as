/**
 * User: VirtualMaestro
 * Date: 10.08.13
 * Time: 19:25
 */
package utils
{
	import nape.geom.Vec2;
	import nape.geom.Vec3;

	public class CirclePacker
	{
		static private var _packingCenter:Vec2;

		/**
		 */
		static public function getSpheres(p_packingCenter:Vec2, p_numSpheres:int, p_minRadius:Number, p_maxRadius:Number, p_minSeparation:Number):Vector.<Vec3>
		{
			_packingCenter = p_packingCenter;
			var list:Vector.<Vec3> = new <Vec3>[];
			var sphere:Vec3;
			var center:Vec2 = Vec2.get();
			var radius:Number;

			for (var i:int = 0; i < p_numSpheres; i++)
			{
				center.setxy(_packingCenter.x + Math.random() * p_minRadius, _packingCenter.y + Math.random() * p_minRadius);
				radius = p_minRadius + Math.random() * (p_maxRadius - p_minRadius);

				sphere = Vec3.get(center.x, center.y, radius);
				list.push(sphere);
			}

			center.dispose();

			packCircles(p_packingCenter, list, p_minSeparation);

			return list;
		}

		/**
		 */
		static private function packCircles(p_packingCenter:Vec2, p_circles:Vector.<Vec3>, p_minSeparation:Number):void
		{
			_packingCenter = p_packingCenter;

			p_circles.sort(comparator);

			var minSeparationSq:Number = p_minSeparation * p_minSeparation;
			var count:int = p_circles.length;
			var sphere_1:Vec3;
			var sphere_2:Vec3;

			for (var i:int = 0; i < count - 1; i++)
			{
				for (var j:int = i + 1; j < count; j++)
				{
					if (i == j) continue;

					sphere_1 = p_circles[j];
					sphere_2 = p_circles[i];

					var radius_1:Number = sphere_1.z;
					var radius_2:Number = sphere_2.z;
					var ab:Vec2 = Vec2.get(sphere_1.x - sphere_2.x, sphere_1.y - sphere_2.y);
					var r:Number = radius_1 + radius_2;

					var d:Number = Math.abs((ab.x * ab.x + ab.y * ab.y) - minSeparationSq);
					d -= Math.min(d, minSeparationSq);

					if (d < (r * r) - 0.01)
					{
						ab.normalise();
						ab.muleq((r - Math.sqrt(d)) * 0.5);

						sphere_1.x += ab.x;
						sphere_1.y += ab.y;

						sphere_2.x -= ab.x;
						sphere_2.y -= ab.y;
					}
				}
			}

//			var iterationCounter:int = 10;
//			var damping:Number = 0.2 / iterationCounter;
//            for (i = 0; i < count; i++)
//            {
//	            var circle:Vec3 = p_circles[i];
//                var  v:Vec2 = Vec2.get(circle.x - _packingCenter.x, circle.y - _packingCenter.y);
//	            v.muleq(damping);
//	            circle.x -= v.x;
//	            circle.y -= v.y;
//            }
		}

		/**
		 */
		static private function distanceToCenterSquared(p_circle:Vec3):Number
		{
			var dist:Vec2 = Vec2.get(p_circle.x - _packingCenter.x, p_circle.y - _packingCenter.y);
			return dist.x * dist.x + dist.y * dist.y;
		}

		/**
		 */
		static private function comparator(p_sphere_1:Vec3, p_sphere_2:Vec3):int
		{
			var d1:Number = distanceToCenterSquared(p_sphere_1);
			var d2:Number = distanceToCenterSquared(p_sphere_2);

			if (d1 > d2) return 1;
			else if (d1 < d2) return -1;
			else return 0;
		}
	}
}

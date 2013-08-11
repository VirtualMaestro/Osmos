/**
 * User: VirtualMaestro
 * Date: 25.07.13
 * Time: 19:16
 */
package ui.buttons
{
	import bb.render.textures.BBTexture;
	import bb.ui.BBButton;
	import bb.ui.BBLabel;

	/**
	 */
	public class ButtonsFactory
	{
		/**
		 */
		static public function getUIButton(p_text:String):BBButton
		{
			var label:BBLabel = BBLabel.getWithNode(p_text, true, 14);
			label.bold = true;
			var width:Number = label.width + 20;
			var height:Number = label.height + 10;
			var upState:BBTexture = BBTexture.createFromColorRect(width, height, "");
			var downState:BBTexture = BBTexture.createFromColorRect(width, height, "", 0xffff0000);
			var overState:BBTexture = BBTexture.createFromColorRect(width, height, "", 0xffa3d5ba);
			var button:BBButton = BBButton.get(upState, downState, overState);
			button.node.addChild(label.node);

			return button;
		}
	}
}

/**
 * User: VirtualMaestro
 * Date: 08.08.13
 * Time: 17:10
 */
package modules.gameStates
{
	import bb.layer.constants.BBLayerNames;
	import bb.render.components.BBSprite;
	import bb.render.textures.BBTexture;
	import bb.signals.BBSignal;
	import bb.ui.BBButton;
	import bb.world.BBWorldModule;

	import bb_fsm.BBState;

	import modules.GameLoop;

	import treefortress.sound.SoundAS;

	import ui.buttons.ButtonsFactory;

	/**
	 */
	public class SplashState extends BBState
	{
		private var _world:BBWorldModule;

		/**
		 */
		public function SplashState()
		{
			super();
		}

		/**
		 */
		override public function enter():void
		{
			_world = (agent as GameLoop).getModule(BBWorldModule) as BBWorldModule;
			var startGameButton:BBButton = ButtonsFactory.getUIButton("START GAME");
			startGameButton.node.onMouseUp.add(startGame);
			_world.add(startGameButton.node, BBLayerNames.MENU);

			var background:BBSprite = BBSprite.getWithNode(BBTexture.getTextureById(Assets.BACKGROUND_SPLASH_ID), "") as BBSprite;
			_world.add(background.node, BBLayerNames.BACKEND);

			//
			SoundAS.playLoop(Assets.MAIN_LOOP_SND, 0.5);
		}

		/**
		 */
		private function startGame(p_signal:BBSignal):void
		{
			fsm.changeState(PlayState);
		}

		/**
		 */
		override public function exit():void
		{
			_world.clear(BBLayerNames.MENU);
			_world.clear(BBLayerNames.BACKEND);
			_world = null;
		}
	}
}

/**
 * User: VirtualMaestro
 * Date: 09.08.13
 * Time: 9:33
 */
package modules.gameStates
{
	import bb.layer.constants.BBLayerNames;
	import bb.mouse.events.BBMouseEvent;
	import bb.physics.BBPhysicsModule;
	import bb.render.components.BBSprite;
	import bb.render.textures.BBTexture;
	import bb.signals.BBSignal;
	import bb.ui.BBButton;
	import bb.ui.BBLabel;
	import bb.world.BBWorldModule;

	import bb_fsm.BBState;

	import modules.GameLoop;

	import treefortress.sound.SoundAS;

	import ui.buttons.ButtonsFactory;

	use namespace SoundAS;

	/**
	 */
	public class LoseState extends BBState
	{
		private var _world:BBWorldModule;

		public function LoseState()
		{
			super();
		}

		/**
		 */
		override public function enter():void
		{
			var gameLoop:GameLoop = agent as GameLoop;
			gameLoop.updateEnable = false;
			gameLoop.getModule(BBPhysicsModule).updateEnable = false;

			_world = gameLoop.getModule(BBWorldModule) as BBWorldModule;
			var background:BBSprite = BBSprite.getWithNode(BBTexture.getTextureById(Assets.BACKGROUND_LOSE_ID)) as BBSprite;
			_world.add(background.node, BBLayerNames.MENU);

			//
			var label:BBLabel = BBLabel.getWithNode("NO FATE, SARAH! TRY AGAIN", true, 16);
			label.bold = true;
			label.node.transform.setPosition(0, -50);
			_world.add(label.node, BBLayerNames.MENU);

			//
			initButtons();

			//
			SoundAS.stopAll();
			SoundAS.playFx(Assets.LOSE_SND, 0.5);
		}

		/**
		 */
		private function initButtons():void
		{
			var tryAgainButton:BBButton = ButtonsFactory.getUIButton("TRY AGAIN");
			tryAgainButton.node.transform.setPosition(-50, 0);
			tryAgainButton.node.onMouseUp.add(tryAgainHandler);
			_world.add(tryAgainButton.node, BBLayerNames.MENU);

			var exitButton:BBButton = ButtonsFactory.getUIButton("EXIT");
			exitButton.node.transform.setPosition(50, 0);
			exitButton.node.onMouseUp.add(exitHandler);
			_world.add(exitButton.node, BBLayerNames.MENU);
		}

		/**
		 */
		private function tryAgainHandler(p_signal:BBSignal):void
		{
			(p_signal.params as BBMouseEvent).propagation = false;
			fsm.changeState(PlayState);
		}

		/**
		 */
		private function exitHandler(p_signal:BBSignal):void
		{
			(p_signal.params as BBMouseEvent).propagation = false;
			fsm.changeState(SplashState);
		}

		/**
		 */
		override public function exit():void
		{
			(agent as GameLoop).clearLevel();
			_world = null;
		}
	}
}

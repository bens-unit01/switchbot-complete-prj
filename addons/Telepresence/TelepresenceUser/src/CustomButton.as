package  {
	/**

	 * @author user
	 */
	public class CustomButton extends BitmapButton {
		
		
		
		[Embed(source = "img/Btn_DPad_Forward.png")]
		public static var  ButtonForward : Class;
		
		[Embed(source = "img/Btn_DPad_Forward_sel.png")]
		public static var  ButtonForwardSel : Class;
		
		[Embed(source = "img/Btn_DPad_Back.png")]
		public static var ButtonBackward : Class;
		
		[Embed(source = "img/Btn_DPad_Back_sel.png")]
		public static var  ButtonBackwardSel : Class;
		
		[Embed(source = "img/Btn_DPad_Left.png")]
		public static var ButtonLeft : Class;
		
		[Embed(source = "img/Btn_DPad_Left_sel.png")]
		public static var  ButtonLeftSel : Class;
		
		[Embed(source = "img/Btn_DPad_Right.png")]
		public static var ButtonRight : Class;
		
		[Embed(source = "img/Btn_DPad_Right_sel.png")]
		public static var  ButtonRightSel : Class;
		
		[Embed(source = "img/Background_DPad.png")]
		public static var DPadBackground : Class;

		//----- btn connect states ...
        [Embed(source = "img/Btn_Connect.png")]
		 public static var ButtonConnect : Class;
		 
		[Embed(source = "img/Btn_Connect_red1.png")]
		 public static var ButtonConnecting1 : Class;
		 
		[Embed(source = "img/Btn_Connect_red2.png")]
		 public static var ButtonConnecting2 : Class;
		 
		 [Embed(source = "img/Btn_Connect_green.png")]
		 public static var ButtonConnected : Class;
		 
		 //-------------------------
		 
		 [Embed(source = "img/Btn_Exit.png")]
		 public static var ButtonExit : Class;
		 
		 [Embed(source = "img/Btn_Exit_sel.png")]
		 public static var ButtonExitSel : Class;
    
       public  function CustomButton(ImageData:Class){
		
		   super(ImageData);
		}
		
			
		
	}
}

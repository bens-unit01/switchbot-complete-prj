package  {
	/**
	 * @author user
	 * 
	 */
	 
	    import flash.display.Bitmap;
		import flash.display.BitmapData;
		import flash.display.Sprite;
		import flash.events.MouseEvent;
	public class BitmapButton extends Sprite {
		
		

    private var _backgroundImage :Bitmap;
	private var _bitmapData:BitmapData;
    private const  THRESHOLD:Number = 0;
		
		public function BitmapButton(ImageData:Class) 
		{
		    _backgroundImage = new ImageData();
		    addChild(_backgroundImage);
		         
		    _bitmapData = _backgroundImage.bitmapData;
		     
		  //  addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		  //  addEventListener(MouseEvent.CLICK, onClick);
		}
		
		public function setBackground(ImageData:Class):void {
			removeChild(_backgroundImage);
			_backgroundImage = new ImageData();
			addChild(_backgroundImage);
		
		}
		
		
	}
}

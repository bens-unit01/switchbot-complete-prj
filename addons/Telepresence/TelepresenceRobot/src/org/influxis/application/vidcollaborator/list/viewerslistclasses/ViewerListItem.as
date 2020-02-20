package org.influxis.application.vidcollaborator.list.viewerslistclasses 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.net.NetConnection;
	import flash.events.MouseEvent;
	
	//Influxis Classes
	import org.influxis.as3.core.infx_internal;
	import org.influxis.as3.display.listclasses.ListItem;
	import org.influxis.as3.managers.DragDropManager;
	import org.influxis.as3.utils.ObjectUtils;
	import org.influxis.as3.utils.SizeUtils;
	import org.influxis.as3.utils.ScreenScaler;
	
	//Flotools Classes
	import org.influxis.flotools.containers.VideoThumb;
	import org.influxis.flotools.list.connectedlistclasses.ConnectedItem;
	
	public class ViewerListItem extends ConnectedItem
	{
		use namespace infx_internal;
		private var _thumb:VideoThumb;
		private var _mask:DisplayObject;
		private var _itemLiveBackground:DisplayObject;
		private var _dragDrop:DragDropManager;
		
		/*
		 * INIT API
		 */
		
		public function ViewerListItem( skinName:String ): void
		{
			super(skinName);
			_dragDrop = DragDropManager.getInstance();
			addEventListener( MouseEvent.MOUSE_DOWN, __onMouseEvent );
		}
		
		/*
		 * CONNECT API
		 */
		
		override public function connect(netConnection:NetConnection):Boolean 
		{
			if ( !super.connect(netConnection) ) return false;
			if ( initialized ) _thumb.connect(_netConnection);
			return true;
		}
		
		override public function close():void 
		{
			super.close();
			if ( initialized ) _thumb.close();
		}
		
		override protected function instanceClose():void 
		{
			super.instanceClose();
			if( initialized ) _thumb.instance = null;
		}
		
		override protected function instanceChange():void 
		{
			super.instanceChange();
			if( initialized ) _thumb.instance = instance;
		}
		
		override protected function stateChanged():void 
		{
			super.stateChanged();
			addChild(_itemLiveBackground);
			addChild(_thumb);
			addChild(_mask);
		}
		
		/*
		 * HANDLERS
		 */
		
		private function __onMouseEvent( event:MouseEvent ): void
		{
			if ( !initialized || (data && data.activeCaster == true) ) return;
			_dragDrop.startDrag( data, _thumb );
		}
		 
		/*
		 * DISPLAY API
		 */
		
		override protected function measure(): void 
		{
			super.measure();
			measuredWidth = ScreenScaler.calculateSize(64);
			measuredHeight = ScreenScaler.calculateSize(36) + paddingTop + paddingBottom;
		}
		
		override protected function createChildren():void 
		{
			super.createChildren();
			_thumb = new VideoThumb();
			_mask = getStyleGraphic("itemBGMask");
			_itemLiveBackground = getStyleGraphic("itemLiveBackground");
			_itemLiveBackground.visible = false;
			mask = _mask;
			
			addChildren(_itemLiveBackground, _thumb, _mask);
		}
		
		override protected function childrenCreated():void 
		{
			super.childrenCreated();
			if ( connected ) _thumb.connect(_netConnection);
			if ( instance ) _thumb.instance = instance;
			if( data ) _thumb.loadThumb(data.thumbName);
		}
		
		override protected function arrange():void 
		{
			super.arrange();
			
			_itemLiveBackground.width = width;
			_itemLiveBackground.height = height; 
			_thumb.setActualSize(width, height);
			
			SizeUtils.moveX( _itemLiveBackground, width, SizeUtils.CENTER );
			SizeUtils.moveY( _itemLiveBackground, height, SizeUtils.MIDDLE );
			
			SizeUtils.moveX( _mask, width, SizeUtils.CENTER );
			SizeUtils.moveY( _mask, height, SizeUtils.MIDDLE );
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		override public function set data(value:Object):void 
		{	
			super.data = value;
			if ( value && initialized ) 
			{
				if( _thumb.thumbPath != value.thumbName ) _thumb.loadThumb(value.thumbName);
				_itemLiveBackground.visible = value.activeCaster == true;
			}
		}
	}
}
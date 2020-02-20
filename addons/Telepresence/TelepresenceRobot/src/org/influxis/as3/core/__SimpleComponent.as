/**
 * SimpleComponent - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.core
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.display.InteractiveObject;
	import flash.text.TextFormat;
	import flash.utils.getQualifiedClassName;
	import org.influxis.as3.skins.StyleGraphic;
	
	//Influxis Classes
	import org.influxis.as3.utils.Debugger;
	import org.influxis.as3.utils.doTimedLater;
	import org.influxis.as3.utils.handler;
	import org.influxis.as3.events.SimpleEventConst;
	import org.influxis.as3.managers.SkinsManager;
	import org.influxis.as3.events.SimpleEvent;
	import org.influxis.as3.skins.SkinElement;
	import org.influxis.as3.core.Display;
	import org.influxis.as3.net.LabelLoader;
	
	//Events
	[Event( name = "resize", type = "flash.events.Event" )]
	
	public class __SimpleComponent extends Sprite 
	{
		//public static var symbolName:String = "SimpleComponent";
		//public static var symbolOwner:Object = org.influxis.as3.core.SimpleComponent;
		//private var _sVersion:String = "1.0.0.0";
		
		private static var COMP_ID_COUNT:uint = 0;
		public static var SKINS_PATH:String = "skins.xml";
		
		private var _sClassTraceName:String;
		private var _sSkinName:String;
		private var _bAllowDebug:Boolean;
		private var _bInitialized:Boolean;
		private var _bParentResize:Boolean;
		private var _bEnabled:Boolean = true;
		private var _visible:Boolean = true;
		
		private var _width:Number;
		private var _height:Number;
		private var _perWidth:Number;
		private var _perHeight:Number;
		
		protected var paddingLeft:int = 0;
		protected var paddingTop:int = 0;
		protected var paddingBottom:int = 0;
		protected var paddingRight:int = 0;
		protected var innerPadding:int = 0;
		protected var outerPadding:int = 0;
		
		/*
		Next api version
		private var _minWidth:Number = 0;
		private var _minHeight:Number = 0;
		private var _maxWidth:Number = 0;
		private var _maxHeight:Number = 0;
		
		private var _paddingLeft:Number = 0;
		private var _paddingRight:Number = 0;
		private var _paddingTop:Number = 0;
		private var _paddingBottom:Number = 0;
		
		private var _align:Number = 0;
		*/
		
		private var _parent:SimpleComponent;
		private var _skinsManager:SkinsManager = SkinsManager.getInstance();
		private var _labels:LabelLoader = LabelLoader.getInstance();
		protected var componentID:uint;
		
		/**
		 * INIT API
		 */
		
		public function SimpleComponent(): void 
		{
			//lets not show comp before its full initialized
			super.visible = false;
			
			//Keep track of comp count
			componentID = COMP_ID_COUNT;
			COMP_ID_COUNT++;
			
			//Call to handle pre-init tasks
			__checkStage();
		}
		
		private function __checkStage(): void
		{
			//trace( "__checkStage: " + Display, stage, root, className );
			if ( stage && root )
			{
				if ( !Display.STAGE ) Display.STAGE = stage;
				if ( !Display.ROOT ) Display.ROOT = root;
				preInitialize();
			}else{
				doTimedLater( 50, __checkStage );
			}
		}
		
		//Initialize component when attached to stage
		private function __initComp(e:Event = null):void 
		{
			//Remove for init
			//removeEventListener(Event.ADDED_TO_STAGE, __initComp);
			
			//Add for resize api
			addEventListener(Event.ADDED_TO_STAGE, __onStageEvent);
			addEventListener(Event.REMOVED_FROM_STAGE, __onStageEvent);
			
			init();
		}
		
		/*
		//After skins loaded then continue initialize
		private function continueInitialize( p_e:Event = null, isSkins:Boolean = false ): void
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, __initComp);
		}*/
		
		/**
		 * PUBLIC API
		 */
		
		public function getStyle( styleName:String, styleItem:String = null ): *
		{
			if ( !_skinsManager.initialized ) return;
			
			var value:*;
			if( _skinsManager.exists(skinName) ) value = _skinsManager.getSkinElement(skinName).getStyle(styleName, styleItem);
			if( value == undefined && skinName != className && _skinsManager.exists(className) ) value = _skinsManager.getSkinElement(className).getStyle(styleName, styleItem);
			return value;
		}
		
		public function setStyle( styleName:String, skin:*, styleItem:String = null ): void
		{
			_skinsManager.getSkinElement(skinName).setStyle(styleName, skin, styleItem);
		}
		
		public function styleExists( styleName:String, styleItem:String = null ): Boolean
		{
			return (getStyle(styleName, styleItem) != undefined);
		}
		
		public function embeddedFontExists( fontName:String ): Boolean
		{
			return _skinsManager.embeddedFontExists(fontName);
		}
		
		/**
		 * PROTECTED API
		 */
		
		//Called to handle pre init tasks (if override then very important to call super class version)
		protected function preInitialize(): void
		{
			__loadAssets();
			/*
			//If skin xml has not been loaded then let's go ahead and load it in
			if ( !_skinsManager.initialized )
			{
				_skinsManager.addEventListener( Event.COMPLETE, handler(continueInitialize, true) );
				_skinsManager.loadSkinSettings( SKINS_PATH );
			}else{
				if (stage) init();
				else addEventListener(Event.ADDED_TO_STAGE, __initComp);
			}*/
		}
		
		private function __loadAssets(): void
		{
			//If skin and label xml has not been loaded then let's go ahead and load it in
			if ( !_skinsManager.initialized || !_labels.loaded )
			{
				if ( !_skinsManager.initialized ) _skinsManager.loadSkinSettings( SKINS_PATH );
				doTimedLater( 30, __loadAssets );
			}else{
				__initComp();
			}
		}
		
		//Initialize
		protected function init(): void
		{
			__registerSubSkin( _sSkinName != null ? _sSkinName : className );
			
			//Sets percent size listeners if set
			__setParentResize();
			
			if ( super.width > 0 && isNaN(_width) ) _width = super.width;
			if ( super.height > 0 && isNaN(_height) ) _height = super.height;
			
			createChildren();
			__setInitialized(true);
		}
		
		protected function setEnabled( enabled:Boolean ): void
		{
			_bEnabled = enabled;
		}
		
		protected function getGraphic( styleName:String ): InteractiveObject
		{
			var grClip:InteractiveObject = _skinsManager.getSkinElement(skinName).getGraphics(styleName);
			if( !grClip && skinName != className ) _skinsManager.getSkinElement(className).getGraphics(styleName);
			return grClip;
		}
		
		protected function getStyleGraphic( styleName:String ): InteractiveObject
		{
			return _skinsManager.getSkinElement(skinName).getStyleGraphic(styleName, className);
		}
		
		protected function getTextFormat( styleName:String ): TextFormat
		{
			var tx:TextFormat = _skinsManager.getSkinElement(skinName).getTextFormat(styleName);
			if ( !tx && skinName != className ) _skinsManager.getSkinElement(className).getTextFormat(styleName);
			if ( !tx ) tx = new TextFormat();
			return tx;
		}
		
		protected function onStyleChanged( style:String = null, styleItem:String = null ): void
		{
			measurePadding();
		}
		
		protected function setDefaultDimentions( width:Number, height:Number ): void
		{
			_width = isNaN(_width) ? width : _width;
			_height = isNaN(_height) ? height : _height;
		}
		
		protected function measure(): void
		{
			measurePadding();
		}
		
		protected function refreshMeasures(): void
		{
			if ( !initialized ) return;
			measure();
			arrange();
		}
		
		protected function measurePadding(): void
		{
			//General padding for when others are missing
			var padding:int = styleExists("padding") ? getStyle("padding") as int : 0;
			
			//Set padding
			paddingLeft = styleExists("paddingLeft") ? getStyle("paddingLeft") as int : padding;
			paddingTop = styleExists("paddingTop") ? getStyle("paddingTop") as int : padding;
			paddingBottom = styleExists("paddingBottom") ? getStyle("paddingBottom") as int : padding;
			paddingRight = styleExists("paddingRight") ? getStyle("paddingRight") as int : padding;
			innerPadding = styleExists("innerPadding") ? getStyle("innerPadding") as int : padding;
			outerPadding = styleExists("outerPadding") ? getStyle("outerPadding") as int : padding;
		}
		
		protected function getLabelAt( id:String ): String
		{
			if ( !id || !_labels ) return null;
			return _labels.getLabelAt(id);
		}
		
		/**
		 * PRIVATE API
		 */
		
		private function __setInitialized( p_bInitialized:Boolean ): void
		{
			if ( _bInitialized == p_bInitialized ) return;
			
			if ( !__checkCreated() )
			{
				doTimedLater( 50, __setInitialized, p_bInitialized );
			}else{
				_bInitialized = p_bInitialized;
				
				childrenCreated();
				measure();
				arrange();
				
				__updateStyleGraphics();
				super.visible = _visible;
				dispatchEvent( new Event(SimpleEventConst.INITIALIZED) );
			}
		}
		
		private function __checkCreated(): Boolean
		{
			if ( numChildren == 0 ) return true;
			
			var simpleChild:SimpleComponent;
			for ( var i:uint = 0; i < numChildren; i++ )
			{
				simpleChild = getChildAt(i) as SimpleComponent;
				if ( simpleChild )
				{
					if ( !simpleChild.initialized ) return false;
				}
			}
			return true;
		}
		
		private function __setParentResize(): void
		{
			if ( !parent ) return;
			
			var bParentResize:Boolean = !isNaN(_perWidth) || !isNaN(_perHeight);
			if ( bParentResize == _bParentResize ) return;
			
			_bParentResize = bParentResize;
			if ( parent is SimpleComponent )
			{
				if ( _bParentResize )
				{
					_parent = (parent as SimpleComponent);
					_parent.addEventListener( Event.RESIZE, __onParentResize );
					__onParentResize(new Event(Event.RESIZE));
				}else{
					_parent.removeEventListener( Event.RESIZE, __onParentResize );
					_parent = null;
				}
			}
		}
		
		private function __registerSubSkin( skinName:String ): void
		{
			if ( skinName == _sSkinName ) return;
			
			var skinElement:SkinElement;
			if ( _sSkinName )
			{
				skinElement = _skinsManager.getSkinElement(_sSkinName);
				if ( skinElement ) skinElement.removeEventListener( SimpleEvent.CHANGED, __onSkinStyleChanged );
				_sSkinName = null;
			}
			
			//trace( "__registerSubSkin: " + skinName, _sSkinName );
			if ( skinName )
			{
				_sSkinName = skinName;
				__checkSkinInstance();
				__updateStyleGraphics();
				skinElement = _skinsManager.getSkinElement(_sSkinName);
				if ( skinElement ) skinElement.addEventListener( SimpleEvent.CHANGED, __onSkinStyleChanged );
			}
		}
		
		private function __checkSkinInstance(): void
		{
			var sSkin:String = skinName != null ? skinName : className;
			if( !_skinsManager.exists(sSkin) ) _skinsManager.setSkinElement( sSkin, SkinElement.getInstance(sSkin), true );
		}
		
		private function __updateStyleGraphics(): void
		{
			if ( !initialized ) return;
			
			var nLen:int = numChildren;
			for ( var i:int = 0; i < nLen; i++ )
			{
				var child:StyleGraphic = getChildAt(i) as StyleGraphic;
				if ( child ) child.changeSkinElement( _skinsManager.getSkinElement(_sSkinName) );
			}
		}
		
		/**
		 * HANDLERS
		 */
		
		private function __onSkinStyleChanged( p_e:SimpleEvent ): void
		{
			if ( p_e.data )
			{
				onStyleChanged( p_e.data.styleName, p_e.data.styleItem );
			}else{
				onStyleChanged();
			}
		}
		
		private function __onStageEvent( p_e:Event ): void
		{
			if ( _bParentResize )
			{
				if ( p_e.type == Event.ADDED_TO_STAGE && parent is SimpleComponent )
				{
					_parent = (parent as SimpleComponent);
					_parent.addEventListener( Event.RESIZE, __onParentResize );
					__onParentResize(new Event(Event.RESIZE));
				}else if ( _parent )
				{
					_parent.removeEventListener( Event.RESIZE, __onParentResize );
					_parent = null;
				}
			}
		}
		 
		private function __onParentResize( p_e:Event ): void
		{
			if ( !_parent ) return;
			
			//set new sizes
			_width = !isNaN(_perWidth) ? (_parent.width * (_perWidth/100)) : width;
			_height = !isNaN(_perHeight) ? (_parent.height * (_perHeight / 100)) : height;
			
			//Only launch resize if initialized
			if ( initialized )
			{
				arrange();
				dispatchEvent(new Event(Event.RESIZE));
			}
		}
		 
		/**
		 * DISPLAY API
		**/
		
		public function addChilren( ...children ): void
		{
			var aChildren:Array = children as Array;
			for each( var o:DisplayObject in aChildren )
			{
				addChild( o );
			}
		}
		
		public function removeAllChildren(): void
		{
			for ( var i:uint = 0; i < numChildren; i++ )
			{
				removeChildAt(i);
			}
		}
		
		protected function createChildren(): void
		{
			if ( initialized ) return;
			
		}
		
		protected function childrenCreated(): void
		{
			
		}
		
		public function setActualSize( w:Number, h:Number ): void
		{
			_width = w;
			_height = h;
			if ( initialized ) arrange();
			dispatchEvent(new Event(Event.RESIZE));
		}
		
		protected function arrange(): void
		{
			
		}
		
		/**
		 * GETTER / SETTER
		**/
		
		public function get className(): String
		{
			return getQualifiedClassName(this).replace("::", ".");
		}
		
		public function set skinName( skinName:String ): void
		{
			if ( _sSkinName == skinName ) return;
			__registerSubSkin( skinName == null ? className : skinName );
		}
		
		public function get skinName(): String
		{
			return _sSkinName;
		}
		
		override public function set width( value:Number ): void
		{
			if ( _width == value ) return;
			_width = value;
			if( initialized ) arrange();
			dispatchEvent(new Event(Event.RESIZE));
		}
		
		override public function get width(): Number
		{
			return (isNaN(_width)?_nMeasuredWidth:_width);
		}
		
		override public function set height( value:Number ): void
		{
			if ( _height == value ) return;
			_height = value;
			
			if( initialized ) arrange();
			dispatchEvent(new Event(Event.RESIZE));
		}
		
		override public function get height(): Number
		{
			return (isNaN(_height)?_nMeasuredHeight:_height);
		}
		
		private var _nMeasuredWidth:Number = 0;
		public function set measuredWidth( value:Number ): void
		{
			if ( _nMeasuredWidth == value ) return;
			_nMeasuredWidth = value;
		}
		
		public function get measuredWidth(): Number
		{
			return _nMeasuredWidth;
		}
		
		private var _nMeasuredHeight:Number = 0;
		public function set measuredHeight( value:Number ): void
		{
			if ( _nMeasuredHeight == value ) return;
			_nMeasuredHeight = value;
		}
		
		public function get measuredHeight(): Number
		{
			return _nMeasuredHeight;
		}
		
		override public function set visible( value:Boolean ): void 
		{ 
			_visible = value;
			if ( initialized ) super.visible = value;
		}
		
		override public function get visible():Boolean 
		{ 
			return _visible;
		}
		
		public function set percentWidth( value:Number ): void
		{
			if ( _perWidth == value ) return;
			_perWidth = value;
			__setParentResize();
		}
		
		public function get percentWidth(): Number
		{
			return _perWidth;
		}
		
		public function set percentHeight( value:Number ): void
		{
			if ( _perHeight == value ) return;
			_perHeight = value;
			__setParentResize();
		}
		
		public function set enabled( enabled:Boolean ): void
		{
			setEnabled(enabled);
		}
		
		public function get enabled(): Boolean
		{
			return _bEnabled;
		}
		
		public function get percentHeight(): Number
		{
			return _perHeight;
		}
		
		public function get initialized(): Boolean
		{
			return _bInitialized;
		}
		
		/**
		* DEBUGGER
		**/
		
		public function setDebug( p_bAllow:Boolean, p_sClassName:String = null ): void
		{
			if ( _sClassTraceName ) return;
			
			_sClassTraceName = p_sClassName == null ? className : p_sClassName;
			_bAllowDebug = p_bAllow;
			Debugger.setDebugger( _sClassTraceName, _bAllowDebug );
		}
		
		protected function tracer( p_msg:* ) : void
		{
			Debugger.tracer( _sClassTraceName, p_msg );
		}
	}
	
}
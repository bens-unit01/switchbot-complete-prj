package org.influxis.social.display.shareoptionsclasses 
{
	//Flash Classes
	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import flash.net.NetConnection;
	import flash.events.Event;
	import flash.sampler.NewObjectSample;
	import flash.utils.setTimeout;
	import flash.geom.Rectangle;
	
	//Influxis Classes
	import org.influxis.flotools.core.InfluxisComponent;
	import org.influxis.as3.events.SimpleEvent;
	import org.influxis.as3.events.DataEvent;
	import org.influxis.as3.states.SizeStates;
	import org.influxis.as3.core.Display;
	import org.influxis.as3.utils.SizeUtils;
	import org.influxis.as3.utils.ScreenScaler;
	import org.influxis.as3.display.Alert;
	import org.influxis.as3.interfaces.display.IAlert;
	import org.influxis.as3.display.Button;
	import org.influxis.as3.utils.ScreenScaler;
	
	//Social Classses
	import org.influxis.social.events.SocialAPIEvent;
	import org.influxis.social.InfluxisSocialAPI;
	import org.influxis.social.managers.SocialCasterManager;
	import org.influxis.social.display.shareoptionsclasses.PlayerLinkAlert;
	
	public class ShareOptionsBase extends InfluxisComponent
	{
		public static const REQUEST_SENT:String = "requestSent";
		
		protected var defaultEncodedLink:String;
		private var _defaultPostMessage:String;
		private var _defaultPostLink:String;
		private var _social:SocialCasterManager;
		private var _bPendingMessage:Boolean;
		private var _twitterToken:String;
		private var _facebookToken:String;
		private var _facebook:InfluxisSocialAPI;
		private var _twitter:InfluxisSocialAPI;
		
		private var _iconFB:InteractiveObject;
		private var _iconTW:InteractiveObject;
		private var _iconLink:InteractiveObject;
		private var _divider1:DisplayObject;
		private var _divider2:DisplayObject;
		
		/*
		 * INIT API
		 */
		
		public function ShareOptionsBase(): void
		{
			_social = SocialCasterManager.getInstance(Display.APPLICATION as DisplayObjectContainer);
			
			//Check if there is an existing service
			if ( _social.facebook ) onFacebookChanged();
			if ( _social.twitter ) onTwitterChanged();
			
			//Add listeners to receive events
			_social.addEventListener( SocialCasterManager.TOKEN_CHANGE, __onTokenChanged );
			_social.addEventListener( SocialAPIEvent.AUTHORIZATION_SUCCESS, __onSocialEvent );
			_social.addEventListener( SocialAPIEvent.AUTHORIZATION_ERROR, __onSocialEvent );
			_social.addEventListener( SocialAPIEvent.AUTHORIZATION_DENIED, __onSocialEvent );
			_social.addEventListener( SocialAPIEvent.POST_RESPONSE_SUCCESS, __onSocialEvent );
			_social.addEventListener( SocialAPIEvent.POST_RESPONSE_FAILED, __onSocialEvent );
			super();
		}
		
		/*
		 * PUBLIC API
		 */
		
		public function checkDefaultShareAlert(): Boolean
		{
			if ( !facebookToken && !twitterToken )
			{
				launchLinkPanel();
				return true;
			}
			return false;
		}
		 
		/*
		 * PROTECTED API
		 */
		
		protected function refreshDisplayView(): void
		{
			_divider1.visible = _iconFB.visible = _facebookToken != null;
			_divider2.visible = _iconTW.visible = _twitterToken != null;
			refreshMeasures();
		}
		
		protected function onFacebookChanged(): void
		{
			if ( _facebook )
			{
				_facebook.removeEventListener( SocialAPIEvent.PAGE_INIT, __onSocialEvent );
				_facebook.removeEventListener( SocialAPIEvent.PAGE_LOADED, __onSocialEvent );
				_facebook.removeEventListener( SocialAPIEvent.PAGE_ERROR, __onSocialEvent );
				_facebook = null;
			}
			
			if ( _social && _social.facebook )
			{
				_facebook = _social.facebook;
				_facebook.addEventListener( SocialAPIEvent.PAGE_INIT, __onSocialEvent );
				_facebook.addEventListener( SocialAPIEvent.PAGE_LOADED, __onSocialEvent );
				_facebook.addEventListener( SocialAPIEvent.PAGE_ERROR, __onSocialEvent );
			}
		}
		
		protected function onTwitterChanged(): void
		{
			if ( _twitter )
			{
				_twitter.removeEventListener( SocialAPIEvent.PAGE_INIT, __onSocialEvent );
				_twitter.removeEventListener( SocialAPIEvent.PAGE_LOADED, __onSocialEvent );
				_twitter.removeEventListener( SocialAPIEvent.PAGE_ERROR, __onSocialEvent );
				_twitter = null;
			}
			
			if ( _social && _social.twitter )
			{
				_twitter = _social.twitter;
				_twitter.addEventListener( SocialAPIEvent.PAGE_INIT, __onSocialEvent );
				_twitter.addEventListener( SocialAPIEvent.PAGE_LOADED, __onSocialEvent );
				_twitter.addEventListener( SocialAPIEvent.PAGE_ERROR, __onSocialEvent );	
			}
		}
		
		protected function launchLinkPanel(): void
		{
			var linkContainer:DisplayObject = new PlayerLinkAlert();
				PlayerLinkAlert(linkContainer).playerLink = !defaultEncodedLink ? defaultPostLink : defaultEncodedLink;
				
			Alert.launchAlertPanel( (linkContainer as IAlert), getLabelAt("linksAlertTitle"), styleExists("alertLinkIcon") ? getStyleGraphic("alertLinkIcon") : null, null, true);
		}
		
		protected function launchRequestSent(): void
		{
			Alert.alert( getLabelAt("requestSentAlert"), getLabelAt("requestSentAlertTitle"), getLabelAt("okBtn") );
		}
		
		protected function get socialPostLink(): String
		{
			return !defaultEncodedLink ? defaultPostLink : defaultEncodedLink;
		}
		
		/*
		 * HANDLERS
		 */
		
		private function __onIconEvent( event:MouseEvent ): void
		{
			switch( event.currentTarget )
			{
				case _iconFB : 
					if ( _facebook )
					{
						if ( _facebook.loggedIn )
						{
							_facebook.postMessage( {message:defaultPostMessage, link:socialPostLink} );
						}else {
							_bPendingMessage = true;
							_facebook.login();
						}
					}
					break;
				case _iconTW : 
					if ( _twitter )
					{
						if ( _twitter.loggedIn )
						{
							_twitter.postMessage( {message:(!defaultPostMessage ? "" : defaultPostMessage + "\n\n") + socialPostLink} );
						}else {
							_bPendingMessage = true;
							_twitter.login();
						}
					}
					break;
				case _iconLink : 
					launchLinkPanel();
					break;
			}
			visible = false;
			if ( !_bPendingMessage && event.currentTarget != _iconLink ) 
			{
				launchRequestSent();
				dispatchEvent( new Event(REQUEST_SENT) );
			}
		}
		
		private function __onSocialEvent( event:SocialAPIEvent ): void
		{
			if ( event.type == SocialAPIEvent.AUTHORIZATION_SUCCESS ||
				 event.type == SocialAPIEvent.AUTHORIZATION_ERROR ||
				 event.type == SocialAPIEvent.AUTHORIZATION_DENIED )
			{
				if ( _bPendingMessage )
				{
					_bPendingMessage = false;
					if ( event.type == SocialAPIEvent.AUTHORIZATION_SUCCESS )
					{
						if ( event.service == SocialCasterManager.FACEBOOK )
						{
							_facebook.postMessage( {message:defaultPostMessage, link:socialPostLink} );
						}else{
							_twitter.postMessage( {message:(!defaultPostMessage ? "" : defaultPostMessage + "\n\n") + socialPostLink} );
						}
						launchRequestSent();
						dispatchEvent( new Event(REQUEST_SENT) );
					}
				}
			}else if ( event.type == SocialAPIEvent.PAGE_LOADED || 
					   event.type == SocialAPIEvent.PAGE_ERROR || 
					   event.type == SocialAPIEvent.PAGE_INIT )
			{
				if ( event.type == SocialAPIEvent.PAGE_INIT )
				{
					
				}else if ( event.type == SocialAPIEvent.PAGE_LOADED )
				{
					
				}
			}
		}
		
		private function __onTokenChanged( event:DataEvent ): void
		{
			if ( event.data == SocialCasterManager.FACEBOOK )
			{
				onFacebookChanged();
			}else{
				onTwitterChanged();
			}
		}
		
		/*
		 * DISPLAY API
		 */
		
		override protected function measure(): void 
		{
			super.measure();
			
			var newMeasuredWidth:Number = paddingLeft + paddingRight + _iconLink.width;
			if ( _iconFB.visible ) newMeasuredWidth += _iconFB.width + _divider1.width + (innerPadding * 2);
			if ( _iconTW.visible ) newMeasuredWidth += _iconTW.width + _divider2.width + (innerPadding * 2);
			
			measuredWidth = newMeasuredWidth;
			measuredHeight = paddingBottom + paddingTop + _iconLink.height;
		}
		
		override protected function createChildren(): void 
		{
			super.createChildren();
			_iconLink = getStyleGraphic("linkIcon");
			_iconFB = getStyleGraphic("facebookIcon");
			_iconTW = getStyleGraphic("twitterIcon");
			_divider1 = getStyleGraphic("lineDivider");
			_divider2 = getStyleGraphic("lineDivider");
			
			//Check to see if tokens are around for use
			_divider1.visible = _iconFB.visible = _facebookToken != null;
			_divider2.visible = _iconTW.visible = _twitterToken != null;
			
			addChildren( _iconFB, _iconTW, _iconLink, _divider1, _divider2 );
		}
		
		override protected function childrenCreated(): void 
		{
			super.childrenCreated();
			_iconFB.addEventListener( MouseEvent.MOUSE_DOWN, __onIconEvent );
			_iconTW.addEventListener( MouseEvent.MOUSE_DOWN, __onIconEvent );
			_iconLink.addEventListener( MouseEvent.MOUSE_DOWN, __onIconEvent );
		}
		
		override protected function arrange(): void 
		{
			super.arrange();
			
			_iconLink.x = paddingLeft;
			if ( _iconFB.visible || _iconTW.visible )
			{
				var alignComps:Vector.<DisplayObject> = new Vector.<DisplayObject>();
				if ( _iconFB.visible ) alignComps.push( _divider1, _iconFB );
				if ( _iconTW.visible ) alignComps.push( _divider2, _iconTW );
				
				var nLen:Number = alignComps.length;
				for ( var i:Number = 0; i < nLen; i++ )
				{
					SizeUtils.hookTarget( alignComps[i], (i == 0 ? _iconLink : alignComps[i-1]), SizeUtils.RIGHT, innerPadding );
				}
			}
			
			SizeUtils.moveY( _iconLink, height, SizeUtils.MIDDLE );
			SizeUtils.moveY( _iconFB, height, SizeUtils.MIDDLE ); SizeUtils.moveY( _divider1, height, SizeUtils.MIDDLE );
			SizeUtils.moveY( _iconTW, height, SizeUtils.MIDDLE ); SizeUtils.moveY( _divider2, height, SizeUtils.MIDDLE );
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		public function set defaultPostMessage( value:String ): void
		{
			if ( _defaultPostMessage == value ) return;
			_defaultPostMessage = value;
		}
		
		public function get defaultPostMessage(): String
		{
			return _defaultPostMessage;
		}
		
		public function set defaultPostLink( value:String ): void
		{
			if ( _defaultPostLink == value ) return;
			_defaultPostLink = value;
		}
		
		public function get defaultPostLink(): String
		{
			return _defaultPostLink;
		}
		
		public function set twitterToken( value:String ): void
		{
			if ( _twitterToken == value ) return;
			_twitterToken = value;
			_social.twitterToken = _twitterToken;
			refreshDisplayView();
		}
		
		public function get twitterToken(): String
		{
			return _twitterToken;
		}
		
		public function set facebookToken( value:String ): void
		{
			if ( _facebookToken == value ) return;
			_facebookToken = value;
			_social.facebookToken = _facebookToken;
			refreshDisplayView();
		}
		
		public function get facebookToken(): String
		{
			return _facebookToken;
		}
	}
}
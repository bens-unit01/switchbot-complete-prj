package org.influxis.as3.net 
{
	//Flash Classes
	import flash.utils.getDefinitionByName;
	
	//Influxis Classes
	import org.influxis.as3.net.loaderclasses.LoaderBase;
	
	public class LabelLoader extends LoaderBase
	{
		private static var _lad:LabelLoader;
		public static var FILE:String = "labels.xml";
		public static const ASSET_XML:String = "localAssetXML";
		
		public function LabelLoader() 
		{
			if ( FILE == ASSET_XML )
			{
				try {
					loadManualXML( getDefinitionByName("assets.Skins").LABELS_XML as XML );
				}catch ( e:Error )
				{
					//Does not exist :/
				}
			}else{
				loadTargetFile(FILE);
			}
		}
		
		/**
		 * SINGLETON API
		 */
		
		public static function getInstance(): LabelLoader
		{
			if ( !_lad ) _lad = new LabelLoader();
			return _lad;
		}
		
		public static function destroy(): void
		{
			if ( _lad ) _lad = null;
		}
		
		/**
		 * PUBLIC API
		 */
		
		public function getLabelAt( id:String ): String
		{
			if ( !dataProvider ) return null;
			var label:String = dataProvider.label.( @id == id ).toString();
			return label;
		}
	}
}
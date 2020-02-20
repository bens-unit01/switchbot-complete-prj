package org.influxis.as3.utils 
{
	//Flash Classes
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	public class FileUtils 
	{	
		/*
		 * PUBLIC API
		 */
		
		public static function saveToLocalDisk( bytes:ByteArray, target_url:String ): void
        {
            //crates the new file class from string that contains target url...
            var file:File = File.applicationStorageDirectory.resolvePath(target_url);
            var fs:FileStream = new FileStream();
				fs.open(file,FileMode.WRITE);
				fs.writeBytes(bytes, 0, bytes.length);
				fs.close();
        }
       
        public static function loadFromLocalDisk( target_url:String ): ByteArray
        {
            var results:ByteArray = new ByteArray();
            var file:File = File.applicationStorageDirectory.resolvePath(target_url);
            var fs:FileStream = new FileStream();
			if ( file.exists )
			{
				fs.open(file, FileMode.READ);
				fs.position = 0;
				fs.readBytes( results, 0, fs.bytesAvailable);
				fs.close();
			}
            return results;
        }
		
		public static function deleteFromDisk( target_url:String ): void
		{
			var file:File = File.applicationStorageDirectory.resolvePath(target_url);
				file.deleteFile();
		}
		
		public static function exists( target_url:String ): Boolean
		{
			return File.applicationStorageDirectory.resolvePath(target_url).exists;
		}
	}

}
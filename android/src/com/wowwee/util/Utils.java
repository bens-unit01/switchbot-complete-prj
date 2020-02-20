package com.wowwee.util;

/**
 *This class contains some utility methods  
 *
 * */
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.net.InetAddress;
import java.net.InterfaceAddress;
import java.net.NetworkInterface;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Enumeration;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.http.conn.util.InetAddressUtils;

import android.app.ActivityManager;
import android.content.Context;
import android.text.format.Formatter;
import android.util.Log;

public class Utils {

	// ------- constructors

	public Utils() {
		super();

	}
	
	public void saveData(String fileName, String mJsonResponse) {
	    try {
	     //   FileWriter file = new FileWriter("/data/data/" + getApplicationContext().getPackageName() + "/" + params);
	        FileWriter file = new FileWriter(fileName);
	        file.write(mJsonResponse);
	        file.flush();
	        file.close();
	    } catch (IOException e) {
	        e.printStackTrace();
	    }
	}	
	public String readData(String fileName) {
	    try {
	     //   File f = new File("/data/data/" + getPackageName() + "/" + params);
	        File f = new File(fileName);
	        FileInputStream is = new FileInputStream(f);
	        int size = is.available();
	        byte[] buffer = new byte[size];
	        is.read(buffer);
	        is.close();
	        String mResponse = new String(buffer);
	        return mResponse;    
	    } catch (IOException e) {
	        // TODO Auto-generated catch block
	        e.printStackTrace();
	        return null;
	    }
	}

	final protected static char[] hexArray = "0123456789ABCDEF".toCharArray();

	/**
	 * returns a string representing an array of bytes on hexadecimal format
	 *
	 * @param bytes
	 *            : input bytes array
	 */
	public static String bytesToHex(byte[] bytes) {
		char[] hexChars = new char[bytes.length * 2];
		for (int j = 0; j < bytes.length; j++) {
			int v = bytes[j] & 0xFF;
			hexChars[j * 2] = hexArray[v >>> 4];
			hexChars[j * 2 + 1] = hexArray[v & 0x0F];
		}
		return new String(hexChars);
	}

	/**
	 * same as previous method, bytesToHex but with more
	 * flexibility for the output shape
	 */
	public static String bytesToHex2(byte[] a) {
		StringBuilder sb = new StringBuilder(a.length * 4);
		for (byte b : a) {
			sb.append(String.format("%02x", b & 0xff));
			sb.append("-");
		}
		return sb.toString();
	}

	/**
	 * used to extract a youtube video ID from a url
	 * 
	 * @param youtubeUrl
	 *            : input url
	 */
	public String getYoutubeVideoId(String youtubeUrl) {
		String video_id = "";
		Log.d("A3", "MipVideoPlayer#getYoutubeVideoId url: " + youtubeUrl);
		if (youtubeUrl != null && youtubeUrl.trim().length() > 0
				&& youtubeUrl.startsWith("http")) {

			String expression = "^.*((youtu.be"
					+ "\\/)"
					+ "|(v\\/)|(\\/u\\/w\\/)|(embed\\/)|(watch\\?))\\??v?=?([^#\\&\\?]*).*"; // var
																								// regExp
																								// =
																								// /^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#\&\?]*).*/;
			CharSequence input = youtubeUrl;
			Pattern pattern = Pattern.compile(expression,
					Pattern.CASE_INSENSITIVE);
			Matcher matcher = pattern.matcher(input);
			if (matcher.matches()) {
				String groupIndex1 = matcher.group(7);
				if (groupIndex1 != null && groupIndex1.length() == 11)
					video_id = groupIndex1;
			}
		}
		Log.d("A3", "MipVideoPlayer#getYoutubeVideoId video_id: " + video_id);
		return video_id;
	}

	/**
	 * force to close an activity
	 * 
	 * @param packageName
	 *            : activity full name
	 * @param context
	 *            : the calling activity context
	 */
	public void closeApp(String packageName, Context context) {

		ActivityManager am = (ActivityManager) context
				.getSystemService(Context.ACTIVITY_SERVICE);
		List<ActivityManager.RunningAppProcessInfo> pids = am
				.getRunningAppProcesses();
		int processid = 0;
		int uid = 0;
		int myUid = android.os.Process.myUid();
		for (int i = 0; i < pids.size(); i++) {
			ActivityManager.RunningAppProcessInfo info = pids.get(i);
			// "air.air.MipVideoPlayer"
			if (info.processName.equalsIgnoreCase(packageName)) {
				processid = info.pid;
				uid = info.uid;
			}
		}

		List<String> cmdList = new ArrayList<String>();
		cmdList.add("kill -9 " + processid);
		try {
			doCmds(cmdList);
			Log.d("A3", "kill process end ...");
		} catch (Exception e1) {

			e1.printStackTrace();
		}

	}

	/**
	 * runs a shell command or a sequence of shell commands
	 * 
	 * @param cmds
	 *            : list of the shell commands
	 * @throws Exception
	 */
	private static void doCmds(List<String> cmds) throws Exception {
		Process process = Runtime.getRuntime().exec("su");
		DataOutputStream os = new DataOutputStream(process.getOutputStream());

		for (String tmpCmd : cmds) {
			os.writeBytes(tmpCmd + "\n");
		}

		os.writeBytes("exit\n");
		os.flush();
		os.close();

		process.waitFor();
	}

	/**
	 * 
	 * @return : ip address on the wireless network
	 */
	public static String getIPAddress() {
		try {
			for (Enumeration<NetworkInterface> en = NetworkInterface
					.getNetworkInterfaces(); en.hasMoreElements();) {
				NetworkInterface intf = en.nextElement();

				if (intf.getName().equals("wlan0")) {
					InterfaceAddress addr = intf.getInterfaceAddresses().get(1);
					return addr.getAddress().getHostAddress();
				}

			}
		} catch (Exception ex) {
			Log.d(Utils.class.getName(), "bloc catch ex: " + ex.getMessage());
		}
		return "";
	}

	/**
	 * same as the previous method but it supports IPv6 and IPv4
	 * 
	 * @param useIPv4
	 *            : true if we want IPv4 format
	 * @return ip address on the wireless network
	 */
	public static String getIPAddress(boolean useIPv4) {
		try {
			List<NetworkInterface> interfaces = Collections
					.list(NetworkInterface.getNetworkInterfaces());
			for (NetworkInterface intf : interfaces) {
				List<InetAddress> addrs = Collections.list(intf
						.getInetAddresses());
				for (InetAddress addr : addrs) {
					if (!addr.isLoopbackAddress()) {
						String sAddr = addr.getHostAddress().toUpperCase();
						boolean isIPv4 = InetAddressUtils.isIPv4Address(sAddr);
						if (useIPv4) {
							if (isIPv4)
								return sAddr;
						} else {
							if (!isIPv4) {
								int delim = sAddr.indexOf('%'); // drop ip6 port
																// suffix
								return delim < 0 ? sAddr : sAddr.substring(0,
										delim);
							}
						}
					}
				}
			}
		} catch (Exception ex) {
		} // for now eat exceptions
		return "";
	}

    /**
     * 
     * @return true if wifi is connected, false is not 
     */
	public static boolean isWifiConnected() {
		return !getIPAddress(true).equals("");
	}
}

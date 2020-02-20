package com.wowwee.util;
/**
 * This class contains methods to activate/deactivate 
 * ADB through wifi 
 * source : https://github.com/only-for-me/WifiAdb
 */
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.OutputStream;

public class AdbUtils {

	protected static int execRootCmdSilent(String paramString)
			throws IOException, InterruptedException {
		Process localProcess = Runtime.getRuntime().exec("su");
		DataOutputStream localDataOutputStream = new DataOutputStream(
				(OutputStream) localProcess.getOutputStream());
		localDataOutputStream
				.writeBytes((String) (String.valueOf(paramString) + "\n"));
		localDataOutputStream.flush();
		localDataOutputStream.writeBytes("exit\n");
		localDataOutputStream.flush();
		localProcess.waitFor();
		return localProcess.exitValue();
	}

	protected static boolean haveRoot() throws IOException,
			InterruptedException {
		int i = execRootCmdSilent("echo test");
		System.out.println("i->" + i);
		if (i == 0)
			return false;
		return true;
	}

	protected static int reset() throws IOException, InterruptedException {
		Process localProcess = Runtime.getRuntime().exec("su");
		DataOutputStream localDataOutputStream = new DataOutputStream(
				(OutputStream) localProcess.getOutputStream());
		localDataOutputStream.writeBytes("setprop service.adb.tcp.port -1\n");
		localDataOutputStream.flush();
		localDataOutputStream.writeBytes("stop adbd\n");
		localDataOutputStream.flush();
		localDataOutputStream.writeBytes("start adbd\n");
		localDataOutputStream.flush();
		localDataOutputStream.writeBytes("exit\n");
		localDataOutputStream.flush();
		localProcess.waitFor();
		return localProcess.exitValue();
	}

	public static int set(int paramInt) throws IOException,
			InterruptedException {
		Process localProcess = Runtime.getRuntime().exec("su");
		DataOutputStream localDataOutputStream = new DataOutputStream(
				(OutputStream) localProcess.getOutputStream());
		localDataOutputStream.writeBytes("setprop service.adb.tcp.port "
				+ paramInt + "\n");
		localDataOutputStream.flush();
		localDataOutputStream.writeBytes("stop adbd\n");
		localDataOutputStream.flush();
		localDataOutputStream.writeBytes("start adbd\n");
		localDataOutputStream.flush();
		localDataOutputStream.writeBytes("exit\n");
		localDataOutputStream.flush();
		localProcess.waitFor();
		return localProcess.exitValue();
	}
}
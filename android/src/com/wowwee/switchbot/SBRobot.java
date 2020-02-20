package com.wowwee.switchbot;

import java.util.ArrayList;

import com.wowwee.drivepath.DPNode;
import com.wowwee.drivepath.SBCommHandler;

import android.content.Context;

public interface SBRobot {

	public void addRobotListener(RobotListener robotListener);
	public void removeListeners();
	public void write(byte[] data);
	public void writeRaw(byte[] data);
	public void disconnect(DeviceType deviceType);
	public boolean isDeviceConnected(Context context, DeviceType deviceType);
	public boolean isAllUsbConnected(Context context);
	public ArrayList<DPNode> getBeaconsLabels();
	public void driveTo(int beaconId);
	public void setCommHandler(SBCommHandler mCommHandler); 


	public enum DeviceType {
		NUTINY, XYZ_SENSOR
	}
	public interface RobotListener {

		public void onNotify(RobotEvent e);

	}

	public class RobotEvent {
		private Object sender;
		private byte[] data;

		public Object getSender() {
			return sender;
		}

		public byte[] getData() {
			return data;
		}

		public RobotEvent() {
			super();
		}

		public RobotEvent(Object sender, byte[] data) {
			super();

			this.sender = sender;
			this.data = data;
		}

	}

}

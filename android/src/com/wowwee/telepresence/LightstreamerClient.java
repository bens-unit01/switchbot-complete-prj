/*
 * Copyright 2013 Weswit Srl
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.wowwee.telepresence;

import android.util.Log;

import com.lightstreamer.ls_client.ConnectionInfo;
import com.lightstreamer.ls_client.ExtendedTableInfo;
import com.lightstreamer.ls_client.LSClient;
import com.lightstreamer.ls_client.PushConnException;
import com.lightstreamer.ls_client.PushServerException;
import com.lightstreamer.ls_client.PushUserException;
import com.lightstreamer.ls_client.SimpleTableInfo;
import com.lightstreamer.ls_client.SubscrException;

/**
 * This class wraps the real Lightstreamer Client object,
 * exposing start/stop methods for general consumption.
 * This class can be accessed concurrently.
 */
public class LightstreamerClient {

	public static final String TAG1 = "A1", TAG2 = "A2", TAG5 = "A5";
	public static final String LS_DATA_ADAPTER ="TELEPRESENCE02";
	public static final String LS_ADAPTER_SET = "TP02";
	public static final String LS_SERVER_URL ="http://ec2-107-22-46-148.compute-1.amazonaws.com:8080/";
	public static final String LS_USER = Constants.LS_USER;
    private final String[] items;
    private final String[] fields;
    private final LSClient client;

    public LightstreamerClient(String[] items, String[] fields) {
        this.items = items;
        this.fields = fields;
        this.client = new LSClient();
    }

    public void stop() {
        this.client.closeConnection();
    }

    public void start(int phase, String pushServerUrl, LightstreamerListener listener)
            throws PushConnException, PushServerException, PushUserException {
        LsConnectionListener ls = new LsConnectionListener(listener, phase);
        ConnectionInfo connInfo = new ConnectionInfo();
        connInfo.pushServerUrl = pushServerUrl;
        connInfo.adapter = LS_ADAPTER_SET;
        connInfo.user = LS_USER;
        client.openConnection(connInfo, ls);
        Log.d(TAG5, "LightstreamerClient start()");
    }
    
    public void subscribe(int phase, LightstreamerListener listener)
            throws SubscrException, PushServerException, PushUserException, PushConnException {
        LsHandyTableListener hl = new LsHandyTableListener(phase, listener);
        SimpleTableInfo tableInfo = new ExtendedTableInfo(
                items, "DISTINCT", fields, true);
        tableInfo.setDataAdapter(LS_DATA_ADAPTER);
        client.subscribeTable(tableInfo, hl, false);
    }

}



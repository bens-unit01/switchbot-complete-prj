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

import com.lightstreamer.ls_client.HandyTableListener;
import com.lightstreamer.ls_client.UpdateInfo;

/**
 * This is the object that shall be passed to Lightstreamer
 * Client, receiving item-specific events.
 * onUpdate and onRawUpdatesLost events are routed to our
 * higher level LightstreamerListener object.
 */
class LsHandyTableListener implements HandyTableListener {

	public static final String TAG1 = "A1", TAG2 = "A2", TAG5 = "A5";
    private LightstreamerListener listener;
    private int phase;
    
    public LsHandyTableListener(int phase, LightstreamerListener listener) {
        this.listener = listener;
        this.phase = phase;
    }
    
    @Override
    public void onUpdate(int itemPos, String itemName, UpdateInfo update) {
        listener.onItemUpdate(phase, itemPos, itemName, update);
    	Log.d(TAG5, "StocklistHandyTableListener onUpdate ");
    }

    @Override
    public void onRawUpdatesLost(int itemPos, String itemName,
            int lostUpdates) {
        listener.onLostUpdate(phase, itemPos, itemName, lostUpdates);
    	Log.d(TAG5, "StocklistHandyTableListener onRawUpdatesLost ");
    }

    @Override
    public void onSnapshotEnd(int itemPos, String itemName) {
    }

    @Override
    public void onUnsubscr(int itemPos, String itemName) {
    }

    @Override
    public void onUnsubscrAll() {
    }
    
}

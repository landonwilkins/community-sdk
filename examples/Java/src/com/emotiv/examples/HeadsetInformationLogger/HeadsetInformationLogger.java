/****************************************************************************
**
** Copyright 2015 by Emotiv. All rights reserved
** Example - Headset Information Logger
** This example allows getting headset infor: contactquality, wireless strength
** battery level.  
** This example work on single connection.
****************************************************************************/

package com.emotiv.examples.HeadsetInformationLogger;

import com.emotiv.Iedk.*;
import com.emotiv.Iedk.EmoState.IEE_InputChannels_t;
import com.sun.jna.Pointer;
import com.sun.jna.ptr.*;
import com.sun.xml.internal.ws.api.streaming.XMLStreamReaderFactory.Default;

/** Simple example of JNA interface mapping and usage. */
public class HeadsetInformationLogger {
	public static void main(String[] args) {
		Pointer eEvent = Edk.INSTANCE.IEE_EmoEngineEventCreate();
		Pointer eState = Edk.INSTANCE.IEE_EmoStateCreate();
		IntByReference userID = null;
		int state = 0;
		boolean onStateChanged = false;
		boolean readytocollect = false;
		IntByReference batteryLevel = new IntByReference(0);
		IntByReference maxBatteryLevel = new IntByReference(0);

		userID = new IntByReference(0);

		if (Edk.INSTANCE.IEE_EngineConnect("Emotiv Systems-5") != 
				EdkErrorCode.EDK_OK.ToInt()) {
			System.out.println("Emotiv Engine start up failed.");
			return;
		}

		System.out.println("Time, Wireless Strength, Battery Level, AF3, "
							+ "T7, Pz, T8, AF4");
		
		while (true) {
			state = Edk.INSTANCE.IEE_EngineGetNextEvent(eEvent);
	
			// New event needs to be handled
			if (state == EdkErrorCode.EDK_OK.ToInt()) {

				int eventType = Edk.INSTANCE.IEE_EmoEngineEventGetType(eEvent);
				Edk.INSTANCE.IEE_EmoEngineEventGetUserId(eEvent, userID);
				
				switch(eventType)
				{
					case 0x0010:
						System.out.println("User added");
						readytocollect = true;
						break;
					case 0x0020:
						System.out.println("User removed");
						readytocollect = false; 		//just single connection
						break;
					case 0x0040:
						onStateChanged = true;
						Edk.INSTANCE.IEE_EmoEngineEventGetEmoState(eEvent, eState);
						break;
					default:
						break;
				}
				
				if (readytocollect && onStateChanged)
				{
					float timestamp = EmoState.INSTANCE.IS_GetTimeFromStart(eState);
					System.out.print(timestamp + ", ");
					
					System.out.print(EmoState.INSTANCE.IS_GetWirelessSignalStatus(eState)
										+ ", ");
					
					EmoState.INSTANCE.IS_GetBatteryChargeLevel(eState, batteryLevel, maxBatteryLevel);
					System.out.print(batteryLevel.getValue() + ", ");
					
					System.out.print(EmoState.INSTANCE.IS_GetContactQuality(eState, 
										IEE_InputChannels_t.IEE_CHAN_AF3.getType()) + ", ");
					System.out.print(EmoState.INSTANCE.IS_GetContactQuality(eState, 
										IEE_InputChannels_t.IEE_CHAN_T7.getType()) + ", ");
					System.out.print(EmoState.INSTANCE.IS_GetContactQuality(eState, 
										IEE_InputChannels_t.IEE_CHAN_Pz.getType()) + ", ");
					System.out.print(EmoState.INSTANCE.IS_GetContactQuality(eState, 
										IEE_InputChannels_t.IEE_CHAN_T8.getType()) + ", ");
					System.out.println(EmoState.INSTANCE.IS_GetContactQuality(eState, 
										IEE_InputChannels_t.IEE_CHAN_AF4.getType()) + ", ");
				}
			} else if (state != EdkErrorCode.EDK_NO_EVENT.ToInt()) {
				System.out.println("Internal error in Emotiv Engine!");
				break;
			}
		}

		Edk.INSTANCE.IEE_EngineDisconnect();
		System.out.println("Disconnected!");
	}
}

package com.emotiv.examples.EmoStateLogger;

import com.emotiv.Iedk.*;
import com.sun.jna.Pointer;
import com.sun.jna.ptr.*;

/** Simple example of JNA interface mapping and usage. */
public class EmoStateLogger {
	public static void main(String[] args) {
		Pointer eEvent = Edk.INSTANCE.IEE_EmoEngineEventCreate();
		Pointer eState = Edk.INSTANCE.IEE_EmoStateCreate();
		IntByReference userID = null;
		short composerPort = 1726;
		int option = 1;
		int state = 0;

		userID = new IntByReference(0);

		switch (option) {
		case 1: {
			if (Edk.INSTANCE.IEE_EngineConnect("Emotiv Systems-5") != EdkErrorCode.EDK_OK
					.ToInt()) {
				System.out.println("Emotiv Engine start up failed.");
				return;
			}
			break;
		}
		case 2: {
			System.out.println("Target IP of EmoComposer: [127.0.0.1] ");

			if (Edk.INSTANCE.IEE_EngineRemoteConnect("127.0.0.1", composerPort,
					"Emotiv Systems-5") != EdkErrorCode.EDK_OK.ToInt()) {
				System.out
						.println("Cannot connect to EmoComposer on [127.0.0.1]");
				return;
			}
			System.out.println("Connected to EmoComposer on [127.0.0.1]");
			break;
		}
		default:
			System.out.println("Invalid option...");
			return;
		}

		while (true) {
			state = Edk.INSTANCE.IEE_EngineGetNextEvent(eEvent);

			// New event needs to be handled
			if (state == EdkErrorCode.EDK_OK.ToInt()) {

				int eventType = Edk.INSTANCE.IEE_EmoEngineEventGetType(eEvent);
				Edk.INSTANCE.IEE_EmoEngineEventGetUserId(eEvent, userID);

				// Log the EmoState if it has been updated
				if (eventType == Edk.IEE_Event_t.IEE_EmoStateUpdated.ToInt()) {

					Edk.INSTANCE.IEE_EmoEngineEventGetEmoState(eEvent, eState);
					float timestamp = EmoState.INSTANCE
							.IS_GetTimeFromStart(eState);
					System.out.println(timestamp + " : New EmoState from user "
							+ userID.getValue());

					System.out.print("WirelessSignalStatus: ");
					System.out.println(EmoState.INSTANCE
							.IS_GetWirelessSignalStatus(eState));

					if (EmoState.INSTANCE.IS_FacialExpressionIsBlink(eState) == 1)
						System.out.println("Blink");
					if (EmoState.INSTANCE.IS_FacialExpressionIsLeftWink(eState) == 1)
						System.out.println("LeftWink");
					if (EmoState.INSTANCE
							.IS_FacialExpressionIsRightWink(eState) == 1)
						System.out.println("RightWink");

					System.out.print("ExcitementScore: ");
					System.out.print("MentalCommandGetCurrentAction: ");
					System.out.println(EmoState.INSTANCE
							.IS_MentalCommandGetCurrentAction(eState));
					System.out.print("CurrentActionPower: ");
					System.out.println(EmoState.INSTANCE
							.IS_MentalCommandGetCurrentActionPower(eState));
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

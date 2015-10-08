package com.emotiv.examples.MotionDataLogger;
import com.emotiv.Iedk.*;
import com.sun.jna.Pointer;
import com.sun.jna.ptr.IntByReference;

public class MotionDataLogger {
	public static void main(String[] args) {
		Pointer eEvent = Edk.INSTANCE.IEE_EmoEngineEventCreate();
		Pointer eState = Edk.INSTANCE.IEE_EmoStateCreate();
		IntByReference userID = null;
		IntByReference nSamplesTaken = null;
		float secs = 1;
		int state = 0;

		boolean readytocollect = false;

		userID = new IntByReference(0);
		nSamplesTaken = new IntByReference(0);

		if (Edk.INSTANCE.IEE_EngineConnect("Emotiv Systems-5") != EdkErrorCode.EDK_OK
				.ToInt()) {
			System.out.println("Emotiv Engine start up failed.");
			return;
		}

		Pointer hMotionData = Edk.INSTANCE.IEE_MotionDataCreate();
		Edk.INSTANCE.IEE_MotionDataSetBufferSizeInSec(secs);
		System.out.print("Buffer size in secs: ");
		System.out.println(secs);

		System.out.println("Start receiving Motion Data!");
		System.out.println("COUNTER, GYROX, GYROY, GYROZ, ACCX, ACCY, ACCZ, MAGX, "
							+ "MAGY, MAGZ, TIMESTAMP");
		while (true) {
			state = Edk.INSTANCE.IEE_EngineGetNextEvent(eEvent);

			// New event needs to be handled
			if (state == EdkErrorCode.EDK_OK.ToInt()) {
				int eventType = Edk.INSTANCE.IEE_EmoEngineEventGetType(eEvent);
				Edk.INSTANCE.IEE_EmoEngineEventGetUserId(eEvent, userID);

				// Log the EmoState if it has been updated
				if (eventType == Edk.IEE_Event_t.IEE_UserAdded.ToInt())
					if (userID != null) {
						System.out.println("User added");
						readytocollect = true;
					}
			} else if (state != EdkErrorCode.EDK_NO_EVENT.ToInt()) {
				System.out.println("Internal error in Emotiv Engine!");
				break;
			}

			if (readytocollect) {
				Edk.INSTANCE.IEE_MotionDataUpdateHandle(0, hMotionData);

				Edk.INSTANCE.IEE_MotionDataGetNumberOfSample(hMotionData, nSamplesTaken);

				if (nSamplesTaken != null) {
					if (nSamplesTaken.getValue() != 0) {

						System.out.print("Updated: ");
						System.out.println(nSamplesTaken.getValue());

						double[] data = new double[nSamplesTaken.getValue()];
						for (int sampleIdx = 0; sampleIdx < nSamplesTaken
								.getValue(); ++sampleIdx) {
							for (int i = 0; i < 10; i++) {

								Edk.INSTANCE.IEE_MotionDataGet(hMotionData, i, data,
										nSamplesTaken.getValue());
								System.out.print(data[sampleIdx]);
								System.out.print(", ");
							}
							System.out.println();
						}
					}
				}
			}
		}

		Edk.INSTANCE.IEE_EngineDisconnect();
		Edk.INSTANCE.IEE_EmoStateFree(eState);
		Edk.INSTANCE.IEE_EmoEngineEventFree(eEvent);
		System.out.println("Disconnected!");
	}
}

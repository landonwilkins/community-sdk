package com.emotiv.getdata;

import java.util.Timer;
import java.util.TimerTask;

import com.emotiv.insight.IEdk;
import com.emotiv.insight.MentalCommandDetection.IEE_MentalCommandEvent_t;
import com.emotiv.insight.MentalCommandDetection.IEE_MentalCommandTrainingControl_t;
import com.emotiv.insight.IEdkErrorCode;
import com.emotiv.insight.IEmoStateDLL;
import com.emotiv.insight.IEmoStateDLL.IEE_MentalCommandAction_t;
import com.emotiv.insight.MentalCommandDetection;
import com.emotiv.mentalcommand.ActivityTrainning;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.IntentSender.SendIntentException;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

public class EngineConnector {

	public static Context context;
	public static EngineConnector engineConnectInstance;
	private Timer timer;
	private TimerTask timerTask;

	public boolean isConnected = false;
	private int state;
	private int userId=-1;

	/* ============================================ */
	protected static final int TYPE_USER_ADD = 16;
	protected static final int TYPE_USER_REMOVE = 32;
	protected static final int TYPE_EMOSTATE_UPDATE = 64;
	protected static final int TYPE_METACOMMAND_EVENT = 256;
	/* ============================================ */
	protected static final int HANDLER_TRAIN_STARTED = 1;
	protected static final int HANDLER_TRAIN_SUCCEED = 2;
	protected static final int HANDLER_TRAIN_COMPLETED = 3;
	protected static final int HANDLER_TRAIN_ERASED = 4;
	protected static final int HANDLER_TRAIN_REJECTED = 5;
	protected static final int HANDLER_ACTION_CURRENT = 6;
	protected static final int HANDLER_USER_ADD = 7;
	protected static final int HANDLER_USER_REMOVE = 8;
	protected static final int HANDLER_TRAINED_RESET = 9;

	public EngineInterface delegate;

	public static void setContext(Context context) {
		EngineConnector.context = context;
	}

	public static EngineConnector shareInstance() {
		if (engineConnectInstance == null) {
			engineConnectInstance = new EngineConnector();
		}
		return engineConnectInstance;
	}

	public EngineConnector() {
		connectEngine();
	}

	private void connectEngine() {
		IEdk.IEE_EngineConnect(EngineConnector.context);
		timer = new Timer();
		timerTask();
		timer.schedule(timerTask, 0, 10);
	}

	public void enableMentalcommandActions(IEE_MentalCommandAction_t _MetalcommandAction) {
		long MetaCommandActions;
		long[] activeAction = MentalCommandDetection.IEE_MentalCommandGetActiveActions(userId);
		if (activeAction[0] == IEdkErrorCode.EDK_OK.ToInt()) {
			long y = activeAction[1] & (long) _MetalcommandAction.ToInt(); // and
			if (y == 0) {
				MetaCommandActions = activeAction[1]| ((long) _MetalcommandAction.ToInt()); // or
				MentalCommandDetection.IEE_MentalCommandSetActiveActions(userId, MetaCommandActions);
				
			}
		}
	}

	public boolean checkTrained(int action) {
		long[] result = MentalCommandDetection.IEE_MentalCommandGetTrainedSignatureActions(userId);
		if (result[0] == IEdkErrorCode.EDK_OK.ToInt()) {
			long y = result[1] & action;
			return (y == action);
		}
		return false;
	}

	public void trainningClear(int _MetalcommandAction) {
		MentalCommandDetection.IEE_MentalCommandSetTrainingAction(userId, _MetalcommandAction);
		if (MentalCommandDetection.IEE_MentalCommandSetTrainingControl(userId,
				IEE_MentalCommandTrainingControl_t.MC_ERASE.getType()) == IEdkErrorCode.EDK_OK
				.ToInt()) {
		}
	}

	public boolean startTrainingMetalcommand(Boolean isTrain,
			IEE_MentalCommandAction_t MetaCommandAction) {
		if (!isTrain) {
			if (MentalCommandDetection.IEE_MentalCommandSetTrainingAction(userId,
					MetaCommandAction.ToInt()) == IEdkErrorCode.EDK_OK.ToInt()) {
				if (MentalCommandDetection.IEE_MentalCommandSetTrainingControl(userId,
						IEE_MentalCommandTrainingControl_t.MC_START.getType()) == IEdkErrorCode.EDK_OK
						.ToInt()) {
					return true;
				}
			}
		} else {
			if (MentalCommandDetection.IEE_MentalCommandSetTrainingControl(userId,
					IEE_MentalCommandTrainingControl_t.MC_RESET.getType()) == IEdkErrorCode.EDK_OK
					.ToInt()) {
				return false;
			}
		}
		return false;
	}

	public void setTrainControl(int type) {
		if (MentalCommandDetection.IEE_MentalCommandSetTrainingControl(userId, type) == IEdkErrorCode.EDK_OK
				.ToInt()) {
		}

	}

	public void timerTask() {
		if (timerTask != null)
			return;
		timerTask = new TimerTask() {

			@Override
			public void run() {
				// TODO Auto-generated method stub
				int numberDevice=IEdk.IEE_GetNumberDeviceInsight();
				if(numberDevice!=0)
				{
					if(!isConnected)
						IEdk.IEE_ConnectDevice(0);
				}
				state = IEdk.IEE_EngineGetNextEvent();
				if (state == IEdkErrorCode.EDK_OK.ToInt()) {
					int eventType = IEdk.IEE_EmoEngineEventGetType();
					switch (eventType) {
					case TYPE_USER_ADD:
						Log.e("connect", "User Added");
						isConnected = true;
						userId = IEdk.IEE_EmoEngineEventGetUserId();
						hander.sendEmptyMessage(HANDLER_USER_ADD);
						break;
					case TYPE_USER_REMOVE:
						Log.e("disconnect", "User Removed");
						isConnected = false;
						userId=-1;
						hander.sendEmptyMessage(HANDLER_USER_REMOVE);
						break;
					case TYPE_EMOSTATE_UPDATE:
						if (!isConnected)
							break;
						IEdk.IEE_EmoEngineEventGetEmoState();
						hander.sendMessage(hander
								.obtainMessage(HANDLER_ACTION_CURRENT));

						break;
					case TYPE_METACOMMAND_EVENT:
						int type = MentalCommandDetection.IEE_MentalCommandEventGetType();
						if (type == IEE_MentalCommandEvent_t.IEE_MentalCommandTrainingStarted
								.getType()) {
							Log.e("", "start");
							hander.sendEmptyMessage(HANDLER_TRAIN_STARTED);
						} else if (type == IEE_MentalCommandEvent_t.IEE_MentalCommandTrainingSucceeded
								.getType()) {
							hander.sendEmptyMessage(HANDLER_TRAIN_SUCCEED);
						} else if (type == IEE_MentalCommandEvent_t.IEE_MentalCommandTrainingCompleted
								.getType()) {
							hander.sendEmptyMessage(HANDLER_TRAIN_COMPLETED);
						} else if (type == IEE_MentalCommandEvent_t.IEE_MentalCommandTrainingDataErased
								.getType()) {
							hander.sendEmptyMessage(HANDLER_TRAIN_ERASED);

						} else if (type == IEE_MentalCommandEvent_t.IEE_MentalCommandTrainingFailed
								.getType()) {

						} else if (type == IEE_MentalCommandEvent_t.IEE_MentalCommandTrainingRejected
								.getType()) {
							hander.sendEmptyMessage(HANDLER_TRAIN_REJECTED);
						} else if (type == IEE_MentalCommandEvent_t.IEE_MentalCommandTrainingReset
								.getType()) {
							hander.sendEmptyMessage(HANDLER_TRAINED_RESET);
						}
						break;
					default:
						break;
					}
				}
			}
		};
	}

	Handler hander = new Handler() {
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case HANDLER_USER_ADD:
				if (delegate != null)
					delegate.userAdd(userId);
				break;
			case HANDLER_USER_REMOVE:
				if (delegate != null)
					delegate.userRemoved();
				break;
			case HANDLER_ACTION_CURRENT:
				if (delegate != null)
					delegate.currentAction(IEmoStateDLL
							.IS_MentalCommandGetCurrentAction(), IEmoStateDLL
							.IS_MentalCommandGetCurrentActionPower());
				break;
			case HANDLER_TRAIN_STARTED:
				if (delegate != null)
					delegate.trainStarted();
				break;
			case HANDLER_TRAIN_SUCCEED:
				if (delegate != null)
					delegate.trainSucceed();
				break;
			case HANDLER_TRAIN_COMPLETED:
				if (delegate != null)
					delegate.trainCompleted();
				break;
			case HANDLER_TRAIN_ERASED:
				if (delegate != null)
					delegate.trainErased();
				break;
			case HANDLER_TRAIN_REJECTED:
				if (delegate != null)
					delegate.trainRejected();
				break;
			case HANDLER_TRAINED_RESET:
				if (delegate != null)
					delegate.trainReset();
				break;
			default:
				break;
			}
		}
	};
}

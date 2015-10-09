package com.emotiv.mentalcommand;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Timer;
import java.util.TimerTask;

import com.emotiv.getdata.EngineConnector;
import com.emotiv.getdata.EngineInterface;
import com.emotiv.insight.IEdk;
import com.emotiv.insight.IEdkErrorCode;
import com.emotiv.insight.MentalCommandDetection.IEE_MentalCommandTrainingControl_t;
import com.emotiv.insight.IEmoStateDLL.IEE_FacialExpressionAlgo_t;
import com.emotiv.insight.IEmoStateDLL.IEE_MentalCommandAction_t;
import com.emotiv.insight.MentalCommandDetection;
import com.emotiv.spinner.AdapterSpinner;
import com.emotiv.spinner.DataSpinner;

import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.graphics.Point;
import android.util.Log;
import android.view.Display;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.Spinner;
import android.widget.SpinnerAdapter;
import android.widget.Toast;

public class ActivityTrainning extends Activity implements EngineInterface {
	
	EngineConnector engineConnector;
	
	 Spinner spinAction;
	 Button btnTrain,btnClear; 
	 ProgressBar progressBarTime,progressPower;
	 AdapterSpinner spinAdapter;
	 ImageView imgBox;
	 ArrayList<DataSpinner> model = new ArrayList<DataSpinner>();
	 int indexAction, _currentAction,userId=0,count=0;
	 
	 Timer timer;
	 TimerTask timerTask;
	 
	 float _currentPower = 0;
	 float startLeft     = -1;
	 float startRight    = 0;
	 float widthScreen   = 0;
	  
	 boolean isTrainning = false;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_trainning);
		engineConnector = EngineConnector.shareInstance();
		engineConnector.delegate = this;
		init();
	}
	public void init()
	{
			spinAction=(Spinner)findViewById(R.id.spinnerAction);
			btnTrain=(Button)findViewById(R.id.btstartTraing);
			btnClear=(Button)findViewById(R.id.btClearData);
			btnClear.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View arg0) {
					// TODO Auto-generated method stub
					switch (indexAction) {
					case 0:
						engineConnector.trainningClear(IEE_MentalCommandAction_t.MC_NEUTRAL.ToInt());
						break;
					case 1:
						engineConnector.trainningClear(IEE_MentalCommandAction_t.MC_PUSH.ToInt());
						break;
					case 2:
						engineConnector.trainningClear(IEE_MentalCommandAction_t.MC_PULL.ToInt());
						break;
					case 3:
						engineConnector.trainningClear(IEE_MentalCommandAction_t.MC_LEFT.ToInt());
						break;
					case 4:
						engineConnector.trainningClear(IEE_MentalCommandAction_t.MC_RIGHT.ToInt());
						break;
					default:
						break;
					}
				}
			});
			progressBarTime=(ProgressBar)findViewById(R.id.progressBarTime);
			progressBarTime.setVisibility(View.INVISIBLE);
			progressPower=(ProgressBar)findViewById(R.id.ProgressBarpower);
			imgBox=(ImageView)findViewById(R.id.imgBox);
			
			setDataSpinner();
			spinAction.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
				public void onItemSelected(AdapterView<?> arg0, View arg1,
						int arg2, long arg3) {
					indexAction=arg2;
				}
				public void onNothingSelected(AdapterView<?> arg0) {
					// TODO Auto-generated method stub
				}
			});
			btnTrain.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View v) {
					// TODO Auto-generated method stub
					if(!engineConnector.isConnected)
						Toast.makeText(ActivityTrainning.this,"You need to connect to your headset.",Toast.LENGTH_SHORT).show();
					else{
						switch (indexAction) {
						case 0:
							startTrainingMentalcommand(IEE_MentalCommandAction_t.MC_NEUTRAL);
							break;
						case 1:
							engineConnector.enableMentalcommandActions(IEE_MentalCommandAction_t.MC_PUSH);
							startTrainingMentalcommand(IEE_MentalCommandAction_t.MC_PUSH);
							break;
						case 2:
							engineConnector.enableMentalcommandActions(IEE_MentalCommandAction_t.MC_PULL);
							startTrainingMentalcommand(IEE_MentalCommandAction_t.MC_PULL);
							break;
						case 3:
							engineConnector.enableMentalcommandActions(IEE_MentalCommandAction_t.MC_LEFT);
							startTrainingMentalcommand(IEE_MentalCommandAction_t.MC_LEFT);
							break;
						case 4:
							engineConnector.enableMentalcommandActions(IEE_MentalCommandAction_t.MC_RIGHT);
							startTrainingMentalcommand(IEE_MentalCommandAction_t.MC_RIGHT);
							break;
						default:
							break;
						}
					}
				}
			});

			Timer timerListenAction = new Timer();
			timerListenAction.scheduleAtFixedRate(new TimerTask() {
			    @Override
			    public void run() {
			    	handlerUpdateUI.sendEmptyMessage(1);
			    }
			},
			0, 20);	
			
	}
	Handler handlerUpdateUI=new Handler(){
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				count ++;
				int trainningTime=(int)MentalCommandDetection.IEE_MentalCommandGetTrainingTime(userId)[1]/1000;
				progressBarTime.setProgress(count / trainningTime);
				if (progressBarTime.getProgress() >= 100) {
					timerTask.cancel();
					timer.cancel();
				}
				break;
			case 1:
				moveImage();
				break;
			default:
				break;
			}
		};
	};

	public void startTrainingMentalcommand(IEE_MentalCommandAction_t MentalCommandAction) {
		isTrainning = engineConnector.startTrainingMetalcommand(isTrainning, MentalCommandAction);
		btnTrain.setText((isTrainning) ? "Abort Trainning" : "Train");
	}
	
	public void setDataSpinner()
	{
		model.clear();
		DataSpinner data = new DataSpinner();
		data.setTvName("Neutral");
		data.setChecked(engineConnector.checkTrained(IEE_MentalCommandAction_t.MC_NEUTRAL.ToInt()));
		model.add(data);
		
		data=new DataSpinner();
		data.setTvName("Push");
		data.setChecked(engineConnector.checkTrained(IEE_MentalCommandAction_t.MC_PUSH.ToInt()));
		model.add(data);
		
		data=new DataSpinner();
		data.setTvName("Pull");
		data.setChecked(engineConnector.checkTrained(IEE_MentalCommandAction_t.MC_PULL.ToInt()));
		model.add(data);
		
		data=new DataSpinner();
		data.setTvName("Left");
		data.setChecked(engineConnector.checkTrained(IEE_MentalCommandAction_t.MC_LEFT.ToInt()));
		model.add(data);
		
		
		data=new DataSpinner();
		data.setTvName("Right");
		data.setChecked(engineConnector.checkTrained(IEE_MentalCommandAction_t.MC_RIGHT.ToInt()));
		model.add(data);
		
		spinAdapter = new AdapterSpinner(this, R.layout.row, model);
		spinAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		spinAction.setAdapter(spinAdapter);
	}
	

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.activity_trainning, menu);
		return true;
	}
	public void TimerTask()
	{
		count = 0;
		timerTask=new TimerTask() {
			@Override
			public void run() {
				// TODO Auto-generated method stub
				handlerUpdateUI.sendEmptyMessage(0);
			}
		};
	}
	@Override
	public void onWindowFocusChanged(boolean hasFocus) {
		    Display display = getWindowManager().getDefaultDisplay();
			Point size = new Point();
			display.getSize(size);
			widthScreen = size.x;
			startLeft = imgBox.getLeft();
			startRight = imgBox.getRight();
	}
	
	private void moveImage() {
			float power = _currentPower;
			if(isTrainning){
				imgBox.setLeft((int)(startLeft));
				imgBox.setRight((int) startRight);
				imgBox.setScaleX(1.0f);
				imgBox.setScaleY(1.0f);
			}
			if(( _currentAction == IEE_MentalCommandAction_t.MC_LEFT.ToInt())  || (_currentAction == IEE_MentalCommandAction_t.MC_RIGHT.ToInt()) && power > 0) {

				if(imgBox.getScaleX() == 1.0f && startLeft > 0) {
					imgBox.setRight((int) widthScreen);
					power = (_currentAction == IEE_MentalCommandAction_t.MC_LEFT.ToInt()) ? power*3 : power*-3;
					imgBox.setLeft((int) (power > 0 ? Math.max(0, (int)(imgBox.getLeft() - power)) : Math.min(widthScreen - imgBox.getMeasuredWidth(), (int)(imgBox.getLeft() - power))));
				}
			}
			else if(imgBox.getLeft() != startLeft && startLeft > 0){
				power = (imgBox.getLeft() > startLeft) ? 6 : -6;
				imgBox.setLeft(power > 0  ? Math.max((int)startLeft, (int)(imgBox.getLeft() - power)) : Math.min((int)startLeft, (int)(imgBox.getLeft() - power)));
			}
			if(((_currentAction == IEE_MentalCommandAction_t.MC_PULL.ToInt()) || (_currentAction == IEE_MentalCommandAction_t.MC_PUSH.ToInt())) && power > 0) {
				if(imgBox.getLeft() != startLeft)
					return;
				imgBox.setRight((int) startRight);
				power = (_currentAction == IEE_MentalCommandAction_t.MC_PUSH.ToInt()) ? power / 20 : power/-20;
				imgBox.setScaleX((float) (power > 0 ? Math.max(0.1, (imgBox.getScaleX() - power)) : Math.min(2, (imgBox.getScaleX() - power))));
				imgBox.setScaleY((float) (power > 0 ? Math.max(0.1, (imgBox.getScaleY() - power)) : Math.min(2, (imgBox.getScaleY() - power))));
			} 
			else if(imgBox.getScaleX() != 1.0f){
				power = (imgBox.getScaleX() < 1.0f) ? 0.03f : -0.03f;
				imgBox.setScaleX((float) (power > 0 ? Math.min(1, (imgBox.getScaleX() + power)) : Math.max(1, (imgBox.getScaleX() + power))));
				imgBox.setScaleY((float) (power > 0 ? Math.min(1, (imgBox.getScaleY() + power)) : Math.max(1, (imgBox.getScaleY() + power))));		
			}
		}
	public void enableClick()
	{
		btnClear.setClickable(true);
		spinAction.setClickable(true);
	}
	@Override
	public void userAdd(int userId) {
		// TODO Auto-generated method stub
		this.userId=userId;
	}
	@Override
	public void currentAction(int typeAction, float power) {
		// TODO Auto-generated method stub
		progressPower.setProgress((int)(power*100));
		_currentAction = typeAction;
		_currentPower  = power;
	}

	@Override
	public void userRemoved() {
		// TODO Auto-generated method stub
	}
	
	@Override
	public void trainStarted() {
		// TODO Auto-generated method stub
		progressBarTime.setVisibility(View.VISIBLE);
		btnClear.setClickable(false);
		spinAction.setClickable(false);
		 timer = new Timer();
		 TimerTask();
		 timer.schedule(timerTask , 0, 10);
	}

	@Override
	public void trainSucceed() {
		// TODO Auto-generated method stub
		progressBarTime.setVisibility(View.INVISIBLE);
		btnTrain.setText("Train");
		enableClick();
		AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(
				ActivityTrainning.this);
		// set title
		alertDialogBuilder.setTitle("Training Succeeded");
		// set dialog message
		alertDialogBuilder
				.setMessage("Training is successful. Accept this training?")
				.setCancelable(false)
				.setIcon(R.drawable.ic_launcher)
				.setPositiveButton("Yes",
						new DialogInterface.OnClickListener() {
							public void onClick(
									DialogInterface dialog,int which) {
								engineConnector.setTrainControl(IEE_MentalCommandTrainingControl_t.MC_ACCEPT.getType());
							}
						})
				.setNegativeButton("No",
						new DialogInterface.OnClickListener() {
							public void onClick(DialogInterface dialog,int id) {
								engineConnector.setTrainControl(IEE_MentalCommandTrainingControl_t.MC_REJECT.getType()); 
							}
						});

		AlertDialog alertDialog = alertDialogBuilder.create();
		alertDialog.show();
	}

	@Override
	public void trainCompleted() {
		// TODO Auto-generated method stub
		DataSpinner data=model.get(indexAction);
		data.setChecked(true);
		model.set(indexAction, data);
		spinAdapter.notifyDataSetChanged();
	}

	@Override
	public void trainRejected() {
		// TODO Auto-generated method stub
		DataSpinner data=model.get(indexAction);
		data.setChecked(false);
		model.set(indexAction, data);
		spinAdapter.notifyDataSetChanged();
		enableClick();
		isTrainning = false;
	}

	@Override
	public void trainErased() {
		// TODO Auto-generated method stub
		 new AlertDialog.Builder(this)
	    .setTitle("Training Erased")
	    .setMessage("")
	    .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
	     public void onClick(DialogInterface dialog, int which) { 
	        }
	     })
	    .setIcon(android.R.drawable.ic_dialog_alert)
	     .show();
		DataSpinner data=model.get(indexAction);
		data.setChecked(false);
		model.set(indexAction, data);
		spinAdapter.notifyDataSetChanged();
		enableClick();
		isTrainning = false;
	}
	
	@Override
	public void trainReset() {
		// TODO Auto-generated method stub
		if(timer!=null){
			timer.cancel();
			timerTask.cancel();
		}
		isTrainning = false;
		progressBarTime.setVisibility(View.INVISIBLE);
		progressBarTime.setProgress(0);
		enableClick();
	};
	
	public void onBackPressed() {
		 android.os.Process.killProcess(android.os.Process.myPid());
		  finish(); 
	 }
}

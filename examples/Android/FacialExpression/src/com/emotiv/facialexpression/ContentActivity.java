package com.emotiv.facialexpression;

import java.util.ArrayList;
import java.util.Currency;
import java.util.HashMap;
import java.util.Timer;
import java.util.TimerTask;
import java.util.Vector;

import com.emotiv.customspinner.CustomAdapter;
import com.emotiv.customspinner.CustomSpinner;
import com.emotiv.customspinner.SpinnerModel;
import com.emotiv.dateget.EngineConnector;
import com.emotiv.dateget.EngineInterface;
import com.emotiv.insight.IEdk;
import com.emotiv.insight.FacialExpressionDetection;
import com.emotiv.insight.FacialExpressionDetection.IEE_FacialExpressionEvent_t;
import com.emotiv.insight.FacialExpressionDetection.IEE_FacialExpressionThreshold_t;
import com.emotiv.insight.FacialExpressionDetection.IEE_FacialExpressionTrainingControl_t;
import com.emotiv.insight.IEmoStateDLL.IEE_FacialExpressionAlgo_t;
import com.emotiv.insight.IEmoStateDLL.IEE_MentalCommandAction_t;

import android.R.bool;
import android.R.color;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.res.Resources;
import android.graphics.Color;
import android.graphics.Point;
import android.media.ExifInterface;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.Display;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.Spinner;
import android.widget.Toast;


@SuppressLint("NewApi")
public class ContentActivity extends Activity implements EngineInterface{
    Spinner spinner,spinnerSensitive;
    CustomSpinner spinner2;
    TimerTask timerTask,timerTaskAnimation;
    CustomAdapter adapter,adapterSpinnerAction,adapterSensitive;
    ImageView   imgBox;
    ProgressBar barTime,powerBar;
    Timer timer;
    boolean mapping= false;
    int indexActionSellected = 0;
    
    private Vector<String> mappingAction;
    int userId = 0,count = 0;
    EngineConnector engineConnector;
    Button btStartTrainning,btClear;
    
	 public static float _currentPower = 0;
	 boolean isTrainning = false;
	 String currentRunningAction="";
	 
	 float startLeft 	= -1;
	 float startRight 	= 0;
	 float widthScreen 	= 0;
	  
	 public  ArrayList<SpinnerModel> CustomListViewValuesArr  = new ArrayList<SpinnerModel>();
	 public  ArrayList<SpinnerModel> CustomListViewValuesArr2 = new ArrayList<SpinnerModel>();
	 public  ArrayList<SpinnerModel> CustomListViewValuesArr3 = new ArrayList<SpinnerModel>();
	 
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.content);
		engineConnector =EngineConnector.shareInstance();
		engineConnector.delegate = this;
		mappingAction = new Vector<String>();
		mappingAction.add("Neutral");
		mappingAction.add("Pull");
		mappingAction.add("Push");
		mappingAction.add("Left");
		mappingAction.add("Right");
		// get signals view
		spinner = (Spinner) this.findViewById(R.id.spinner1);
		spinner2 = (CustomSpinner) this.findViewById(R.id.spinner2);
		spinnerSensitive = (Spinner) this.findViewById(R.id.spinner3);
		
		barTime = (ProgressBar) this.findViewById(R.id.progressTimer);
		powerBar = (ProgressBar) this.findViewById(R.id.ProgressBarpower);
		imgBox = (ImageView) this.findViewById(R.id.imgBox);
		btStartTrainning=(Button)this.findViewById(R.id.btStartTrainning);
		btClear=(Button)this.findViewById(R.id.btClear);
		btStartTrainning.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				if(!engineConnector.isConnected)
					Toast.makeText(ContentActivity.this,"You need to connect to your headset.",Toast.LENGTH_SHORT).show();
				else{
					switch (indexActionSellected) {
					case 0:
						// neutral
						startTrainingFacialExpression(IEE_FacialExpressionAlgo_t.FE_NEUTRAL);
						break;
					case 1:
						//smile
						startTrainingFacialExpression(IEE_FacialExpressionAlgo_t.FE_SMILE);
						break;
					case 2:
						//clench
						startTrainingFacialExpression(IEE_FacialExpressionAlgo_t.FE_CLENCH);
						break;
					case 3:
						//frown
						startTrainingFacialExpression(IEE_FacialExpressionAlgo_t.FE_FROWN);
						break;	
					case 4:
						//suprise
						startTrainingFacialExpression(IEE_FacialExpressionAlgo_t.FE_SURPRISE);
						break;		
					default:
						break;
					}
				}
			}
		});
		btClear.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				clearData();
			}
		});
		barTime.setVisibility(View.INVISIBLE);
		setListData();
		Resources res = getResources(); 
		adapterSpinnerAction = new CustomAdapter(getApplicationContext(), R.layout.spinner, CustomListViewValuesArr,res);
	        // Set adapter to spinner
		spinner.setAdapter(adapterSpinnerAction);
		spinner.setOnItemSelectedListener(new OnItemSelectedListener() {

			@Override
			public void onItemSelected(AdapterView<?> arg0, View arg1,
					int arg2, long arg3) {
				// TODO Auto-generated method stub
				indexActionSellected = arg2;
				mapping = true;
				spinner2.setSelection(indexActionSellected);
			}
			
			@Override
			public void onNothingSelected(AdapterView<?> arg0) {
				// TODO Auto-generated method stub
				
			}
		});
		
		adapter = new CustomAdapter(getApplicationContext(), R.layout.spinner, CustomListViewValuesArr2,res);
		adapter.headerData = mappingAction;
		spinner2.setAdapter(adapter);
		spinner2.setOnItemSelectedListener(new OnItemSelectedListener() {
		  
			@Override
			public void onItemSelected(AdapterView<?> arg0, View arg1,
					int arg2, long arg3) {
				// TODO Auto-generated method stub
				if (mapping) {
					mapping = false;
					return;
				}
				mapping = true;
			   	switch (arg2){
			   		case 0:
			   		 	mappingAction.setElementAt("Neutral", indexActionSellected);
			   			break;
			   		case 1:
			   		 	mappingAction.setElementAt("Pull", indexActionSellected);
			   			break;
			   		case 2:
			   		 	mappingAction.setElementAt("Push", indexActionSellected);
			   			break;
			   		case 3:
			   			mappingAction.setElementAt("Left", indexActionSellected);
			   			break;
			   		case 4:
			   			mappingAction.setElementAt("Right", indexActionSellected);
			   			break;	
			   	}
			 
			   	spinner2.setSelection(indexActionSellected);
			   	adapter.notifyDataSetChanged();				
			}
			
			@Override
			public void onNothingSelected(AdapterView<?> arg0) {
				// TODO Auto-generated method stub
			}
		});
		adapterSensitive = new CustomAdapter(getApplicationContext(), R.layout.spinner, CustomListViewValuesArr3,res);
		spinnerSensitive.setAdapter(adapterSensitive);
		spinnerSensitive.setSelection(4);
		spinnerSensitive.setOnItemSelectedListener(new OnItemSelectedListener() {
			@Override
			public void onItemSelected(AdapterView<?> arg0, View arg1,
					int arg2, long arg3) {
				switch (indexActionSellected) {
				case 0:
					// neutral
					FacialExpressionDetection.IEE_FacialExpressionSetThreshold(userId,IEE_FacialExpressionAlgo_t.FE_NEUTRAL.ToInt(), IEE_FacialExpressionThreshold_t.FE_SENSITIVITY.toInt(), arg2*100);
					break;
				case 1:
					//smile
					FacialExpressionDetection.IEE_FacialExpressionSetThreshold(userId,IEE_FacialExpressionAlgo_t.FE_SMILE.ToInt(), IEE_FacialExpressionThreshold_t.FE_SENSITIVITY.toInt(), arg2*100);
					break;
				case 2:
					//clench
					FacialExpressionDetection.IEE_FacialExpressionSetThreshold(userId,IEE_FacialExpressionAlgo_t.FE_CLENCH.ToInt(), IEE_FacialExpressionThreshold_t.FE_SENSITIVITY.toInt(), arg2*100);
					break;
				case 3:
					//frown
					FacialExpressionDetection.IEE_FacialExpressionSetThreshold(userId,IEE_FacialExpressionAlgo_t.FE_FROWN.ToInt(), IEE_FacialExpressionThreshold_t.FE_SENSITIVITY.toInt(), arg2*100);
					break;	
				case 4:
					//suprise
					FacialExpressionDetection.IEE_FacialExpressionSetThreshold(userId,IEE_FacialExpressionAlgo_t.FE_SURPRISE.ToInt(), IEE_FacialExpressionThreshold_t.FE_SENSITIVITY.toInt(), arg2*100);
					break;		
				default:
					break;
				}
			}

			@Override
			public void onNothingSelected(AdapterView<?> arg0) {
				// TODO Auto-generated method stub
			}
		}
		);
		Timer timerListenAction = new Timer();
		timerListenAction.scheduleAtFixedRate(new TimerTask() {
		    @Override
		    public void run() {
		    	mHandlerUpdateUI.sendEmptyMessage(1);
		    }
		},
		0, 20);	
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

	
	  public void setListData()
	    {
	         
	        // Now i have taken static values by loop.
	        // For further inhancement we can take data by webservice / json / xml;
	            SpinnerModel sched = new SpinnerModel();
	            sched.setLabel("Neutral");
	            sched.setChecked(engineConnector.checkTrained(IEE_FacialExpressionAlgo_t.FE_NEUTRAL.ToInt()));
	            CustomListViewValuesArr.add(sched);
	            sched= new SpinnerModel();
	            sched.setLabel("Smile");
	            sched.setChecked(engineConnector.checkTrained(IEE_FacialExpressionAlgo_t.FE_SMILE.ToInt()));

	            CustomListViewValuesArr.add(sched);
	            
	            sched= new SpinnerModel();
	            sched.setLabel("Clench");
	            sched.setChecked(engineConnector.checkTrained(IEE_FacialExpressionAlgo_t.FE_CLENCH.ToInt()));

	            CustomListViewValuesArr.add(sched);
	            
	            sched= new SpinnerModel();
	            sched.setLabel("Frown");
	            sched.setChecked(engineConnector.checkTrained(IEE_FacialExpressionAlgo_t.FE_FROWN.ToInt()));
	            sched.setChecked(false);
	            CustomListViewValuesArr.add(sched);
	            
	            sched= new SpinnerModel();
	            sched.setLabel("Surprise");
	            sched.setChecked(engineConnector.checkTrained(IEE_FacialExpressionAlgo_t.FE_SURPRISE.ToInt()));
	            sched.setChecked(false);
	            CustomListViewValuesArr.add(sched);
	            
	          
	            
	            //////////
	            for (int i = 0 ;i < mappingAction.size() ;i ++){
	            	  sched = new SpinnerModel();
	  	            sched.setLabel(mappingAction.elementAt(i));
	  	            sched.setChecked(false);
	  	            CustomListViewValuesArr2.add(sched);
	            }
	            for(int i = 0; i < 11 ; i++){
	                //////////
		            sched = new SpinnerModel();
		            sched.setLabel("" + i);
		            CustomListViewValuesArr3.add(sched);
	            }
	}
	
	private void intTimerTask(){
			count=0;
		   timerTask = new TimerTask() {
			@Override
			 public void run() {
				mHandlerUpdateUI.sendEmptyMessage(0);
			 }
			};
	}
	public void startTrainingFacialExpression(IEE_FacialExpressionAlgo_t FacialExpressionAction) {
		isTrainning = engineConnector.startFacialExpression(isTrainning, FacialExpressionAction);
		btStartTrainning.setText((isTrainning) ? "Abort Trainning" : "Train");
	}
	public void enableClick()
	{
		spinner.setClickable(true);
		spinner2.setClickable(true);
		btClear.setClickable(true);
		spinnerSensitive.setClickable(true);
	}
	private void runAnimation(int index,float power){
		powerBar.setProgress((int) (power*100));
		currentRunningAction = mappingAction.elementAt(index);
	}
	public void clearData(){
		switch (indexActionSellected) {
		case 0:
			// neutral
			engineConnector.trainningClear(IEE_FacialExpressionAlgo_t.FE_NEUTRAL.ToInt());
			break;
		case 1:
			//smile
			engineConnector.trainningClear(IEE_FacialExpressionAlgo_t.FE_SMILE.ToInt());
			break;
		case 2:
			//clench
			engineConnector.trainningClear(IEE_FacialExpressionAlgo_t.FE_CLENCH.ToInt());
			break;
		case 3:
			//furrow
			engineConnector.trainningClear(IEE_FacialExpressionAlgo_t.FE_FROWN.ToInt());
			break;	
		case 4:
			//furrow
			engineConnector.trainningClear(IEE_FacialExpressionAlgo_t.FE_SURPRISE.ToInt());
			break;		
		default:
			break;
		}
	}

	// mark to engine interface
	@Override
	public void userAdded(int userId) {
		// TODO Auto-generated method stub
		this.userId=userId;
	}; 
	@Override
	public void detectedActionLowerFace(int typeAction, float power) {
		// TODO Auto-generated method stub
		_currentPower=power;
		if (typeAction == IEE_FacialExpressionAlgo_t.FE_SMILE.ToInt()) {
			runAnimation(indexActionSellected,power);
		}
		else if (typeAction == IEE_FacialExpressionAlgo_t.FE_CLENCH.ToInt())
			runAnimation(indexActionSellected,power);
	}

	@Override
	public void userRemove() {
		this.userId=-1;
		// TODO Auto-generated method stub
	}
	@Override
	public void trainStarted() {
		// TODO Auto-generated method stub
		   barTime.setVisibility(View.VISIBLE);
		   spinner.setClickable(false);
		   spinner2.setClickable(false);
		   btClear.setClickable(false);
		   spinnerSensitive.setClickable(false);
		   timer = new Timer();
		   intTimerTask();
		   timer.schedule(timerTask ,0, 10);
	}
	@Override
	public void trainSucceed() {
		// TODO Auto-generated method stub
		barTime.setVisibility(View.INVISIBLE);
		enableClick();
		btStartTrainning.setText("Train");
		new AlertDialog.Builder(this)
	    .setTitle("Training Succeeded")
	    .setMessage("Training is successful. Accept this training?")
	    .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
	     public void onClick(DialogInterface dialog, int which) { 
	            // continue with delete
	        	engineConnector.setTrainControl(IEE_FacialExpressionTrainingControl_t.FE_ACCEPT.getType());
	        }
	     })
	    .setNegativeButton(android.R.string.no, new DialogInterface.OnClickListener() {
	        public void onClick(DialogInterface dialog, int which) { 
	            // do nothing
	        	engineConnector.setTrainControl(IEE_FacialExpressionTrainingControl_t.FE_REJECT.getType());
	        }
	     })
	    .setIcon(android.R.drawable.ic_dialog_alert)
	     .show();
	}
	
	
	@Override
	public void trainCompleted() {
		// TODO Auto-generated method stub
		SpinnerModel model = CustomListViewValuesArr.get(indexActionSellected);
		model.setChecked(true);
		CustomListViewValuesArr.set(indexActionSellected, model);
        adapterSpinnerAction.notifyDataSetChanged();
        
        new AlertDialog.Builder(this)
	    .setTitle("Training Completed")
	    .setMessage("")
	    .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
	     public void onClick(DialogInterface dialog, int which) { 
	            // continue with delete
	        }
	     })
	    .setIcon(android.R.drawable.ic_dialog_alert)
	     .show();
	}
	
	@Override
	public void trainRejected() {
		// TODO Auto-generated method stub
		SpinnerModel model = CustomListViewValuesArr.get(indexActionSellected);
		model.setChecked(false);
		enableClick();
		isTrainning=false;
	}

	@Override
	public void trainErased() {
		// TODO Auto-generated method stub
		   new AlertDialog.Builder(this)
		    .setTitle("Training Erased")
		    .setMessage("")
		    .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
		     public void onClick(DialogInterface dialog, int which) { 
		            // continue with delete
		        }
		     })
		    .setIcon(android.R.drawable.ic_dialog_alert)
		     .show();
	  
		SpinnerModel model = CustomListViewValuesArr.get(indexActionSellected);
		model.setChecked(false);
		CustomListViewValuesArr.set(indexActionSellected, model);
		adapterSpinnerAction.notifyDataSetChanged();
		enableClick();
		isTrainning=false;
	}
	@Override
	public void trainReset() {
		// TODO Auto-generated method stub
		if(timer!=null){
			timer.cancel();
			timerTask.cancel();
			barTime.setVisibility(View.INVISIBLE);
			powerBar.setProgress(0);
		}
		enableClick();
		isTrainning=false;
	}

	/// handler
	  public Handler mHandlerUpdateUI = new Handler() {
	       public void handleMessage(Message msg) {
	    	 switch (msg.what) {
			case 0:
				count ++;
				int trainningTime=(int)FacialExpressionDetection.IEE_FacialExpressionGetTrainingTime(userId)[1]/1000;
				barTime.setProgress(count / trainningTime);
				if (barTime.getProgress() > 100) {
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
	       } 
	    };
	    private void moveImage() {
			float power = _currentPower;
			if(isTrainning){
				imgBox.setLeft((int)(startLeft));
				imgBox.setRight((int) startRight);
				imgBox.setScaleX(1.0f);
				imgBox.setScaleY(1.0f);
			}
			if(( currentRunningAction.equals("Neutral"))  || (currentRunningAction.equals("Right")) && power > 0) {

				if(imgBox.getScaleX() == 1.0f && startLeft > 0) {
					
					imgBox.setRight((int) widthScreen);
					power = ( currentRunningAction.equals("Left")) ? power*3 : power*-3;
					imgBox.setLeft((int) (power > 0 ? Math.max(0, (int)(imgBox.getLeft() - power)) : Math.min(widthScreen - imgBox.getMeasuredWidth(), (int)(imgBox.getLeft() - power))));
				}
			}
			else if(imgBox.getLeft() != startLeft && startLeft > 0){
				power = (imgBox.getLeft() > startLeft) ? 6 : -6;
				imgBox.setLeft(power > 0  ? Math.max((int)startLeft, (int)(imgBox.getLeft() - power)) : Math.min((int)startLeft, (int)(imgBox.getLeft() - power)));
			}
			if((( currentRunningAction.equals("Pull")) || ( currentRunningAction.equals("Push"))) && power > 0) {
				if(imgBox.getLeft() != startLeft)
					return;
				imgBox.setRight((int) startRight);
				power = (currentRunningAction.equals("Push")) ? power / 20 : power/-20;
				imgBox.setScaleX((float) (power > 0 ? Math.max(0.1, (imgBox.getScaleX() - power)) : Math.min(2, (imgBox.getScaleX() - power))));
				imgBox.setScaleY((float) (power > 0 ? Math.max(0.1, (imgBox.getScaleY() - power)) : Math.min(2, (imgBox.getScaleY() - power))));
			} 
			else if(imgBox.getScaleX() != 1.0f){
				power = (imgBox.getScaleX() < 1.0f) ? 0.03f : -0.03f;
				imgBox.setScaleX((float) (power > 0 ? Math.min(1, (imgBox.getScaleX() + power)) : Math.max(1, (imgBox.getScaleX() + power))));
				imgBox.setScaleY((float) (power > 0 ? Math.min(1, (imgBox.getScaleY() + power)) : Math.max(1, (imgBox.getScaleY() + power))));		
			}
		}
	       
	 public void onBackPressed() {
		 android.os.Process.killProcess(android.os.Process.myPid());
		  finish(); 
	 }


}

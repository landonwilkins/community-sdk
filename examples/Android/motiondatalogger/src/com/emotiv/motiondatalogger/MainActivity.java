package com.emotiv.motiondatalogger;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import com.example.com.emotiv.eeglogger.R;

import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothManager;
import android.content.Context;
import android.content.Intent;

import com.emotiv.insight.IEdk;
import com.emotiv.insight.IEdkErrorCode;
import com.emotiv.insight.IEdk.IEE_Event_t;;

public class MainActivity extends Activity {

	private static final int REQUEST_ENABLE_BT = 1;
	private BluetoothAdapter mBluetoothAdapter;
	private boolean lock = false;
	private boolean isEnablGetData = false;
	private boolean isEnableWriteFile = false;
	int userId;
	private BufferedWriter motion_writer;
	private final int WHAT_GET_DATA = 5;
	Button Start_button,Stop_button;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		
		final BluetoothManager bluetoothManager =
                (BluetoothManager) getSystemService(Context.BLUETOOTH_SERVICE);
        mBluetoothAdapter = bluetoothManager.getAdapter();
        if (!mBluetoothAdapter.isEnabled()) {
            if (!mBluetoothAdapter.isEnabled()) {
                Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
                startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
            }
        }
		Start_button = (Button)findViewById(R.id.startbutton);
		Stop_button  = (Button)findViewById(R.id.stopbutton);
		
		Start_button.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				Log.e("EEGLogger","Start Write File");
				setDataFile();
				isEnableWriteFile = true;
			}
		});
		Stop_button.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				Log.e("EEGLogger","Stop Write File");
				StopWriteFile();
				isEnableWriteFile = false;
			}
		});
		
		//Connect to emoEngine
		IEdk.IEE_EngineConnect(this);
		IEdk.IEE_MotionDataCreate();
		Thread processingThread=new Thread()
		{
			@Override
			public void run() {
				// TODO Auto-generated method stub
				super.run();
				while(true)
				{
					try
					{
						handler.sendEmptyMessage(0);
						handler.sendEmptyMessage(1);
						if(isEnablGetData && isEnableWriteFile)handler.sendEmptyMessage(2);
						Thread.sleep(5);
					}
					
					catch (Exception ex)
					{
						ex.printStackTrace();
					}
				}
			}
		};		
		processingThread.start();
	}
	
	Handler handler = new Handler() {
		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {

			case 0:
				int state = IEdk.IEE_EngineGetNextEvent();
				if (state == IEdkErrorCode.EDK_OK.ToInt()) {
					int eventType = IEdk.IEE_EmoEngineEventGetType();
				    userId = IEdk.IEE_EmoEngineEventGetUserId();
					if(eventType == IEE_Event_t.IEE_UserAdded.ToInt()){
						Log.e("SDK","User added");
						isEnablGetData = true;
					}
					if(eventType == IEE_Event_t.IEE_UserRemoved.ToInt()){
						Log.e("SDK","User removed");		
						isEnablGetData = false;
					}
				}
				
				break;
			case 1:
				int number = IEdk.IEE_GetNumberDeviceInsight();
				if(number != 0) {
					if(!lock){
						lock = true;
						IEdk.IEE_ConnectDevice(0);
					}
				}
				else lock = false;
				break;
			case 2:
				IEdk.IEE_MotionDataUpdateHandle(userId);
				double[] eeg_data = IEdk.IEE_MotionDataGet();
				if(eeg_data.length > 1) thandler.sendMessage(thandler.obtainMessage(WHAT_GET_DATA,eeg_data));
				break;
			}

		}

	};

	Handler thandler = new Handler(){
		@Override
		public void handleMessage(Message msg){
			switch (msg.what) {
			case WHAT_GET_DATA:
				double[] data = (double[]) msg.obj;
				addEEGData(data);
				break;

			default:
				break;
			}
		} 
	};
	
	private void setDataFile() {
		try {
			String eeg_header = "COUNTER_MEMS,GYROX,GYROY,GYROZ,ACCX,ACCY,ACCZ,MAGX,MAGY,MAGZ,TimeStamp";
			File root = Environment.getExternalStorageDirectory();
			String file_path = root.getAbsolutePath()+ "/MotionLogger/";
			File folder=new File(file_path);
			if(!folder.exists())
			{
				folder.mkdirs();
			}		
			motion_writer = new BufferedWriter(new FileWriter(file_path+"raw_motion.csv"));
			motion_writer.write(eeg_header);
			motion_writer.newLine();
		} catch (Exception e) {
			Log.e("","Exception"+ e.getMessage());
		}
	}
	private void StopWriteFile(){
		try {
			motion_writer.flush();
			motion_writer.close();
		} catch (Exception e) {
			// TODO: handle exception
		}
	}
	/**
	 * public void addEEGData(Double[][] eegs) Add EEG Data for write int the
	 * EEG File
	 * 
	 * @param eegs
	 *            - double array of eeg data
	 */
	public void addEEGData(double[] eegs) {

		if (motion_writer == null) {
			return;
		}

		for (int i = 0; i < eegs.length/11; i++) {
			String input = "";
			for (int j = 0; j < 11; j++) {
				input += (String.valueOf(eegs[i*11+j]) + ",");
			}
			input = input.substring(0, input.length() - 1);
			try {
				motion_writer.write(input);
				motion_writer.newLine();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

		}
	}
}

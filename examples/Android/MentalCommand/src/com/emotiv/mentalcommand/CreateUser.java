package com.emotiv.mentalcommand;

import com.emotiv.getdata.EngineConnector;

import android.os.Bundle;
import android.app.Activity;
import android.content.Intent;
import android.view.Menu;
import android.view.View;
import android.widget.EditText;

public class CreateUser extends Activity {
	EditText etUserName; 
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.create_user);
		EngineConnector.setContext(this);
		etUserName=(EditText)findViewById(R.id.etUserName);
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.create_user, menu);
		return true;
	}
	public void onclickCreate(View v)
	{
//		if (etUserName.length() == 0) return;
		
		
		Intent intent=new Intent(this,ActivityTrainning.class);
		startActivity(intent);
	}

}

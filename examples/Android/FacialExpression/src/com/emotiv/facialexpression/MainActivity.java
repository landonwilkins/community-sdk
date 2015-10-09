package com.emotiv.facialexpression;

import com.emotiv.dateget.EngineConnector;
import com.emotiv.dateget.EngineInterface;
import com.emotiv.insight.IEdk;
import com.emotiv.insight.FacialExpressionDetection.IEE_FacialExpressionSignature_t;
import com.emotiv.insight.FacialExpressionDetection.IEE_FacialExpressionTrainingControl_t;
import com.emotiv.insight.IEmoStateDLL.IEE_FacialExpressionAlgo_t;

import android.os.Bundle;
import android.app.Activity;
import android.content.Intent;
import android.util.Log;
import android.view.Menu;
import android.view.View;

public class MainActivity extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		EngineConnector.setContext(this);
		setContentView(R.layout.activity_main);
		this.finish();
		Intent intent = new Intent(this, ContentActivity.class);
		startActivity(intent);
	}
	
	

}



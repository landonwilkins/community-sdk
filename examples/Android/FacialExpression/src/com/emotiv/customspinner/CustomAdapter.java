package com.emotiv.customspinner;

import java.util.ArrayList;
import java.util.Vector;

import com.emotiv.facialexpression.R;



import android.content.Context;
import android.content.res.Resources;
import android.graphics.Color;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

public class CustomAdapter extends ArrayAdapter<String>{
public  ArrayList<SpinnerModel> CustomListViewValuesArr = new ArrayList<SpinnerModel>();
private Context activity;
private ArrayList data;
public  Vector<String> headerData;
public Resources res;
SpinnerModel tempValues=null;
LayoutInflater inflater;
int save;
public CustomAdapter(Context activitySpinner, int textViewResourceId,   ArrayList objects,Resources resLocal) 
{
super(activitySpinner, textViewResourceId,objects);
/********** Take passed values **********/
activity = activitySpinner;
data     = objects;
res      = resLocal;
save =textViewResourceId;

/***********  Layout inflator to call external xml layout () **********************/
inflater = (LayoutInflater)activity.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

}

@Override
public View getView(int position, View convertView, ViewGroup parent) {
	 View row = inflater.inflate(save, parent, false);
    
	    /***** Get each Model object from Arraylist ********/
	    tempValues = null;
	    tempValues = (SpinnerModel) data.get(position);
	    TextView label        = (TextView)row.findViewById(R.id.textView1);  
	    ImageView imageView = (ImageView) row.findViewById(R.id.imageView1);
	    label.setTextColor(Color.parseColor("#000000"));
	    label.setText(tempValues.getLabel());
	    if (headerData!= null) {
	    	 label.setText(headerData.elementAt(position));
	    }
	    imageView.setVisibility(View.INVISIBLE);
	   
	   
    return row;
}

public View getDropDownView(int position, View convertView,ViewGroup parent) {
	       
    return getCustomView(position, convertView, parent);
}

public View getCustomView(int position, View convertView, ViewGroup parent) {
    /********** Inflate spinner_rows.xml file for each row ( Defined below ) ************/
    View row = inflater.inflate(save, parent, false);
     
    /***** Get each Model object from Arraylist ********/
    tempValues = null;
    tempValues = (SpinnerModel) data.get(position);
     
    TextView label        = (TextView)row.findViewById(R.id.textView1);    
        // Set values for spinner each row 
    label.setTextColor(Color.parseColor("#000000"));
    label.setText(tempValues.getLabel());
    ImageView imageView = (ImageView) row.findViewById(R.id.imageView1);
    // Set values for spinner each row 
    if (!tempValues.isChecked())  {
    	
    	imageView.setVisibility(View.INVISIBLE);
    } 


    return row;
  }
}

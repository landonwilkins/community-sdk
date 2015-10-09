package com.emotiv.spinner;

import java.util.ArrayList;

import com.emotiv.mentalcommand.R;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;


public class AdapterSpinner extends ArrayAdapter<DataSpinner> {
	ArrayList<DataSpinner> data;
	Context context;

	public AdapterSpinner(Context context, int textViewResourceId,
			ArrayList<DataSpinner> model) {
		super(context, textViewResourceId, model);
		this.context=context;
		data = model;
		// TODO Auto-generated constructor stub
	}

	@Override
	public View getDropDownView(int position, View convertView, ViewGroup parent) {
		// TODO Auto-generated method stub
		return getCustomView(position, convertView, parent);
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		// TODO Auto-generated method stub
		return getCustomView(position, convertView, parent);
	}

	public View getCustomView(int position, View convertView, ViewGroup parent) {
		// TODO Auto-generated method stub
		// return super.getView(position, convertView, parent);
		Activity activity=(Activity)context;
		 LayoutInflater inflater=activity.getLayoutInflater();
		View row = inflater.inflate(R.layout.row, parent, false);
		TextView label = (TextView) row.findViewById(R.id.tvTrain);
		label.setTextColor(Color.parseColor("#000000"));
		label.setText(data.get(position).getTvName());
		ImageView icon = (ImageView) row.findViewById(R.id.iconCheck);

		if (data.get(position).isChecked()) {
			icon.setVisibility(View.VISIBLE);
		} else {
			icon.setVisibility(View.INVISIBLE);
		}

		return row;
	}
}

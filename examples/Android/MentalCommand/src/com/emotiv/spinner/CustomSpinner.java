package com.emotiv.spinner;

import android.content.Context;
import android.util.AttributeSet;
import android.util.Log;
import android.widget.Spinner;


/** Spinner extension that calls onItemSelected even when the selection is the same as its previous value */
public class CustomSpinner extends Spinner {

  public CustomSpinner(Context context)
  { super(context); }

  public CustomSpinner(Context context, AttributeSet attrs)
  { super(context, attrs); }

  public CustomSpinner(Context context, AttributeSet attrs, int defStyle)
  { super(context, attrs, defStyle); }


@Override
	public void setSelection(int position) {
		// TODO Auto-generated method stub
	    boolean sameSelected = position == getSelectedItemPosition();
	    super.setSelection(position);
	    if (sameSelected) {
	      // Spinner does not call the OnItemSelectedListener if the same item is selected, so do it manually now
	     if (this.getOnItemSelectedListener()!= null)
	        getOnItemSelectedListener().onItemSelected(null, null, position, 0);
	    }
	}
  @Override public void
  setSelection(int position, boolean animate)
  {
	 
    boolean sameSelected = position == getSelectedItemPosition();
   
    super.setSelection(position, animate);
    if (sameSelected) {
    	
      // Spinner does not call the OnItemSelectedListener if the same item is selected, so do it manually now
      getOnItemSelectedListener().onItemSelected(this, getSelectedView(), position, getSelectedItemId());
    }
  }

}

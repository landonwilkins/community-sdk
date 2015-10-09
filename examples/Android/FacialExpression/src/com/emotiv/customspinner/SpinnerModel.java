package com.emotiv.customspinner;
public class SpinnerModel {
    
    private  String textLabel="";
    private  boolean isChecked;
     
    public boolean isChecked() {
		return isChecked;
	}


	public void setChecked(boolean isChecked) {
		this.isChecked = isChecked;
	}


	/*********** Set Methods ******************/
    public void setLabel(String CompanyName)
    {
        this.textLabel = CompanyName;
    }
     

    /*********** Get Methods ****************/
    public String getLabel()
    {
        return this.textLabel;
    }
}

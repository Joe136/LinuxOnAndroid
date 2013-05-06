package org.joe136.linuxexecutor;

import android.os.Bundle;
import android.preference.PreferenceActivity;

public class MainOptionsMenu extends PreferenceActivity {

	@Override  
	protected void onCreate(Bundle savedInstanceState) {  
		super.onCreate(savedInstanceState);  
		addPreferencesFromResource(R.xml.activity_main_options);

	}  

}

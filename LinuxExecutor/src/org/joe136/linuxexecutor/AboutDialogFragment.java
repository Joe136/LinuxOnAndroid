
package org.joe136.linuxexecutor;



import android.app.AlertDialog;
import android.app.Dialog;
import android.app.DialogFragment;
import android.os.Bundle;



public class AboutDialogFragment extends DialogFragment {

   //------------------------Start Constructor-------------------------------------//
   public AboutDialogFragment () {}



   //------------------------Start onCreateDialog----------------------------------//
   @Override
   public Dialog onCreateDialog (Bundle savedInstanceState)
   {
      // Use the Builder class for convenient dialog construction
      AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
      builder.setTitle(getString(R.string.string_about) + " " + getString(R.string.app_name) )
            .setMessage(R.string.about);
      // Create the AlertDialog object and return it
      return builder.create();
   }// end Fct

}// end Class

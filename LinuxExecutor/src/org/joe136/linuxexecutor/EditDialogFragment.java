
package org.joe136.linuxexecutor;



import org.joe136.linuxexecutor.data.Distributions;
import org.joe136.linuxexecutor.data.Distributions.Distribution;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.DialogFragment;
import android.content.DialogInterface;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.EditText;



public class EditDialogFragment extends DialogFragment
{

   private class ModifyListener implements DialogInterface.OnClickListener {
      @Override
      public void onClick (DialogInterface dialog, int which)
      {
         //TODO save the distro
         AlertDialog ad = (AlertDialog)dialog;

         EditText distro_name = (EditText)ad.findViewById (R.id.distro_name);
//         if (distro_name.length() == 0)
//            //TODO

         //EditText distro_config_path = (EditText)ad.findViewById (R.id.distro_config_path);

         Distributions.addItem(new Distribution(new String (distro_name.getText().toString() ) ) );
      }//end Fct
   }//end Class
   
   
   
   
   
   private String name  = null;
   private ModifyListener ml = null;
   private boolean overwrite = false;



   //------------------------Start Constructor-------------------------------------//
   public EditDialogFragment ()
   {
      //FIXME
      ml   = new ModifyListener();
      name  = new String ("Hallo1");
//      name = new String (getActivity ().getString (R.string.string_add_distro) );
   }



   public void setArguments(String name, String title)
   {
      overwrite = true;
      this.name = name;
   }//end Constructor



   //------------------------Start onCreateDialog----------------------------------//
   @Override
   public Dialog onCreateDialog(Bundle savedInstanceState)
   {
      // Use the Builder class for convenient dialog construction
      AlertDialog.Builder builder = new AlertDialog.Builder (getActivity () );

      // Get the layout inflater
      LayoutInflater inflater = getActivity().getLayoutInflater();

      View v = inflater.inflate(R.layout.activity_edit_distribution_dialog, null);
      builder.setTitle(name)
             .setView(v)
             .setPositiveButton(R.string.string_edit_distro_OK, ml)
             .setNegativeButton(R.string.string_edit_distro_cancel,
                  new DialogInterface.OnClickListener() {
                     public void onClick (DialogInterface dialog, int id)
                     { EditDialogFragment.this.getDialog().cancel(); } } );

      if (overwrite)
      {
          ( (EditText)v.findViewById(R.id.distro_name) ).setText(name);
      }
      // Create the AlertDialog object and return it
      return builder.create();
   }//end Fct

}//end Class

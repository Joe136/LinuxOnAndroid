package org.joe136.linuxexecutor;

import android.app.DialogFragment;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.NavUtils;
import android.view.MenuInflater;
import android.view.MenuItem;

/**
 * An activity representing a single Distribution detail screen. This activity
 * is only used on handset devices. On tablet-size devices, item details are
 * presented side-by-side with a list of items in a
 * {@link DistributionListActivity}.
 * <p>
 * This activity is mostly just a 'shell' activity containing nothing more than
 * a {@link DistributionDetailFragment}.
 */
public class DistributionDetailActivity extends FragmentActivity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_distribution_detail);

		

		// Show the Up button in the action bar.
		getActionBar().setDisplayHomeAsUpEnabled(true);

		// savedInstanceState is non-null when there is fragment state
		// saved from previous configurations of this activity
		// (e.g. when rotating the screen from portrait to landscape).
		// In this case, the fragment will automatically be re-added
		// to its container so we don't need to manually add it.
		// For more information, see the Fragments API guide at:
		//
		// http://developer.android.com/guide/components/fragments.html
		//
		if (savedInstanceState == null) {
			// Create the detail fragment and add it to the activity
			// using a fragment transaction.
			Bundle arguments = new Bundle();
			arguments.putString(
					DistributionDetailFragment.ARG_ITEM_ID,
					getIntent().getStringExtra(
							DistributionDetailFragment.ARG_ITEM_ID));
			DistributionDetailFragment fragment = new DistributionDetailFragment();
			fragment.setArguments(arguments);
			getSupportFragmentManager().beginTransaction()
					.add(R.id.distribution_detail_container, fragment).commit();
		}
	}



	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case android.R.id.home:
			// This ID represents the Home or Up button. In the case of this
			// activity, the Up button is shown. Use NavUtils to allow users
			// to navigate up one level in the application structure. For
			// more details, see the Navigation pattern on Android Design:
			//
			// http://developer.android.com/design/patterns/navigation.html#up-vs-back
			//
			NavUtils.navigateUpTo(this, new Intent(this,
					DistributionListActivity.class));
			return true;
      case R.id.edit_distro_menu_button:
         EditDialogFragment dialog2 = new EditDialogFragment ();
         //dialog2.setArguments(name, title);
         //TODO: Set the values of the Dialog
         dialog2.show (getFragmentManager(), "DistributionDetailFragment");
         break;
		}
		return super.onOptionsItemSelected(item);
	}



	@Override  
    public boolean onCreateOptionsMenu(android.view.Menu menu) {  
        // TODO Auto-generated method stub  
        super.onCreateOptionsMenu(menu);  
        MenuInflater menuInflater = getMenuInflater();  
        menuInflater.inflate(R.menu.activity_distribution_menu, menu);  
        return true;  
    }  

}

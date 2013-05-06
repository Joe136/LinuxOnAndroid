package org.joe136.linuxexecutor;

import android.app.DialogFragment;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.view.MenuInflater;
import android.view.MenuItem;

/**
 * An activity representing a list of Distributions. This activity has different
 * presentations for handset and tablet-size devices. On handsets, the activity
 * presents a list of items, which when touched, lead to a
 * {@link DistributionDetailActivity} representing item details. On tablets, the
 * activity presents the list of items and item details side-by-side using two
 * vertical panes.
 * <p>
 * The activity makes heavy use of fragments. The list of items is a
 * {@link DistributionListFragment} and the item details (if present) is a
 * {@link DistributionDetailFragment}.
 * <p>
 * This activity also implements the required
 * {@link DistributionListFragment.Callbacks} interface to listen for item
 * selections.
 */
public class DistributionListActivity extends FragmentActivity implements
		DistributionListFragment.Callbacks {

	/**
	 * Whether or not the activity is in two-pane mode, i.e. running on a tablet
	 * device.
	 */
	private boolean mTwoPane;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_distribution_list);

		if (findViewById(R.id.distribution_detail_container) != null) {
			// The detail container view will be present only in the
			// large-screen layouts (res/values-large and
			// res/values-sw600dp). If this view is present, then the
			// activity should be in two-pane mode.
			mTwoPane = true;

			// In two-pane mode, list items should be given the
			// 'activated' state when touched.
			((DistributionListFragment) getSupportFragmentManager()
					.findFragmentById(R.id.distribution_list))
					.setActivateOnItemClick(true);
		}

		// TODO: If exposing deep links into your app, handle intents here.
	}

	/**
	 * Callback method from {@link DistributionListFragment.Callbacks}
	 * indicating that the item with the given ID was selected.
	 */
	@Override
	public void onItemSelected(Integer id) {
		if (mTwoPane) {
			// In two-pane mode, show the detail view in this activity by
			// adding or replacing the detail fragment using a
			// fragment transaction.
			Bundle arguments = new Bundle();
			arguments.putInt(DistributionDetailFragment.ARG_ITEM_ID, id);
			DistributionDetailFragment fragment = new DistributionDetailFragment();
			fragment.setArguments(arguments);
			getSupportFragmentManager().beginTransaction()
					.replace(R.id.distribution_detail_container, fragment)
					.commit();

		} else {
			// In single-pane mode, simply start the detail activity
			// for the selected item ID.
			Intent detailIntent = new Intent(this,
					DistributionDetailActivity.class);
			detailIntent.putExtra(DistributionDetailFragment.ARG_ITEM_ID, id);
			startActivity(detailIntent);
		}
	}



	@Override  
    public boolean onCreateOptionsMenu(android.view.Menu menu) {  
        // TODO Auto-generated method stub  
        super.onCreateOptionsMenu(menu);  
        MenuInflater menuInflater = getMenuInflater();  
        menuInflater.inflate(R.menu.activity_distributions_menu, menu);  
        return true;  
    }



	@Override  
	public boolean onOptionsItemSelected(MenuItem item) {
		switch(item.getItemId()){
		case R.id.add_distro_menu_button:
			DialogFragment dialog1 = new EditDialogFragment ();
			dialog1.show (getFragmentManager(), "DistributionListFragment");
			break;
		case R.id.about_menu_button:
			DialogFragment dialog3 = new AboutDialogFragment ();
			dialog3.show (getFragmentManager(), "DistributionListFragment");
			break;
		case R.id.options_menu_button:
			Intent intent3 = new Intent(DistributionListActivity.this, MainOptionsMenu.class);
			startActivity(intent3);
			break;
		case R.id.exit_menu_button:
			finish();
			break;
		}
		return false;
	}

}

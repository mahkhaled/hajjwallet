package com.hajjwallet.www.hajjwallet;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.constraint.ConstraintLayout;
import android.support.design.widget.BottomNavigationView;
import android.view.MenuItem;
import android.widget.FrameLayout;

import com.hajjwallet.www.hajjwallet.base.BaseActivity;
import com.hajjwallet.www.hajjwallet.fragments.HomeFragment;
import com.hajjwallet.www.hajjwallet.fragments.OffersFragment;
import com.hajjwallet.www.hajjwallet.fragments.ShopFragment;

import butterknife.BindView;
import butterknife.ButterKnife;

public class MainActivity extends BaseActivity {


    @BindView(R.id.navigation)
    BottomNavigationView navigation;
    @BindView(R.id.container)
    ConstraintLayout container;
    @BindView(R.id.content)
    FrameLayout content;
    private BottomNavigationView.OnNavigationItemSelectedListener mOnNavigationItemSelectedListener
            = new BottomNavigationView.OnNavigationItemSelectedListener() {

        @Override
        public boolean onNavigationItemSelected(@NonNull MenuItem item) {
            switch (item.getItemId()) {
                case R.id.navigation_home:
                    getFragmentManager().beginTransaction().replace(R.id.content, ShopFragment.newInstance()).commit();
                    return true;
                case R.id.navigation_dashboard:
                    getFragmentManager().beginTransaction().replace(R.id.content, HomeFragment.newInstance()).commit();
                    return true;
                case R.id.navigation_notifications:
                    getFragmentManager().beginTransaction().replace(R.id.content, OffersFragment.newInstance()).commit();
                    return true;
            }
            return false;
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        ButterKnife.bind(this);


        BottomNavigationView navigation = (BottomNavigationView) findViewById(R.id.navigation);
        navigation.setOnNavigationItemSelectedListener(mOnNavigationItemSelectedListener);
    }

}

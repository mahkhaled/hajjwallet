package com.hajjwallet.www.hajjwallet;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.hajjwallet.www.hajjwallet.R;
import com.hajjwallet.www.hajjwallet.adapters.OrdersAdapter;
import com.hajjwallet.www.hajjwallet.base.BaseActivity;
import com.hajjwallet.www.hajjwallet.base.BaseFragment;

public class OrderDetailsActivity extends BaseActivity {
    OrdersAdapter ordersAdapter;


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.fragment_order_details);


    }
}

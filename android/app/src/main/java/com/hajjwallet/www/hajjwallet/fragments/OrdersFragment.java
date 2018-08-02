package com.hajjwallet.www.hajjwallet.fragments;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.hajjwallet.www.hajjwallet.adapters.OrdersAdapter;
import com.hajjwallet.www.hajjwallet.R;
import com.hajjwallet.www.hajjwallet.base.BaseFragment;

public class OrdersFragment extends BaseFragment {
    OrdersAdapter ordersAdapter;

    public static OrdersFragment newInstance() {

        Bundle args = new Bundle();

        OrdersFragment fragment = new OrdersFragment();
        fragment.setArguments(args);
        return fragment;
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_orders, container, false);
        ordersAdapter = new OrdersAdapter();
        return view;

    }

}

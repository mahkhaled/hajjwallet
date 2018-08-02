package com.hajjwallet.www.hajjwallet.fragments;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.hajjwallet.www.hajjwallet.adapters.OrdersAdapter;
import com.hajjwallet.www.hajjwallet.R;
import com.hajjwallet.www.hajjwallet.base.BaseFragment;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.Unbinder;

public class ActiveOrdersFragment extends BaseFragment {
    OrdersAdapter ordersAdapter;
    @BindView(R.id.rv_orders)
    RecyclerView rvOrders;
    Unbinder unbinder;

    public static ActiveOrdersFragment newInstance() {

        Bundle args = new Bundle();

        ActiveOrdersFragment fragment = new ActiveOrdersFragment();
        fragment.setArguments(args);
        return fragment;
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_acrtive_orders, container, false);
        ordersAdapter = new OrdersAdapter();
        unbinder = ButterKnife.bind(this, view);
        rvOrders.setLayoutManager(new LinearLayoutManager(getActivity()));
        rvOrders.setAdapter(ordersAdapter);
        return view;

    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        unbinder.unbind();
    }
}

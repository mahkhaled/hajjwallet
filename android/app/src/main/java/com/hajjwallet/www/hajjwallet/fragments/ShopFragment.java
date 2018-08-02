package com.hajjwallet.www.hajjwallet.fragments;

import android.app.Fragment;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;

import com.hajjwallet.www.hajjwallet.base.BaseFragment;

public class ShopFragment extends BaseFragment {
    public static ShopFragment newInstance() {
        
        Bundle args = new Bundle();
        
        ShopFragment fragment = new ShopFragment();
        fragment.setArguments(args);
        return fragment;
    }
}

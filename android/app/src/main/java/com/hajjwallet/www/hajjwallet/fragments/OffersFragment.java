package com.hajjwallet.www.hajjwallet.fragments;

import android.os.Bundle;

import com.hajjwallet.www.hajjwallet.base.BaseFragment;

public class OffersFragment extends BaseFragment {
    public static OffersFragment newInstance() {
        
        Bundle args = new Bundle();
        
        OffersFragment fragment = new OffersFragment();
        fragment.setArguments(args);
        return fragment;
    }
}

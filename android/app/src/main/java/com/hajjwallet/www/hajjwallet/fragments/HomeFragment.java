package com.hajjwallet.www.hajjwallet.fragments;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.hajjwallet.www.hajjwallet.KeypadActivity;
import com.hajjwallet.www.hajjwallet.R;
import com.hajjwallet.www.hajjwallet.base.BaseFragment;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.Unbinder;

public class HomeFragment extends BaseFragment {

    Unbinder unbinder;

    @BindView(R.id.iv_qrcode)
    ImageView qrCode;
    @BindView(R.id.share_qr_code)
    TextView shareQrCode;

    //TODO generate qr code
    String walletQrCode = "R842718960";

    public static HomeFragment newInstance() {

        Bundle args = new Bundle();

        HomeFragment fragment = new HomeFragment();
        fragment.setArguments(args);
        return fragment;
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_home, container, false);
        unbinder = ButterKnife.bind(this, view);
        shareQrCode.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                shareQrCode();
            }
        });
        qrCode.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                getActivity().startActivity(new Intent(getActivity(), KeypadActivity.class));
            }
        });
        return view;

    }

    void shareQrCode() {
        Intent sendIntent = new Intent();
        sendIntent.setAction(Intent.ACTION_SEND);
        sendIntent.putExtra(Intent.EXTRA_TEXT, walletQrCode);
        sendIntent.setType("text/plain");
        startActivity(sendIntent);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        unbinder.unbind();
    }
}

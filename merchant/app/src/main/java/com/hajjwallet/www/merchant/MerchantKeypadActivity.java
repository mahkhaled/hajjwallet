package com.hajjwallet.www.merchant;

import android.app.Activity;
import android.os.Bundle;
import android.support.annotation.Nullable;

public class MerchantKeypadActivity extends Activity {
    public static final String KEY_QR_CODE = "KEY_QR_CODE";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_keypad);
    }
}

package com.hajjwallet.www.hajjwallet;

import android.content.Context;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.View;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.hajjwallet.www.hajjwallet.base.BaseActivity;

import butterknife.BindView;
import butterknife.ButterKnife;

public class KeypadActivity extends BaseActivity {
    @BindView(R.id.password)
    EditText password;
    @BindView(R.id.button)
    Button button;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_keypad);
        ButterKnife.bind(this);
        showSoftKeyboard(password);
        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (password.getText().length() < 4) {
                    Toast.makeText(KeypadActivity.this, "please enter pin code (4 numbers)", Toast.LENGTH_LONG).show();

                    return;
                }
                Toast.makeText(KeypadActivity.this, "Success", Toast.LENGTH_LONG).show();
                finish();
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
        showSoftKeyboard(password);
    }

    public void showSoftKeyboard(View view) {
        InputMethodManager inputMethodManager = (InputMethodManager) view.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        view.requestFocus();
        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_VISIBLE);
        inputMethodManager.showSoftInput(view, 0);
    }
}

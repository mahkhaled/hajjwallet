package com.hajjwallet.www.hajjwallet;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.Nullable;
import android.widget.ImageView;

import com.squareup.picasso.Picasso;

import butterknife.BindView;
import butterknife.ButterKnife;

public class SplashScreenActivity extends Activity {
    @BindView(R.id.imageView)
    ImageView splashImageView;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);
        ButterKnife.bind(this);
        Picasso.get().load(R.drawable.splash).into(splashImageView);
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                // navigate to next screen
                Intent intent = new Intent(SplashScreenActivity.this, MainActivity.class);
                startActivity(intent);
                finish();
            }
        }, 3000);
    }
}

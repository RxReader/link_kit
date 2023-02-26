package io.github.v7lin.link_kit;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public class LinkCallbackActivity extends Activity {
    private static final String KEY_LINK_CALLBACK = "link_callback";
    private static final String KEY_LINK_EXTRA = "link_extra";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        handleIntent(getIntent());
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        handleIntent(intent);
    }

    private void handleIntent(Intent intent) {
        final Intent launchIntent = getPackageManager().getLaunchIntentForPackage(getPackageName());
        launchIntent.putExtra(KEY_LINK_CALLBACK, true);
        launchIntent.putExtra(KEY_LINK_EXTRA, intent);
//        launchIntent.setPackage(getPackageName());
        launchIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        startActivity(launchIntent);
        finish();
    }

    public static Intent extraCallback(@NonNull Intent intent) {
        if (intent.getExtras() != null && intent.getBooleanExtra(KEY_LINK_CALLBACK, false)) {
            final Intent extra = intent.getParcelableExtra(KEY_LINK_EXTRA);
            return extra;
        }
        return null;
    }
}

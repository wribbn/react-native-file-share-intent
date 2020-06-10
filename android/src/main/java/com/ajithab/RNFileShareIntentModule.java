
package com.ajithab;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

import com.ajithab.RNFileShareIntentPackage;

import java.util.Map;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Set;

import android.widget.Toast;
import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;


public class RNFileShareIntentModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;

  public RNFileShareIntentModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }


  protected void onNewIntent(Intent intent) {
    Activity mActivity = getCurrentActivity();

    if(mActivity == null) { return; }

    mActivity.setIntent(intent);
  }

  @ReactMethod
  public void close() {
    getCurrentActivity().finish();
  }

  @ReactMethod
  public void data(Promise promise) {
    promise.resolve(processIntent());
  }

  protected WritableMap processIntent() {

      Activity currentActivity = getCurrentActivity();

      WritableMap map = Arguments.createMap();

      Intent intent = currentActivity.getIntent();
      String text = null;

      // DEBUG: Uncomment to access a concatted list of intent extras in `str`
      // Bundle bundle = intent.getExtras();
      // StringBuilder str = new StringBuilder();
      //
      // if (bundle != null) {
      //     Set<String> keys = bundle.keySet();
      //     Iterator<String> it = keys.iterator();
      //     while (it.hasNext()) {
      //         String key = it.next();
      //         str.append(key);
      //         str.append(":");
      //         str.append(bundle.get(key));
      //         str.append("\n\r");
      //     }
      // }

      text = intent.getStringExtra(Intent.EXTRA_TEXT);

      map.putString("text", text);

      return map;
  }

  @ReactMethod
  public void clearFilePath() {
    Activity mActivity = getCurrentActivity();

    if(mActivity == null) { return; }

    Intent intent = mActivity.getIntent();
    String type = intent.getType();
    if ("text/plain".equals(type)) {
      intent.removeExtra(Intent.EXTRA_TEXT);
    } else if (type.startsWith("image/") || type.startsWith("video/") || type.startsWith("application/")) {
      intent.removeExtra(Intent.EXTRA_STREAM);
    }
  }
  @Override
  public String getName() {
    return "RNFileShareIntent";
  }
}


package com.ajithab;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableArray;
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

// Pulled from react-native-recieve-sharing-intent
import android.annotation.SuppressLint;
import android.content.ContentUris;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.DocumentsContract;
import android.provider.MediaStore;

import java.io.File;
import android.graphics.BitmapFactory;
import android.graphics.Bitmap;
import android.support.v4.app.ActivityCompat;
import android.Manifest;
import java.io.InputStream;
import android.util.Base64;
import java.io.IOException;
import java.io.FileNotFoundException;
import java.io.FileInputStream;
import java.io.ByteArrayOutputStream;

public class RNFileShareIntentModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;

  private static final int PERMISSION_REQUEST_CODE = 1;

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

  @ReactMethod
  public void getBase64Android (String filePath, Promise promise) {
    promise.resolve(getBase64(filePath));
  }

  private static Bitmap resize(Bitmap image, int maxWidth, int maxHeight) {
    if (maxHeight > 0 && maxWidth > 0) {
        int width = image.getWidth();
        int height = image.getHeight();
        float ratioBitmap = (float) width / (float) height;
        float ratioMax = (float) maxWidth / (float) maxHeight;

        int finalWidth = maxWidth;
        int finalHeight = maxHeight;
        if (ratioMax > ratioBitmap) {
            finalWidth = (int) ((float)maxHeight * ratioBitmap);
        } else {
            finalHeight = (int) ((float)maxWidth / ratioBitmap);
        }
        image = Bitmap.createScaledBitmap(image, finalWidth, finalHeight, true);
        return image;
    } else {
        return image;
    }
  }

  public WritableMap getBase64(String filePath) {
    WritableMap response = Arguments.createMap();
    File file = new File(filePath);
    ByteArrayOutputStream outputStream = new ByteArrayOutputStream();

    BitmapFactory.Options options = new BitmapFactory.Options();
    options.inJustDecodeBounds = false;

    Bitmap bitmap = BitmapFactory.decodeFile(file.getAbsolutePath(), options);
    Bitmap scaled = resize(bitmap, 900, 900);

    scaled.compress(Bitmap.CompressFormat.JPEG, 60, outputStream);

    byte [] bytes = outputStream.toByteArray();
    String src = Base64.encodeToString(bytes, Base64.DEFAULT);

    response.putString("src", src);
    response.putInt("width", bitmap.getWidth());
    response.putInt("height", bitmap.getHeight());

    return response;
  }

  private byte[] getByte(String path) {
   byte[] getBytes = {};
   try {
       File file = new File(path);
       getBytes = new byte[(int) file.length()];
       InputStream is = new FileInputStream(file);
       is.read(getBytes);
       is.close();
   } catch (FileNotFoundException e) {
       e.printStackTrace();
   } catch (IOException e) {
       e.printStackTrace();
   }
   return getBytes;
 }

  protected WritableMap processIntent() {
    Activity currentActivity = getCurrentActivity();
    Intent intent = currentActivity.getIntent();
    Bundle bundle = intent.getExtras();

    WritableMap response = Arguments.createMap();
    WritableArray images = Arguments.createArray();

    if (bundle != null) {
      Set<String> keys = bundle.keySet();
      Iterator<String> it = keys.iterator();

      while (it.hasNext()) {
        String key = it.next();

        if (key.equals(Intent.EXTRA_TEXT)) {
          String text = bundle.get(key).toString();

          response.putString("text", text);
        }

        if (key.equals(Intent.EXTRA_STREAM)) {
          ActivityCompat.requestPermissions(currentActivity, new String[]{Manifest.permission.READ_EXTERNAL_STORAGE}, PERMISSION_REQUEST_CODE);

          Uri uri = intent.getParcelableExtra(Intent.EXTRA_STREAM);
          WritableMap image = Arguments.createMap();
          String filePath = getFilePath(this.reactContext, uri);
          File file = new File(filePath);

          BitmapFactory.Options options = new BitmapFactory.Options();
          options.inJustDecodeBounds = false;

          Bitmap bitmap = BitmapFactory.decodeFile(file.getAbsolutePath(), options);

          if (bitmap != null) {
            image.putString("filePath", filePath);
            image.putString("contentStreamUri", uri.toString());
            image.putInt("width", bitmap.getWidth());
            image.putInt("height", bitmap.getHeight());

            images.pushMap(image);
          }
        }
      }
    }

    if (images.size() != 0) {
      response.putArray("images", images);
    }

    return response;
  }

  public static String getFilePath(Context context, Uri uri) {
    String selection = null;
    String[] selectionArgs = null;
    // Uri is different in versions after KITKAT (Android 4.4), we need to
    if (Build.VERSION.SDK_INT >= 19 && DocumentsContract.isDocumentUri(context.getApplicationContext(), uri)) {
        if (isExternalStorageDocument(uri)) {
            final String docId = DocumentsContract.getDocumentId(uri);
            final String[] split = docId.split(":");
            return Environment.getExternalStorageDirectory() + "/" + split[1];
        } else if (isDownloadsDocument(uri)) {
            final String id = DocumentsContract.getDocumentId(uri);
            uri = ContentUris.withAppendedId(
                    Uri.parse("content://downloads/public_downloads"), Long.valueOf(id));
        } else if (isMediaDocument(uri)) {
            final String docId = DocumentsContract.getDocumentId(uri);
            final String[] split = docId.split(":");
            final String type = split[0];
            if ("image".equals(type)) {
                uri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
            } else if ("video".equals(type)) {
                uri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI;
            } else if ("audio".equals(type)) {
                uri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;
            }
            selection = "_id=?";
            selectionArgs = new String[]{
                    split[1]
            };
        }
    }
    if ("content".equalsIgnoreCase(uri.getScheme())) {


        if (isGooglePhotosUri(uri)) {
            return uri.getLastPathSegment();
        }

        String[] projection = {
                MediaStore.Images.Media.DATA
        };
        Cursor cursor = null;
        try {
            cursor = context.getContentResolver()
                    .query(uri, projection, selection, selectionArgs, null);
            int column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
            if (cursor.moveToFirst()) {
                return cursor.getString(column_index);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    } else if ("file".equalsIgnoreCase(uri.getScheme())) {
        return uri.getPath();
    }
    return null;
  }

  public static boolean isExternalStorageDocument(Uri uri) {
      return "com.android.externalstorage.documents".equals(uri.getAuthority());
  }

  public static boolean isDownloadsDocument(Uri uri) {
      return "com.android.providers.downloads.documents".equals(uri.getAuthority());
  }

  public static boolean isMediaDocument(Uri uri) {
      return "com.android.providers.media.documents".equals(uri.getAuthority());
  }

  public static boolean isGooglePhotosUri(Uri uri) {
      return "com.google.android.apps.photos.content".equals(uri.getAuthority());
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

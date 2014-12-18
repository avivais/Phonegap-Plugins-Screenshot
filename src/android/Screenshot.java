package mobi.fabula.cordova.screenshot;

import java.io.ByteArrayOutputStream;
import java.io.File;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONException;

import android.graphics.Bitmap;
import android.os.Environment;
import android.view.View;
import android.util.Base64;
import android.util.Log;

public class Screenshot extends CordovaPlugin {
	@Override
	public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {
		if (action.equals("saveScreenshot")) {
			super.cordova.getActivity().runOnUiThread(new Runnable() {
				@Override
				public void run() {
					View view = webView.getRootView();
					view.setDrawingCacheEnabled(true);
					Bitmap bitmap = Bitmap.createBitmap(view.getDrawingCache());
					view.setDrawingCacheEnabled(false);
					File folder = new File(Environment.getExternalStorageDirectory(), "Pictures");
					if (!folder.exists()) {
						folder.mkdirs();
					}
					//File f = new File(folder, "screenshot_" + System.currentTimeMillis() + "."+format);
					//FileOutputStream fos = new FileOutputStream(f);
					//bitmap.compress(Bitmap.CompressFormat.JPEG, 100, fos);

					ByteArrayOutputStream baos = new ByteArrayOutputStream();
					bitmap.compress(Bitmap.CompressFormat.JPEG, 100, baos);
	                byte[] b = baos.toByteArray();
	                String base64String = Base64.encodeToString(b, Base64.DEFAULT);
                    PluginResult result = new PluginResult(PluginResult.Status.OK, base64String);
                    callbackContext.sendPluginResult(result);
				}
			});
			return true;
		}
		callbackContext.error("action not found");
		return false;	
	}
}
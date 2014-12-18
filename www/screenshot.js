var exec = require('cordova/exec');
var pluginNativeName = "Screenshot";
           
var ScreenshotPlugin = function () {
};

ScreenshotPlugin.prototype = {
	getBase64ScreenShot: function( successCallback, errorCallback ) {
		exec(successCallback,errorCallback,pluginNativeName,'saveScreenshot',[]);
	}
};
           
module.exports = new ScreenshotPlugin();
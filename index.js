var gutil   = require("gulp-util");
var through = require("through2");
var markdox = require("markdox");

gulpError = function(message) {
	return new gutil.PluginError('gulp-markdox', message)
}

module.exports = function (options) {
	"use strict";

  if (!options || typeof options !== 'object') {
    options = {};
  }

	function gulpMarkdox(file, enc, callback) {
		var self = this;
		/*jshint validthis:true*/

		// Do nothing if no contents
		if (file.isNull()) {
			this.push(file);
			return callback();
		}

		// accepting streams is optional
		if (file.isStream()) {
			this.emit("error", gulpError("Streams are not supported"));
			return callback();
		}

		// we only support buffers
		if (file.isBuffer()) {
			markdox.process(file.path, options, function(err, result) {
				if (err) {
					self.emit("error", gulpError(err));
					return callback();
				}
				file.contents = new Buffer(result);
				self.push(file);
				return callback();
			});
		}
	}

	return through.obj(gulpMarkdox);
};

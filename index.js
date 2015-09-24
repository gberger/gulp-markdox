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

	var paths = [];
	var base = '';

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

		if (typeof options.concat === 'string') {
			paths.push(file.path);
			base = file.base;
			return callback();
		}

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

	function concat(callback) {
		var self = this;
		/*jshint validthis:true*/

		if (paths.length === 0) {
			return callback();
		}

		markdox.process(paths, options, function(err, result) {
			if (err) {
				this.emit("error", gulpError(err));
				return callback();
			}
			var file = new gutil.File({ path: base +'/'+ options.concat, });
			file.contents = new Buffer(result);
			self.push(file);
			return callback();
		});
	}

	return through.obj(gulpMarkdox, concat);
};

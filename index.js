// license: MIT
'use strict';

var gutil = require('gulp-util');
var through = require('through2');
var markdox = require('markdox');
var path = require('path');
var async = require('async');
var _ = require('underscore');

module.exports = function(options) {
  var stream = gutil.noop();

  var output = [];
  var afterRender = stream
    .pipe(module.exports.parse(options))
    .pipe(module.exports.format())
    .pipe(module.exports.render())
    .pipe(through.obj(function(chunk, enc, callback) {
      output.push(chunk);
      return callback();
    }));

  function write(chunk, enc, callback) {
    return stream.write(chunk, enc, callback);
  }

  function flush(callback) {
    var self = this;
    afterRender.on('finish', function(err) {
      output.forEach(self.push.bind(self));
      callback(err)
    });
    stream.end();
  }

  var retVal = through.obj(write, flush);
  return retVal;
};

_.extend(module.exports, {
  parse: stream(requireBuffer(parse), noop),
  format: stream(requireProperty('javadoc', format), noop),
  render: stream(requireProperty('formattedDoc', maybeConcat), render, createArray('chunks')),
});

function parse(self, options, chunk, callback) {
  chunk.path = path.relative(process.cwd(), chunk.path);
  chunk.cwd = process.cwd();

  markdox.parse(chunk.path, options, function(err, doc) {
    if (err) {
      self.emit('error', gulpError(err));
      return callback();
    }

    chunk.javadoc = doc;
    self.push(chunk);
    return callback();
  });
}

function format(self, options, chunk, callback) {
  try {
    chunk.formattedDoc = options.formatter({
      filename: chunk.path,
      javadoc: chunk.javadoc,
      options: options,
    });
    if (!chunk.formattedDoc) {
      self.emit('error', gulpError('No document returned from formatter: '+ chunk.formatterDoc));
    }
    self.push(chunk);
    return callback();

  } catch(e) {
    self.emit('error', gulpError(e));
    return callback(e);
  }
}

function maybeConcat(self, options, chunk, callback) {
  var path = chunk.path;
  if (typeof options.concat === 'string') {
    path = options.concat;
  }

  var chunks = self.chunks;
  (chunks[path] = chunks[path] || []).push(chunk);
  return callback();
}

function render(self, callback) {
  // intermediate map used to assure
  // the same order of chunks after async processing
  var rendered = {};
  var length = 0;

  async.each(_.keys(self.chunks), render0, flush);

  function render0(outputPath, cb) {
    var input = self.chunks[outputPath];
    var inputDocs = input.map(function(file) { return file.formattedDoc; });
    var options = input[0].markdoxOptions;

    var index = length++;

    markdox.generate(inputDocs, options, function(err, result) {
      if (err) {
        self.emit('error', gulpError(err));
        return cb(err);
      }
      var file = new gutil.File({ path: outputPath });
      file.contents = new Buffer(result);
      rendered[index] = file;
      return cb();
    });
  }

  function flush(err) {
    _.keys(rendered)
      .sort(function(a, b) { return a > b; })
      .map(function(index) { return rendered[index]; })
      .forEach(function(file) { self.push(file); })
    ;
    callback(err);
  }
}

function noop(self, callback) {
  return callback();
}

function stream(transform, flush) {
  var initializers = [].slice.call(arguments, 2);

  return function(options) {
    function transformDecorator(chunk, enc, callback) {
      chunk.markdoxOptions = _.defaults(options || chunk.markdoxOptions || {}, {
        output: false,
        encoding: enc,
        formatter: markdox.defaultFormatter,
      });
      if (chunk.isNull()) {
        this.push(chunk);
        return callback();
      }
      return transform(this, chunk.markdoxOptions, chunk, callback);
    }

    function flushDecorator(callback) {
      return flush(this, callback);
    }

    var retVal = through.obj(transformDecorator, flushDecorator);
    initializers.forEach(function(init) { init(retVal); });
    return retVal;
  };
}

function requireBuffer(chunkHandler) {
  return function(self, options, chunk, callback) {
    if (chunk.isStream()) {
      self.emit('error', gulpError('Streams are not supported'));
      return callback();
    }

    return chunkHandler(self, options, chunk, callback);
  };
}

function requireProperty(propertyName, chunkHandler) {
  return function(self, options, chunk, callback) {
    if (typeof chunk[propertyName] === 'undefined') {
      self.emit('error', gulpError('Couldn\'t find property on data chunk: "'+ propertyName +'"'));
      return callback();
    }

    return chunkHandler(self, options, chunk, callback);
  };
}

function createArray(propertyName) {
  return function(self) {
    self[propertyName] = [];
  };
}

function gulpError(message) {
  return new gutil.PluginError('gulp-markdox', message);
}


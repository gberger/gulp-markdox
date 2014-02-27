# gulp-markdox
[![NPM version][npm-image]][npm-url] [![Build Status][travis-image]][travis-url]

> [markdox](https://github.com/cbou/markdox) plugin for [gulp](https://github.com/wearefractal/gulp)

Markdox is a documentation generator based on Dox and Markdown with support for JavaScript, CoffeeScript and IcedCoffeeScript.

This plugin is a `gulp` wrapper for it.

## Usage

First, install `gulp-markdox` as a development dependency:

```shell
npm install --save-dev gulp-markdox
```

Then, add it to your `gulpfile.js`:

```javascript
var markdox = require("gulp-markdox");

gulp.task("doc", function(){
  gulp.src("./src/*.js")
    .pipe(markdox())
    .pipe(gulp.dest("./doc"));
});
```

It can take on `.coffee` and `.iced` files, too.

If you want to concatenate all your generated documentation files, use [gulp-concat](https://github.com/wearefractal/gulp-concat):

```javascript
var markdox = require("gulp-markdox");
var concat = require("gulp-concat");

gulp.task("doc", function(){
  gulp.src("./src/*.js")
    .pipe(markdox())
    .pipe(concat("doc.md"))
    .pipe(gulp.dest("./doc"));
});
```

## API

Please refer to [markdox's documentation](https://github.com/cbou/markdox) for further documentation of these options.x'

### markdox(options)

#### options.template
Type: `String`  

Path or the custom template

#### options.encoding
Type: `String`  
Default: `utf-8`

Encoding of templates and files to parse

#### options.formatter
Type: `Function`

Custom formatter

#### options.compiler
Type: `Function`

Custom compiler


## License

[MIT License](http://en.wikipedia.org/wiki/MIT_License)

[npm-url]: https://npmjs.org/package/gulp-markdox
[npm-image]: https://badge.fury.io/js/gulp-markdox.png

[travis-url]: http://travis-ci.org/gberger/gulp-markdox
[travis-image]: https://secure.travis-ci.org/gberger/gulp-markdox.png?branch=master

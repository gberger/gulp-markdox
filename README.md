[npm-url]: https://npmjs.org/package/gulp-markdox2
[npm-image]: https://badge.fury.io/js/gulp-markdox2.png

[travis-url]: http://travis-ci.org/webfront-toolkit/gulp-markdox2
[travis-image]: https://secure.travis-ci.org/webfront-toolkit/gulp-markdox2.png?branch=master

[david-url]: https://david-dm.org/webfront-toolkit/gulp-markdox2
[david-image]: https://david-dm.org/webfront-toolkit/gulp-markdox2.svg

[david-url-dev]: https://david-dm.org/webfront-toolkit/gulp-markdox2#info=devDependencies
[david-image-dev]: https://david-dm.org/webfront-toolkit/gulp-markdox2/dev-status.svg

# gulp-markdox2

[![NPM version][npm-image]][npm-url]
[![Build Status][travis-image]][travis-url]
[![Dependency Status][david-image]][david-url]
[![devDependency Status][david-image-dev]][david-url-dev]

Markdo a documentation generator based on Dox and Markdown with support for JavaScript,
CoffeeScrip IcedCoffeeScript.

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

If you want to concatenate all your generated documentation files, use `concat` option.
All parsed docfiles will be passed to templateat once:

```javascript
var markdox = require("gulp-markdox");

gulp.task("doc", function(){
  gulp.src("./src/*.js")
    .pipe(markdox({ concat: "doc.md" })
    .pipe(gulp.dest("./doc"));
});
```

Following example does the same in more fine-grained manner:

```javascript
var markdox = require("gulp-markdox");

gulp.task("doc", function(){
  gulp.src("./src/*.js")
    .pipe(markdox.parse())
    .pipe(markdox.format())
    .pipe(markdox.render({ concat: "doc.md" }))
    .pipe(gulp.dest("./doc"));
});
```

## API
Please refer to [markdox's documentation](https://github.com/cbou/markdox) for further documentation of these options.x'.

### markdox(options)
Generates markdox documentation from source code in the input.

#### options.compiler
Type: `Function`

Custom compiler (user in parse phase).

#### options.encoding
Type: `String`
Default: `utf-8`

Encoding of templates and files to parse (used in parse phase).

#### options.formatter
Type: `Function`

Custom formatter (used in format phase).

#### options.concat
Type: `String`

File name for concatenated docfile.

#### options.template
Type: `String`

Path or the custom template (used in render phase).

### markdox.parse(options)
Input: commented source code in file `contents`.

Output: raw document object generated from comments assigned to `javadoc` property.

### markdox.format(options)
Input: raw document object generated from comments assigned to `javadoc` property.

Output: formatted document object assigned to `formattedDoc` property.

### markdox.render(options)
Input: formatted document object assigned to `formattedDoc` property.

Output: rendered documentation in file `contents`.

## License

[MIT License](http://en.wikipedia.org/wiki/MIT_License)


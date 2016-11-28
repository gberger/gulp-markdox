[npm-url]: https://npmjs.org/package/gulp-markdox2
[npm-image]: https://img.shields.io/npm/v/gulp-markdox2.svg?maxAge=2592000

[travis-url]: http://travis-ci.org/muroc/gulp-markdox2
[travis-image]: https://img.shields.io/travis/muroc/gulp-markdox2.svg?maxAge=2592000

[david-url]: https://david-dm.org/muroc/gulp-markdox2
[david-image]: https://david-dm.org/muroc/gulp-markdox2.svg

[david-url-dev]: https://david-dm.org/muroc/gulp-markdox2?type=dev
[david-image-dev]: https://david-dm.org/muroc/gulp-markdox2/dev-status.svg

[license-url]: LICENSE
[license-image]: https://img.shields.io/github/license/muroc/gulp-markdox2.svg?maxAge=2592000

# gulp-markdox2

[![NPM version][npm-image]][npm-url]
[![Build Status][travis-image]][travis-url]
[![Dependency Status][david-image]][david-url]
[![devDependency Status][david-image-dev]][david-url-dev]
[![License][license-image]][license-url]

[Markdox][markdox] is a structured documentation generator based on [Dox][dox],
[Markdown][markdown] and [EJS][ejs] with support for [JavaScript][js], [CoffeeScript][coffee]
and [Iced CoffeeScript][iced].
This plugin is a [gulp][gulp] wrapper for it.

[markdox]: https://github.com/cbou/markdox
[dox]: https://github.com/tj/dox
[markdown]: https://daringfireball.net/projects/markdown/syntax
[ejs]: http://www.embeddedjs.com/
[js]: https://developer.mozilla.org/en-US/docs/Web/JavaScript
[coffee]: http://coffeescript.org/
[iced]: http://maxtaco.github.io/coffee-script/
[gulp]: https://github.com/gulpjs/gulp

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
All parsed docfiles will be passed to template at once:

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
Please refer to [markdox's documentation][markdox] for further documentation of these options.x'.

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

Copyright &copy; 2016 Maciej Chałapuk. Released under [MIT License](LICENSE).


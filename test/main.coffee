es = require 'event-stream'
fs = require 'fs'
should = require 'should'
mocha = require 'mocha'
gulp = require 'gulp'
gutil = require 'gulp-util'
tmp = require 'tmp'
assert = require 'stream-assert'
itis = require 'funsert'

delete require.cache[ require.resolve '../' ]

gutil = require 'gulp-util'
markdox = require '../'
defaultFormatter = require('markdox').defaultFormatter

describe "gulp-markdox", ->

  files = []
  customTemplate = null
  src = []

  before ->
    files.push file = tmp.fileSync prefix: 'markdox'
    fs.writeFileSync file.name, '/** comment0 */'
    files.push file = tmp.fileSync prefix: 'markdox'
    fs.writeFileSync file.name, '/** comment1 */'

    customTemplate = tmp.fileSync prefix: 'markdox'
    fs.writeFileSync customTemplate.name, 'custom template: <?= docfiles.length ?>'

    src = files.map (file) -> file.name

  after ->
    fs.unlinkSync customTemplate.name
    while files.length
      files.shift().removeCallback()
    src = [];

  it 'should generate output files with contents from all piped source files', (done) ->

    testedStream = markdox()

    gulp.src src
      .pipe testedStream
      .pipe assert.length 2
      .pipe assert.first itis.ok (result) ->
        String(result.contents).should.match /.*comment0.*/
      .pipe assert.second itis.ok (result) ->
        String(result.contents).should.match /.*comment1.*/
      .pipe assert.end done

  it 'should call custom compiler that was passed in constructor options', (done) ->
    compiledCode = []

    testedStream = markdox compiler: (filename, code) ->
      compiledCode.push [ filename, code ]
      code

    gulp.src src
      .pipe testedStream
      .pipe assert.length 2
      .pipe assert.end ->
        should.exist compiledCode[0]
        compiledCode[0].should.be.eql [ src[0], '/** comment0 */' ]
        should.exist compiledCode[1]
        compiledCode[1].should.be.eql [ src[1], '/** comment1 */' ]
        done()

  it 'should call custom formatter that was passed in constructor options', (done) ->
    formattedCode = []

    testedStream = markdox formatter: (docfile) ->
      formattedCode.push [
        docfile.filename,
        docfile.javadoc[0].description.full
      ]
      defaultFormatter docfile

    gulp.src src
      .pipe testedStream
      .pipe assert.length 2
      .pipe assert.end ->
        should.exist formattedCode[0]
        formattedCode[0].should.be.eql [ src[0], 'comment0' ]
        should.exist formattedCode[1]
        formattedCode[1].should.be.eql [ src[1], 'comment1' ]
        done()

  it 'should use custom template that was passed in constructor options', (done) ->

    testedStream = markdox template: customTemplate.name

    gulp.src src
      .pipe testedStream
      .pipe assert.length 2
      .pipe assert.all itis.ok (result) ->
        String(result.contents).should.be.exactly 'custom template: 1'
      .pipe assert.end done

  describe 'given "concat" property passed in constructor options', ->
    it 'should generate one file with contents from all piped source files', (done) ->
      testedStream = markdox concat: 'all.md', template: customTemplate.name

      gulp.src src
        .pipe testedStream
        .pipe assert.length 1
        .pipe assert.first itis.ok (result) ->
          String(result.contents).should.be.exactly 'custom template: 2'
        .pipe assert.first itis.ok (result) ->
          result.path.should.match /all\.md/
        .pipe assert.end done



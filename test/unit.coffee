es = require 'event-stream'
fs = require 'fs'
should = require 'should'
mocha = require 'mocha'
gulp = require 'gulp'
gutil = require 'gulp-util'
tmp = require 'tmp'
assert = require 'stream-assert'
itis = require 'funsert'
_ = require 'underscore'

delete require.cache[ require.resolve '../' ]

gutil = require 'gulp-util'
markdox = require '../'
defaultFormatter = require('markdox').defaultFormatter

FileMock = _.partial _.create,
  isNull: -> false,
  isStream: -> false,
  isBuffer: -> true,
  path: 'mock',
  content: [],

describe 'markdox.parse()', ->
  files = []
  before ->
    files.push file = tmp.fileSync prefix: 'markdox', dir: './tmp'
    fs.writeFileSync file.name, '/* comment0 */'
  after ->
    while files.length
      files.shift().removeCallback()

  it 'should emit error when called with input file that is a stream', (done) ->
    streamFile = FileMock
      isStream: -> true,
      isBuffer: -> false,
    emittedError = null

    testedStream = markdox.parse()
      .on 'error', (error) ->
        emittedError = error
        this.emit 'end'

    testedStream.pipe assert.end ->
      should.exist emittedError
      emittedError.message.should.equal 'Streams are not supported'
      done()

    testedStream.write streamFile

  it 'should parse comments', (done) ->

    testedStream = markdox.parse()

    gulp.src(files.map (file) -> file.name)
      .pipe testedStream
      .pipe assert.length 1
      .pipe assert.first itis.ok (result) ->
        result.javadoc[0].description.full.should.equal 'comment0'
      .pipe assert.end done

describe 'markdox.format()', ->

  it 'should emit error when called with input file without "javadoc" property', (done) ->
    emittedError = null

    testedStream = markdox.format()
      .on 'error', (error) ->
        emittedError = error
        this.emit 'end'

    testedStream.pipe assert.end ->
      should.exist emittedError
      emittedError.message.should.equal 'Couldn\'t find property on data chunk: "javadoc"'
      done()

    testedStream.write FileMock()

  it 'should call custom formatter that was passed in constructor options', (done) ->
    docfiles = []

    testedStream = markdox.format formatter: (arg)-> docfiles.push arg

    testedStream.write FileMock javadoc: 'a'
    testedStream.write FileMock javadoc: 'b'
    testedStream.end()

    testedStream.pipe assert.end ->
      docfiles[0].javadoc.should.equal 'a'
      docfiles[1].javadoc.should.equal 'b'
      done()

describe 'markdox.render()', ->

  customTemplate = null

  before ->
    customTemplate = tmp.fileSync prefix: 'markdox'
    fs.writeFileSync customTemplate.name, '<? docfiles.forEach(function(file) { ?><?= file ?>\n<? }) ?>'

  after ->
    fs.unlinkSync customTemplate.name

  it 'should emit error when called with input file without "formattedDoc" property', (done) ->
    emittedError = null

    testedStream = markdox.render()
      .on 'error', (error) ->
        emittedError = error
        this.emit 'end'

    testedStream.pipe assert.end ->
      should.exist emittedError
      emittedError.message.should.equal 'Couldn\'t find property on data chunk: "formattedDoc"'
      done()

    testedStream.write FileMock()

  it 'should use custom template passed in constructor options', (done) ->

    testedStream = markdox.render template: customTemplate.name

    testedStream.pipe assert.length 2
      .pipe assert.first (output) ->
        should.exist output.contents
        String(output.contents).should.equal 'a\n'
        output.path.should.equal 'mock0'
      .pipe assert.second (output) ->
        should.exist output.contents
        String(output.contents).should.equal 'b\n'
        output.path.should.equal 'mock1'
      .pipe assert.end done

    testedStream.write FileMock path: 'mock0', formattedDoc: 'a'
    testedStream.write FileMock path: 'mock1', formattedDoc: 'b'
    testedStream.end()

  it 'should render all files at once in a template when "concat" option passed in constructor options', (done) ->

    testedStream = markdox.render template: customTemplate.name, concat: 'concatenated'

    testedStream.pipe assert.length 1
      .pipe assert.first (output) ->
        should.exist output.contents
        String(output.contents).should.equal 'a\nb\n'
        output.path.should.equal 'concatenated'
      .pipe assert.end done

    testedStream.write FileMock path: 'mock0', formattedDoc: 'a'
    testedStream.write FileMock path: 'mock1', formattedDoc: 'b'
    testedStream.end()

commonTests = {
  'markdox()': markdox,
  'markdox.parse()': markdox.parse,
  'markdox.format()': markdox.format,
  'markdox.render()': markdox.render,
}

_.keys(commonTests).forEach (funcName) ->
  describe funcName, ->
    testedFunction = commonTests[funcName]

    it 'should pass null file down the stream', (done) ->
      nullFile = FileMock isNull: -> true

      testedStream = testedFunction()

      testedStream.pipe assert.length 1
        .pipe assert.first itis.ok (result) ->
          (result == nullFile).should.be.true
        .pipe assert.end done

      testedStream.write nullFile
      testedStream.end()

    it 'should have output file with "markdoxOptions" property containing default values', (done) ->
      nullFile = FileMock isNull: -> true

      testedStream = testedFunction()

      testedStream.pipe assert.length 1
        .pipe assert.first itis.ok (result) ->
          should.exist result.markdoxOptions
          result.markdoxOptions.should.be.eql {
            output: false,
            encoding: 'utf8',
            formatter: defaultFormatter,
          }
        .pipe assert.end done

      testedStream.write nullFile
      testedStream.end()

    it 'should have output file with "markdoxOptions" property containing values passed in constructor', (done) ->
      nullFile = FileMock isNull: -> true

      testedStream = testedFunction(output: true)

      testedStream.pipe assert.length 1
        .pipe assert.first itis.ok (result) ->
          should.exist result.markdoxOptions
          result.markdoxOptions.should.be.eql {
            output: true,
            encoding: 'utf8',
            formatter: defaultFormatter,
          }
        .pipe assert.end done

      testedStream.write nullFile
      testedStream.end()


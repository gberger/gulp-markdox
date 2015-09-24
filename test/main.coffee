es = require 'event-stream'
fs = require 'fs'
should = require 'should'
mocha = require 'mocha'
gulp = require 'gulp'
gutil = require 'gulp-util'
tmp = require 'tmp'
assert = require 'stream-assert'

delete require.cache[ require.resolve '../' ]

gutil = require 'gulp-util'
markdox = require '../'
defaultFormatter = require('markdox').defaultFormatter

describe "gulp-markdox", ->

	files = []

	before ->
		files.push file = tmp.fileSync prefix: 'markdox'
		fs.writeFileSync file.name, '/** comment0 */'
		files.push file = tmp.fileSync prefix: 'markdox'
		fs.writeFileSync file.name, '/** comment1 */'
	after ->
		while files.length
			files.shift().removeCallback()

	it 'should generate output files with contents of all passed source files', (done) ->
		testedStream = markdox()

		generatedFiles = []
		testedStream.on "data", (newFile) ->
			generatedFiles.push(newFile)

		gulp.src(files.map (file) -> file.name)
			.pipe testedStream
			.pipe assert.end ->
				should.exist generatedFiles[0]
				String(generatedFiles[0].contents).should.match /.*comment0.*/
				should.exist generatedFiles[1]
				String(generatedFiles[1].contents).should.match /.*comment1.*/
				done()

	it 'should call custom compiler passed in options', (done) ->
		compiledCode = []

		testedStream = markdox compiler: (filename, code) ->
			compiledCode.push [ filename, code ]
			code

		gulp.src(files.map (file) -> file.name)
			.pipe testedStream
			.pipe assert.end ->
				should.exist compiledCode[0]
				compiledCode[0].should.be.eql [ files[0].name, '/** comment0 */' ]
				should.exist compiledCode[1]
				compiledCode[1].should.be.eql [ files[1].name, '/** comment1 */' ]
				done()


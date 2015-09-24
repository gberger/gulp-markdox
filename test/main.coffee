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

	src = []
	customTemplate = null

	before ->
		src.push file = tmp.fileSync prefix: 'markdox'
		fs.writeFileSync file.name, '/** comment0 */'
		src.push file = tmp.fileSync prefix: 'markdox'
		fs.writeFileSync file.name, '/** comment1 */'
		customTemplate = tmp.fileSync prefix: 'markdox'
		fs.writeFileSync customTemplate.name, 'custom template'
	after ->
		fs.unlinkSync customTemplate.name
		while src.length
			src.shift().removeCallback()

	it 'should generate output files with contents from all passed source src', (done) ->
		testedStream = markdox()

		generatedFiles = []
		testedStream.on "data", (newFile) ->
			generatedFiles.push(newFile)

		gulp.src(src.map (file) -> file.name)
			.pipe testedStream
			.pipe assert.end ->
				should.exist generatedFiles[0]
				String(generatedFiles[0].contents).should.match /.*comment0.*/
				should.exist generatedFiles[1]
				String(generatedFiles[1].contents).should.match /.*comment1.*/
				done()

	it 'should call custom compiler that was passed in constructor options', (done) ->
		compiledCode = []

		testedStream = markdox compiler: (filename, code) ->
			compiledCode.push [ filename, code ]
			code

		gulp.src(src.map (file) -> file.name)
			.pipe testedStream
			.pipe assert.end ->
				should.exist compiledCode[0]
				compiledCode[0].should.be.eql [ src[0].name, '/** comment0 */' ]
				should.exist compiledCode[1]
				compiledCode[1].should.be.eql [ src[1].name, '/** comment1 */' ]
				done()

	it 'should call custom formatter that was passed in constructor options', (done) ->
		formattedCode = []

		testedStream = markdox formatter: (docfile) ->
			formattedCode.push [
				docfile.filename.replace(/^(\.\.\/)+/, '/'),
				docfile.javadoc[0].description.full
			]
			defaultFormatter docfile

		gulp.src(src.map (file) -> file.name)
			.pipe testedStream
			.pipe assert.end ->
				should.exist formattedCode[0]
				formattedCode[0].should.be.eql [ src[0].name, 'comment0' ]
				should.exist formattedCode[1]
				formattedCode[1].should.be.eql [ src[1].name, 'comment1' ]
				done()

	it 'should use custom template that was passed in constructor options', (done) ->
		testedStream = markdox template: customTemplate.name

		generatedFiles = []
		testedStream.on "data", (newFile) ->
			generatedFiles.push(newFile)

		gulp.src(src.map (file) -> file.name)
			.pipe testedStream
			.pipe assert.end ->
				should.exist generatedFiles[0]
				String(generatedFiles[0].contents).should.be.exactly 'custom template'
				should.exist generatedFiles[1]
				String(generatedFiles[1].contents).should.be.exactly 'custom template'
				done()


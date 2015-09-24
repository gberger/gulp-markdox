es = require 'event-stream'
fs = require 'fs'
should = require 'should'
mocha = require 'mocha'
gulp = require 'gulp'
gutil = require 'gulp-util'
tmp = require 'tmp'
assert = require 'stream-assert'

delete require.cache[require.resolve("../")]

gutil = require("gulp-util")
markdox = require("../")

describe "gulp-markdox", ->

	files = []

	files.push path = tmp.tmpNameSync(prefix: 'markdox')
	fs.writeFileSync path, '/** comment0 */'
	files.push path = tmp.tmpNameSync(prefix: 'markdox')
	fs.writeFileSync path, '/** comment1 */'

	it "should generate files with contents of all passed files", (done) ->
		testedStream = markdox()

		generatedFiles = []
		testedStream.on "data", (newFile) ->
			generatedFiles.push(newFile)

		gulp.src(files)
			.pipe testedStream
			.pipe assert.end ->
				should.exist generatedFiles[0]
				String(generatedFiles[0].contents).should.match /.*comment0.*/
				should.exist generatedFiles[1]
				String(generatedFiles[1].contents).should.match /.*comment1.*/
				done()


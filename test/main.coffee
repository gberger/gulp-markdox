es     = require 'event-stream'
fs     = require 'fs'
should = require 'should'
mocha  = require 'mocha'

delete require.cache[require.resolve("../")]

gutil = require("gulp-util")
markdox = require("../")

describe "gulp-markdox", ->

	# name of our fixtures
	files =
		js: 'dox-parser.js'
		coffee: 'dox-parser.coffee'
		iced: 'iced.iced'
		tags: 'tags.coffee'

	# opens buffers for the source and expected files
	makeFiles = (name) ->
		srcFile = new gutil.File
			path: "test/fixtures/#{name}"
			contents: fs.readFileSync("test/fixtures/#{name}")

		expectedFile = new gutil.File
			path: "test/expected/#{name}"
			contents: fs.readFileSync("test/expected/#{name}.md")

		return [srcFile, expectedFile]


	it "should produce expected file with JS source", (done) ->
		[srcFile, expectedFile] = makeFiles(files.js)

		stream = markdox()

		stream.on "data", (newFile) ->
			should.exist newFile
			should.exist newFile.contents
			String(newFile.contents).should.equal String(expectedFile.contents)
			done()

		stream.write srcFile
		stream.end()

	it "should produce expected file with Coffee source", (done) ->
		[srcFile, expectedFile] = makeFiles(files.coffee)

		stream = markdox()

		stream.on "data", (newFile) ->
			should.exist newFile
			should.exist newFile.contents
			String(newFile.contents).should.equal String(expectedFile.contents)
			done()

		stream.write srcFile
		stream.end()

	it "should produce expected file with Iced source", (done) ->
		[srcFile, expectedFile] = makeFiles(files.iced)

		stream = markdox()

		stream.on "data", (newFile) ->
			should.exist newFile
			should.exist newFile.contents
			String(newFile.contents).should.equal String(expectedFile.contents)
			done()

		stream.write srcFile
		stream.end()

	it "should produce expected file with all tags", (done) ->
		[srcFile, expectedFile] = makeFiles(files.tags)

		stream = markdox()

		stream.on "data", (newFile) ->
			should.exist newFile
			should.exist newFile.contents
			String(newFile.contents).should.equal String(expectedFile.contents)
			done()

		stream.write srcFile
		stream.end()

#jshint camelcase: false

"use strict"
mountFolder = (connect, dir) ->
  connect.static require("path").resolve(dir)

module.exports = (grunt) ->
  
  # load all grunt tasks
  require("matchdep").filterDev("grunt-*").forEach grunt.loadNpmTasks
  
  # configurable paths
  yeomanConfig =
    app: "app"
    dist: "dist"

  grunt.initConfig
    yeoman: yeomanConfig
    watch:
      coffee:
        files: ["<%= yeoman.app %>/scripts/{,*/}*.coffee"]
        tasks: ["build"]

      coffeeTest:
        files: ["test/spec/{,*/}*.coffee"]
        tasks: ["coffee:test"]

    connect:
      options:
        port: 9000
        
        # change this to '0.0.0.0' to access the server from outside
        hostname: "localhost"

      test:
        options:
          middleware: (connect) ->
            [mountFolder(connect, ".tmp"), mountFolder(connect, "test")]

    clean:
      dist:
        files: [
          dot: true
          src: [".tmp", "<%= yeoman.dist %>/*", "!<%= yeoman.dist %>/.git*"]
        ]

      server: ".tmp"

    jshint:
      options:
        jshintrc: ".jshintrc"

      all: ["Gruntfile.js", "<%= yeoman.app %>/scripts/{,*/}*.js", "test/spec/{,*/}*.js"]

    mocha:
      all:
        options:
          run: true
          urls: ["http://localhost:<%= connect.options.port %>/index.html"]

    coffee:
      dist:
        files: [
          expand: true
          cwd: "<%= yeoman.app %>/scripts"
          src: "{,*/}*.coffee"
          dest: ".tmp/scripts"
          ext: ".js"
        ]

      test:
        files: [
          expand: true
          cwd: "test/spec"
          src: "{,*/}*.coffee"
          dest: ".tmp/spec"
          ext: ".js"
        ]

    copy:
      coffee:
        files: [
          expand: true
          dot: true
          cwd: ".tmp"
          dest: "<%= yeoman.dist %>"
          src: [
            "scripts/{,*/}*.js"
          ]
        ]
      dist:
        files: [
          expand: true
          dot: true
          cwd: "<%= yeoman.app %>"
          dest: "<%= yeoman.dist %>"
          src: [
            "*.{ico,txt}"
            "images/{,*/}*.{webp,gif,png,jpg,jpeg}"
            "_locales/{,*/}*.json"
          ]
        ]

    compress:
      dist:
        options:
          archive: "package/nicomnibox.zip"

        files: [
          expand: true
          cwd: "dist/"
          src: ["**"]
          dest: ""
        ]

  grunt.renameTask "regarde", "watch"

  grunt.registerTask "manifest", ->
    manifest = grunt.file.readJSON(yeomanConfig.app + "/manifest.json")
    manifest.background.scripts = ["scripts/background.js"]
    grunt.file.write yeomanConfig.dist + "/manifest.json", JSON.stringify(manifest, null, 2)

  grunt.registerTask "test", ["clean:server", "coffee", "connect:test", "mocha"]
  grunt.registerTask "build", ["clean:dist", "coffee", "copy:coffee", "copy:dist", "manifest", "compress"]
  grunt.registerTask "default", ["jshint", "test", "build"]

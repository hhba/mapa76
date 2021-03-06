
module.exports = function(grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    banner: '/*! \n* <%= pkg.title || pkg.name %> - v<%= pkg.version %>' +
            '\n* Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author %> ' +
            '\n* <%= pkg.homepage ? pkg.homepage : "" %> ' +
            '\n*/ \n\n',

    paths: {
      app: {
        root: "app/",
        css: "app/styles/",
        assets: "app/assets/"
      },
      vendor: {
        js: "vendor/scripts/"
      },
      dist: {
        root: "dist/",
        css: "dist/css/",
        js: "dist/js/",
        images: "dist/img/"
      }
    },

    clean: {
      before: {
        src: [
          "<%= paths.dist.root %>*",
          "!<%= paths.dist.root %>.gitignore"
        ],
      }
    },

    less: {
      dev: {
        files: {
          "<%= paths.dist.css %>app.css": [
            "<%= paths.app.css %>app.less"
          ]
        }
      },

      prod: {
        options: {
          yuicompress: true
        },
        files: {
          "<%= paths.dist.css %>app.css": [
            "<%= paths.app.css %>app.less"
          ]
        }
      }

    },

    browserify: {
      app: {
        options:{
          extension: [ '.js', '.hbs' ],
          transform: [ 'hbsfy' ],
          //debug: true
        },
        src: ['<%= paths.app.root %>initApp.js'],
        dest: '<%= paths.dist.js %>app.js'
      }
    },

    concat: {
      vendor: {
        files: {
          '<%= paths.dist.js %>vendor.js': [
              '<%= paths.vendor.js %>underscore.min.js'
            , '<%= paths.vendor.js %>backbone.min.js'
            , '<%= paths.vendor.js %>backbone.marionette.min.js'
            , '<%= paths.vendor.js %>jquery.ui.widget.js'
            , '<%= paths.vendor.js %>**/*.js'
          ]
        }
      },
      app: {
        options: {
          stripBanners: {
            line: true
          },
          banner: '<%= banner %>',
        },
        files: {
          '<%= paths.dist.js %>app.js': [ '<%= paths.dist.js %>app.js' ]
        }
      }
    },

    uglify: {
      all: {
        options: {
          stripBanners: {
            line: true
          },
          banner: '<%= banner %>',
        },
        files: {
          '<%= paths.dist.js %>app.js': [ '<%= paths.dist.js %>app.js' ]
        }
      }
    },

    copy: {
      dist: {
        expand: true,
        cwd: "<%= paths.app.assets %>",
        src: ["**"],
        dest: "<%= paths.dist.root %>"
      }
    },

    watch: {
      app: {
        files: ["<%= paths.app.root %>**/*"],
        tasks: ['default'],
        options: {
          atBegin: true
        }
      }
    },

    jshint: {
      all: {
        files: {
          src: ["<%= paths.app.root %>**/*.js"]
        },
        options: {
            bitwise: true
          , curly: true
          , eqeqeq: true
          , forin: true
          , immed: true
          , latedef: true
          , newcap: true
          , noempty: true
          , nonew: true
          , quotmark: false
          , undef: true
          , unused: true
          , laxcomma: true

          ,globals: {
              window: true
            , $: true
            , jQuery: true
            , _: true
            , require: true
            , module: true
            , Backbone: true
            , Handlebars: true
            , console: true
            , moment: true
            , aeolus: true
          }
        }
      }
    }
  });

  grunt.loadNpmTasks('grunt-browserify');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-commonjs-handlebars');
  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-uglify');

  grunt.registerTask("default", [
    "clean:before",
    "jshint:all",
    "less:dev",
    "browserify",
    "concat",
    "copy"
  ]);

  grunt.registerTask("dist", [ "default", "uglify" ]);

};

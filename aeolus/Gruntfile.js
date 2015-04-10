
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
        assets: "app/assets",
        css: "app/assets/styles/",
        fonts: "app/assets/fonts",
        images: "app/assets/images"

      },
      vendor: {
        js: "vendor/scripts/"
      },
      dist: {
        root: "dist/",
        assets: "app/assets/",
        css: "dist/stylesheets/",
        fonts: "dist/fonts/",
        js: "dist/javascripts/",
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

    sass: {
      dev: {
        options: {
          sourceComments: true
        },
        files: {
          "<%= paths.dist.css %>app.css": "<%= paths.app.css %>app.scss"
        }
      },
      dist: {
        options: {
          outputStyle: 'compressed'
        },
        files: {
          "<%= paths.dist.css %>app.css": "<%= paths.app.css %>app.scss"
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

    browserSync: {
      options: {
        port: 3001
      },
      dev: {
        bsFiles: {
          src: ["<%= paths.app.root %>**/*"]
        },
        options: {
          watchTask: true,
          server: './dist/'
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
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-sass');
  grunt.loadNpmTasks('grunt-browser-sync');

  grunt.registerTask("sass-dev", [ "sass:dev" ]);
  grunt.registerTask("sass-prod", [ "sass:prod" ]);
  grunt.registerTask("default", [
    "clean:before",
    "jshint:all",
    "browserify",
    "concat",
    "copy",
    "sass:dev"
  ]);
  grunt.registerTask("dist", [ "default", "uglify", "sass:prod" ]);
  grunt.registerTask('serve', ['browserSync', 'watch']);

};

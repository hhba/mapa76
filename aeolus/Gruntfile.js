
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
        css: "app/styles/",
        fonts: "app/assets/fonts",
        images: "app/assets/images",
        bower: "bower_components/",
        frontend: "app/frontend/"
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
        images: "dist/images/"
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

    symlink: {
      explicit: {
        files: [
          {
            src: '<%= paths.dist.fonts %>',
            dest: '<%= paths.dist.root %>latest/fonts'
          },
          {
            src: '<%= paths.dist.images %>',
            dest: '<%= paths.dist.root %>latest/images'
          },
        ]
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
      frontend: {
        files: {
          '<%= paths.dist.js %>frontend.js': [
            '<%= paths.app.bower %>jquery/dist/jquery.js',
            '<%= paths.app.bower %>jquery-placeholder/jquery.placeholder.js',
            '<%= paths.app.bower %>carouFredSel/jquery.carouFredSel-6.2.1.js',
            '<%= paths.app.frontend %>dropdown.js',
            '<%= paths.app.frontend %>home.js',
            '<%= paths.app.frontend %>application.js'
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
          '<%= paths.dist.js %>app.js': [ '<%= paths.dist.js %>app.js' ],
          '<%= paths.dist.js %>frontend.js': [ '<%= paths.dist.js %>frontend.js' ],
          '<%= paths.dist.js %>vendor.js': [ '<%= paths.dist.js %>vendor.js' ]
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
            , document: true
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
    },

    bower_concat: {
      all: {
        dest: "<%= paths.dist.js %>vendor.js"
      }
    },

    connect: {
      server: {
        options: {
          port: 3001,
          hostname: '*',
          base: 'dist/',
          keepalive: true,
          middleware: function(connect, options, middlewares) {
            middlewares.unshift(function(req, res, next) {
              res.setHeader('Access-Control-Allow-Origin', '*');
              next();
            });
            return middlewares;
          }
        }
      }
    }
  });

  grunt.loadNpmTasks('grunt-browserify');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-commonjs-handlebars');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-connect');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-symlink');
  grunt.loadNpmTasks('grunt-bower-concat');
  grunt.loadNpmTasks('grunt-sass');

  grunt.registerTask("sass-dev", [ "sass:dev" ]);
  grunt.registerTask("sass-dist", [ "sass:dist" ]);
  grunt.registerTask("default", [
    "clean:before",
    "jshint:all",
    "browserify",
    "concat",
    "copy",
    "bower_concat",
    "symlink",
    "sass:dev"
  ]);
  grunt.registerTask("dist", [ "default", "uglify", "sass:dist" ]);
  grunt.registerTask("serve", ["connect", "watch"]);
};

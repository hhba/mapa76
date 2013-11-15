
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
          "<%= paths.app.root %>views/**/*.tpl.js", 
          "<%= paths.dist.root %>*",
          "!<%= paths.dist.root %>.gitignore"
        ],
      },
      after: {
        src: [
          "<%= paths.app.root %>views/**/*.tpl.js", 
          "<%= paths.dist.root %>app_prev.js"
        ]
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

    handlebars: {
      dev: {
        files: [
          {
            expand: true,
            cwd: 'app/views/',
            src: ['**/*.hbs'],
            dest: 'app/views/',
            ext: '.tpl.js',
          },
        ]
      }
    },

    builder: {
      app: {
        src: "<%= paths.app.root %>initApp.js",
        dest: "<%= paths.dist.root %>app_prev.js"
      }
    },

    concat: {
      vendor: {
        files: {
          '<%= paths.dist.js %>vendor.js': [
              '<%= paths.vendor.js %>underscore.min.js'
            , '<%= paths.vendor.js %>backbone.min.js'
            , '<%= paths.vendor.js %>backbone.marionette.min.js'
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
          '<%= paths.dist.js %>app.js': [ '<%= paths.dist.root %>app_prev.js' ]
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
      local: {
        files: ["<%= paths.app.root %>**/*",
          "!<%= paths.app.root %>views/**/*.tpl.js"],
        tasks: ['default']
      },
      stage: {
        files: ["<%= paths.app.root %>**/*",
          "!<%= paths.app.root %>views/**/*.tpl.js"],
        tasks: ['stage']
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
            , aeolus: true
          }
        }
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-commonjs-handlebars');
  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-uglify');

  require('./builder.grunt.js')(grunt);

  grunt.registerTask("default", [
    "clean:before", 
    "jshint:all", 
    "less:dev",
    "handlebars", 
    "builder:app:local", 
    "concat", 
    "clean:after",
    "copy"
  ]);

  grunt.registerTask("stage", [
    "clean:before", 
    "jshint:all", 
    "less:dev",
    "handlebars", 
    "builder:app:stage", 
    "concat", 
    "clean:after",
    "copy"
  ]);

  grunt.registerTask("prod", [
    "clean:before", 
    "jshint:all", 
    "less:prod",
    "handlebars", 
    "builder:app:prod", 
    "concat", 
    "uglify",
    "clean:after",
    "copy:dist"
  ]);

  grunt.registerTask("w", ["default", "watch:local"]);
  grunt.registerTask("ws", ["stage", "watch:stage"]);
};

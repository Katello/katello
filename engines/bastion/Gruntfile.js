/**
 * Copyright 2013 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 */

/*global module,require*/

var lrSnippet = require('grunt-contrib-livereload/lib/utils').livereloadSnippet;
var mountFolder = function (connect, dir) {
    return connect.static(require('path').resolve(dir));
};

module.exports = function (grunt) {
    // load all grunt tasks
    require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);

    // configurable paths
    var bastionConfig = {
        src: 'app/assets/bastion',
        dist: 'dist'
    };

    try {
        bastionConfig.src = require('./bower.json').appPath || bastionConfig.src;
    } catch (e) {}

    grunt.initConfig({
        bastion: bastionConfig,
        clean: {
            build: '<%= bastion.dist %>'
        },
        connect: {
            livereload: {
                options: {
                    port: 9000,
                    hostname: '0.0.0.0',
                    middleware: function (connect) {
                        return [
                            lrSnippet,
                            mountFolder(connect, bastionConfig.src)
                        ];
                    }
                }
            },
            test: {
                options: {
                    middleware: function (connect) {
                        return [
                            mountFolder(connect, 'test')
                        ];
                    }
                }
            }
        },
        jshint: {
            options: {
                jshintrc: '.jshintrc'
            },
            all: [
                'Gruntfile.js',
                '<%= bastion.src %>/**/*.js',
                '!<%= bastion.src %>/i18n/translations.js'
            ]
        },
        htmlhint: {
            html: {
                src: [bastionConfig.src + '/**/*.html'],
                options: {
                    'tagname-lowercase': true,
                    'attr-lowercase': true,
                    'attr-value-doublequotes': true,
                    'tag-pair': true,
                    'tag-self-close': true,
                    'id-unique': true,
                    'src-not-empty': true,
                    'style-disabled': true,
                    'img-alt-require': true,
                    'spec-char-escape': true
                },
            },
        },
        karma: {
            server: {
                configFile: 'karma.conf.js',
                autoWatch: true
            },
            singleRun: {
                configFile: 'karma.conf.js',
                singleRun: true
            },
            //continuous integration mode
            ci: {
                configFile: 'karma.conf.js',
                reporters: ['progress', 'coverage'],
                preprocessors: {
                    'app/assets/bastion/**/*.html': ['ng-html2js'],
                    'app/assets/bastion/**/*.js': ['coverage']
                },
                coverageReporter: {
                    type: 'cobertura',
                    dir: 'coverage/'
                },
                singleRun: true
            }
        },
        docular: {
            groups: [{
                groupTitle: 'Bastion',
                groupId: 'bastion',
                sections: [{
                    id: 'bastion_api',
                    title: 'API Reference',
                    scripts: [
                        'app/assets/bastion/components/',
                        'app/assets/bastion/i18n/',
                        'app/assets/bastion/incubator',
                        'app/assets/bastion/menu',
                        'app/assets/bastion/systems',
                        'app/assets/bastion/utils',
                        'app/assets/bastion/widgets'
                    ]
                }]
            }],
            showDocularDocs: false,
            showAngularDocs: false
        },
        'nggettext_extract': {
            bastion: {
                src: ['<%= bastion.src %>/**/*.html', '<%= bastion.src %>/**/*.js'],
                dest: '<%= bastion.src %>/i18n/katello.pot'
            }
        },
        'nggettext_compile': {
            options: {
                module: 'Bastion'
            },
            bastion: {
                src: ['<%= bastion.src %>/i18n/locale/**/*.po'],
                dest: '<%= bastion.src %>/i18n/translations.js'
            }
        }
    });

    grunt.registerTask('docs', [
        'docular'
    ]);

    grunt.registerTask('i18n:extract', [
        'nggettext_extract'
    ]);

    grunt.registerTask('i18n:compile', [
        'nggettext_compile'
    ]);

    grunt.registerTask('test', [
        'connect:test',
        'karma:singleRun'
    ]);

    grunt.registerTask('test:server', [
        'connect:test',
        'karma:server'
    ]);

    grunt.registerTask('ci', [
        'connect:test',
        'jshint',
        'htmlhint',
        'karma:ci'
    ]);

    grunt.registerTask('build', [
        'clean:build',
        'jshint',
        'htmlhint',
        'test'
    ]);

    grunt.registerTask('default', ['build']);
};

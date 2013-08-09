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
                '<%= bastion.src %>/**/*.js'
            ]
        },
        karma: {
            //continuous integration mode
            ci: {
                browsers: ['PhantomJS'],
                configFile: 'karma.conf.js',
                singleRun: true
            },
            server: {
                configFile: 'karma.conf.js',
                autoWatch: true
            },
            singleRun: {
                configFile: 'karma.conf.js',
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
        }
    });

    grunt.registerTask('docs', [
        'docular'
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
        'karma:ci'
    ]);

    grunt.registerTask('build', [
        'clean:build',
        'jshint',
        'test'
    ]);

    grunt.registerTask('default', ['build']);
};

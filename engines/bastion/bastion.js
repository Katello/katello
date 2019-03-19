var requireDir = require('require-dir');

module.exports = function (grunt) {
    var configs = requireDir('./grunt');

    grunt.loadTasks('node_modules/grunt-eslint/tasks');
    grunt.loadTasks('node_modules/grunt-htmlhint/tasks');
    grunt.loadTasks('node_modules/grunt-bower-task/tasks');
    grunt.loadTasks('node_modules/grunt-karma/tasks');
    grunt.loadTasks('node_modules/grunt-angular-gettext/tasks');

    grunt.initConfig(configs);

    grunt.registerTask('ci', [
        'eslint',
        'htmlhint',
        'karma:ci'
    ]);

    grunt.registerTask('test', [
        'karma:unit'
    ]);

    grunt.registerTask('i18n:extract', [
        'nggettext_extract'
    ]);

    grunt.registerTask('i18n:compile', [
        'nggettext_compile'
    ]);

    grunt.registerTask('default', [
        'ci',
    ]);
};

module.exports = function(config) {
    config.set({
        basePath: '.',
        frameworks: ['jasmine'],
        port: 8080,
        runnerPort: 9100,
        colors: true,
        browsers: ['PhantomJS'],
        reporters: ['progress'],
        singleRun: false,
        preprocessors: {
            'app/assets/javascripts/bastion/**/*.html': ['ng-html2js']
        },
        files: [
            '.tmp/bower_components/jquery/jquery.js',
            'vendor/assets/javascripts/bastion/angular/angular.js',
            '.tmp/bower_components/angular-mocks/angular-mocks.js',
            'vendor/assets/javascripts/bastion/angular-sanitize/angular-sanitize.js',
            'vendor/assets/javascripts/bastion/angular-resource/angular-resource.js',
            'vendor/assets/javascripts/bastion/**/*.js',
            'vendor/assets/javascripts/bastion/alchemy/alchemy.js',
            'vendor/assets/javascripts/bastion/underscore/underscore.js',
            'vendor/assets/javascripts/bastion/angular-ui-router/angular-ui-router.js',
            'vendor/assets/javascripts/bastion/angular-gettext/angular-gettext.js',
            'vendor/assets/javascripts/bastion/ngUpload/ng-upload.js',

            '../../app/assets/javascripts/katello/common/katello.global.js',
            '../../app/assets/javascripts/katello/common/notices.js',
            '../../app/assets/javascripts/katello/common/experimental/katello-globals.module.js',

            // Load Bastion module first
            'app/assets/javascripts/bastion/bastion.module.js',

            // Load Bastion test constants
            'test/bastion/test-constants.js',

            // Load modules first
            'app/assets/javascripts/bastion/**/*.module.js',
            'app/assets/javascripts/bastion/**/*.js',
            'app/assets/javascripts/bastion/**/*.html',

            'test/test-mocks.module.js',
            'test/**/*test.js'
        ],
        ngHtml2JsPreprocessor: {
            stripPrefix: 'app/assets/javascripts/bastion/'
        }
    });
};

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
            'app/assets/bastion/**/*.html': ['ng-html2js']
        },
        files: [
            '.tmp/assets/dev-components/jquery/jquery.js',
            '.tmp/assets/dev-components/angular/angular.js',
            '.tmp/assets/dev-components/angular-mocks/angular-mocks.js',
            '.tmp/assets/dev-components/alchemy/alchemy.js',
            '.tmp/assets/dev-components/underscore/underscore.js',

            'vendor/assets/components/angular-sanitize/angular-sanitize.js',
            'vendor/assets/components/angular-resource/angular-resource.js',
            'vendor/assets/components/angular-ui-router/angular-ui-router.js',
            'vendor/assets/components/angular-gettext/angular-gettext.js',
            'vendor/assets/components/ng-upload/ng-upload.js',

            '../../app/assets/javascripts/common/katello.global.js',
            '../../app/assets/javascripts/common/katello.module.js',
            '../../app/assets/javascripts/common/notices.js',
            '../../app/assets/javascripts/common/experimental/katello-globals.module.js',

            // Must load modules first
            'app/assets/bastion/**/*.module.js',
            'app/assets/bastion/**/*.js ',
            'app/assets/bastion/**/*.html',

            'test/test-mocks.module.js',
            'test/**/*test.js'
        ],
        ngHtml2JsPreprocessor: {
            stripPrefix: 'app/assets/bastion/'
        }
    });
};

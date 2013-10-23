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
            'vendor/assets/dev-components/jquery/jquery.js',
            'vendor/assets/dev-components/angular/angular.js',
            'vendor/assets/dev-components/angular-mocks/angular-mocks.js',
            'vendor/assets/dev-components/angular-sanitize/angular-sanitize.js',
            'vendor/assets/dev-components/angular-resource/angular-resource.js',
            'vendor/assets/dev-components/ngInfiniteScroll/ng-infinite-scroll.js',
            'vendor/assets/dev-components/alchemy/alchemy.js',
            'vendor/assets/dev-components/underscore/underscore.js',
            '../../vendor/assets/javascripts/angular-ui-router.js',
            '../../vendor/assets/javascripts/angular-gettext.js',
            'vendor/assets/components/ng-upload.js',

            '../../app/assets/javascripts/common/katello.global.js',
            '../../app/assets/javascripts/common/katello.module.js',
            '../../app/assets/javascripts/common/notices.js',
            '../../app/assets/javascripts/common/experimental/katello-globals.module.js',

            // Must load modules first
            'app/assets/bastion/**/*.module.js',
            'app/assets/bastion/**/*.js',
            'app/assets/bastion/**/*.html',

            'test/test-mocks.module.js',
            'test/**/*test.js'
        ],
        ngHtml2JsPreprocessor: {
            stripPrefix: 'app/assets/bastion/'
        }
    });
};

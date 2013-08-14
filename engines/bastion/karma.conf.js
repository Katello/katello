// Testacular configuration

// base path, that will be used to resolve files and exclude
basePath = 'app/assets/bastion/';

// list of files / patterns to load in the browser
files = [
    JASMINE,
    JASMINE_ADAPTER,

    '../../../vendor/assets/dev-components/jquery/jquery.js',
    '../../../vendor/assets/dev-components/angular/angular.js',
    '../../../vendor/assets/dev-components/angular-mocks/angular-mocks.js',
    '../../../vendor/assets/dev-components/angular-sanitize/angular-sanitize.js',
    '../../../vendor/assets/dev-components/angular-resource/angular-resource.js',
    '../../../vendor/assets/dev-components/ngInfiniteScroll/ng-infinite-scroll.js',
    '../../../vendor/assets/dev-components/alchemy/alchemy.js',
    '../../../../../vendor/assets/javascripts/angular-ui-states.js',

    '../../../../../app/assets/javascripts/common/katello.global.js',
    '../../../../../app/assets/javascripts/common/katello.module.js',
    '../../../../../app/assets/javascripts/common/notices.js',
    '../../../../../app/assets/javascripts/common/experimental/katello-globals.module.js',
    '../../../../../app/assets/javascripts/system_groups/system-groups.module.js',

    // Must load modules first
    '**/*.module.js',
    '**/*.js',
    '**/views/*.html',

    '../../../test/**/*test.js'
];

// list of files to exclude
exclude = [];

// test results reporter to use
// possible values: dots || progress
reporter = 'progress';

// web server port
port = 8080;

// cli runner port
runnerPort = 9100;

// enable / disable colors in the output (reporters and logs)
colors = true;

// level of logging
// possible values: LOG_DISABLE || LOG_ERROR || LOG_WARN || LOG_INFO || LOG_DEBUG
logLevel = LOG_INFO;

// enable / disable watching file and executing tests whenever any file changes
autoWatch = true;

// Start these browsers, currently available:
// - Chrome
// - ChromeCanary
// - Firefox
// - Opera
// - Safari
// - PhantomJS
browsers = ['PhantomJS'];

// Continuous Integration mode
// if true, it capture browsers, run tests and exit
singleRun = false;

preprocessors = {
    '**/views/*.html': 'html2js'
};

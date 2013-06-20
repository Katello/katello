// Testacular configuration

// base path, that will be used to resolve files and exclude
basePath = '';

// list of files / patterns to load in the browser
files = [
    JASMINE,
    JASMINE_ADAPTER,

    'vendor/assets/components/jquery/jquery.js',
    'vendor/assets/components/angular/angular.js',
    'vendor/assets/components/angular-mocks/angular-mocks.js',
    'vendor/assets/components/angular-sanitize/angular-sanitize.js',
    'vendor/assets/components/angular-resource/angular-resource.js',
    'vendor/assets/components/ngInfiniteScroll/ng-infinite-scroll.js',
    'vendor/assets/components/alchemy/alchemy.js',
    '../../vendor/assets/javascripts/angular-ui-states.js',

    '../../app/assets/javascripts/common/katello.global.js',
    '../../app/assets/javascripts/common/katello.module.js',
    '../../app/assets/javascripts/common/notices.js',
    '../../app/assets/javascripts/common/experimental/katello-globals.module.js',
    '../../app/assets/javascripts/systems/systems.module.js',
    '../../app/assets/javascripts/system_groups/system-groups.module.js',

    // Must load modules first
    'app/assets/bastion/**/*.module.js',
    'app/assets/bastion/**/*.js',

    '.tmp/templates/**/*.js',

    'test/**/*test.js'
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

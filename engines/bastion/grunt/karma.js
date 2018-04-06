var basePath = __dirname + '/../',
    pluginName = process.cwd().split('/').pop();


module.exports = {
    options: {
        frameworks: ['jasmine'],
        runnerPort: 9100,
        browserNoActivityTimeout: 100000,
        colors: true,
        browsers: ['ChromiumHeadless'],
        reporters: ['progress'],
        singleRun: true,
        preprocessors: {
            'app/assets/javascripts/**/*.html': ['ng-html2js']
        },
        exclude: [
            basePath + 'app/assets/javascripts/bastion/bastion-bootstrap.js'
        ],
        files: [
            basePath + '.tmp/bower_components/jquery/jquery.js',
            basePath + 'vendor/assets/javascripts/bastion/angular/angular.js',
            basePath + 'vendor/assets/javascripts/bastion/angular-sanitize/angular-sanitize.js',
            basePath + 'vendor/assets/javascripts/bastion/angular-resource/angular-resource.js',
            basePath + 'vendor/assets/javascripts/bastion/angular-uuid4/angular-uuid4.js',
            basePath + 'vendor/assets/javascripts/bastion/angular-blocks/angular-blocks.js',
            basePath + 'vendor/assets/javascripts/bastion/angular-animate/angular-animate.js',
            basePath + 'vendor/assets/javascripts/bastion/angular-bootstrap/ui-bootstrap.js',
            basePath + 'vendor/assets/javascripts/bastion/angular-bootstrap/ui-bootstrap-tpls.js',
            basePath + 'vendor/assets/javascripts/bastion/angular-ui-router/*.js',
            basePath + 'vendor/assets/javascripts/bastion/angular-gettext/angular-gettext.js',
            basePath + 'vendor/assets/javascripts/bastion/ngUpload/ng-upload.js',
            basePath + 'vendor/assets/javascripts/bastion/angular-breadcrumb/angular-breadcrumb.js',
            basePath + '.tmp/bower_components/ngReact/ngReact.js',
            basePath + '.tmp/bower_components/angular-mocks/angular-mocks.js',
            basePath + '.tmp/bower_components/lodash/lodash.js',

            basePath + 'app/assets/javascripts/bastion/bastion.module.js',
            basePath + 'app/assets/javascripts/bastion/routing.module.js',
            basePath + 'app/assets/javascripts/bastion/i18n/i18n.module.js',
            basePath + 'app/assets/javascripts/bastion/i18n/*.js',
            basePath + 'app/assets/javascripts/bastion/auth/auth.module.js',
            basePath + 'app/assets/javascripts/bastion/auth/*.js',
            basePath + 'app/assets/javascripts/bastion/utils/utils.module.js',
            basePath + 'app/assets/javascripts/bastion/utils/*.js',
            basePath + 'app/assets/javascripts/bastion/menu/menu.module.js',
            basePath + 'app/assets/javascripts/bastion/menu/*.js',
            basePath + 'app/assets/javascripts/bastion/features/features.module.js',
            basePath + 'app/assets/javascripts/bastion/features/*.js',
            basePath + 'app/assets/javascripts/bastion/components/components.module.js',
            basePath + 'app/assets/javascripts/bastion/components/*.js',
            basePath + 'app/assets/javascripts/bastion/components/formatters/components-formatters.module.js',
            basePath + 'app/assets/javascripts/bastion/components/formatters/*.js',

            basePath + 'test/bastion/test-constants.js',
            basePath + 'app/assets/javascripts/bastion/**/*.html',

            // Load modules first
            'app/assets/javascripts/' + pluginName + '/**/*.module.js',
            'app/assets/javascripts/' + pluginName + '/**/*.js',
            'app/assets/javascripts/' + pluginName + '/**/*.html',

            basePath + '../babel-polyfill/dist/polyfill.js',
            basePath + 'test/test-mocks.module.js',
            'test/**/*test.js'
        ],
        ngHtml2JsPreprocessor: {
            cacheIdFromPath: function (filepath) {
                return filepath.replace(/app\/assets\/javascripts\/bastion\w*\//, '');
            }
        }
    },
    server: {
        autoWatch: true,
        singleRun: false
    },
    unit: {
        singleRun: true
    },
    ci: {
        reporters: ['progress', 'coverage'],
        preprocessors: {
            'app/assets/javascripts/**/*.js': ['coverage']
        },
        coverageReporter: {
            type: 'cobertura',
            dir: 'coverage/'
        }
    }
}

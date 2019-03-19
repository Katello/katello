module.exports = {
    options: {
        configFile: __dirname + '/../eslint.yaml',
        ignorePath: __dirname + '/../.eslintignore',
        quiet: true
    },
    target: [
        'Gruntfile.js',
        'app/assets/javascripts/**/*.js',
        '!app/assets/javascripts/bastion/i18n/translations.js'
    ]
};

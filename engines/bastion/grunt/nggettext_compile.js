var basePath = __dirname + '/../',
    pluginName = process.cwd().split('/').pop();

module.exports = {
    options: {
        module: 'Bastion.i18n'
    },
    bastion: {
        src: ['app/assets/javascripts/**/*.po'],
        dest: 'app/assets/javascripts/' + pluginName + '/i18n/translations.js'
    }
};

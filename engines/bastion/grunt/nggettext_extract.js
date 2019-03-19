var basePath = __dirname + '/../',
    pluginName = process.cwd().split('/').pop();

module.exports = {
    bastion: {
        options: {
            markerName: 'translate'
        },
        src: ['app/assets/javascripts/**/*.html', 'app/assets/javascripts/**/*.js'],
        dest: 'app/assets/javascripts/' + pluginName + '/i18n/' + pluginName + '.pot'
    }
};

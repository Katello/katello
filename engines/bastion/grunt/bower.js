module.exports = {
    update: {
        options: {
            targetDir: 'vendor/assets',
            copy: true,
            layout: function (type) {
                // We provide a bit of customization here by allowing
                // explicit path declarations if the component is included
                // in the type. This is handy for sub-nesting within folders
                // for a component. Fallback is 'byType'.
                return require('path').join(type);
            },
            clearBowerDir: true
        }
    }
}

angular.module('alchemy').directive('alchInput', function() {
    return {
        replace: true,
        template: '<div class="control-group">' +
                    '<div class="label">' +
                      '<label>{{ label }}</label>' +
                    '</div>' +
                    '<div class="input">' +
                      '<span class="value">{{ model }}</span>' +
                    '</div>' +
                  '</div>',
        scope: {
            model: '=alchInput',
            label: '@label'
        },
        controller: ['$scope', function($scope) {
        }]
    };
});

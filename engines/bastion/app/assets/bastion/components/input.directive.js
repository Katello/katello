angular.module('alchemy').directive('alchInput', function() {
    return {
        replace: true,
        transclude: true,
        template: '<div class="control-group">' +
                    '<div class="label">' +
                      '<label>{{ label }}</label>' +
                    '</div>' +
                    '<div class="input" ng-transclude>' +
                    '</div>' +
                  '</div>',
        scope: {
            label: '@label'
        }
    };
});

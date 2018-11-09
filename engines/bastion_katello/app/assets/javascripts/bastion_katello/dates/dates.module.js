/**
 * @ngdoc module
 * @name  Bastion.dates
 *
 * @description
 *   Module providing directives for formatting dates.
 */
angular.module('Bastion.dates', [
    'Bastion',
    'react'
]);

angular.module('Bastion.dates').factory('componentRegistry',
    ['$window', function($window) {
        return $window.tfm.componentRegistry;
    }]
);

angular.module('Bastion.dates').factory('dateComponent',
    ['componentRegistry', function(componentRegistry) {
        return function(componentName) {
            var dateWrapper = componentRegistry.wrapperFactory().with('i18n').wrapper;
            return dateWrapper(componentRegistry.getComponent(componentName).type);
        };
    }]
);

angular.module('Bastion.dates').directive('date',
    ['dateComponent', 'reactDirective', function(dateComponent, reactDirective) {
        return reactDirective(dateComponent('IsoDate'), ['date']);
    }]
);

angular.module('Bastion.dates').directive('shortDateTime',
    ['dateComponent', 'reactDirective', function(dateComponent, reactDirective) {
        return reactDirective(dateComponent('ShortDateTime'), ['date', 'seconds']);
    }]
);

angular.module('Bastion.dates').directive('longDateTime',
    ['dateComponent', 'reactDirective', function(dateComponent, reactDirective) {
        return reactDirective(dateComponent('LongDateTime'), ['date', 'seconds']);
    }]
);

angular.module('Bastion.dates').directive('relativeDate',
    ['dateComponent', 'reactDirective', function(dateComponent, reactDirective) {
        return reactDirective(dateComponent('RelativeDateTime'), ['date']);
    }]
);

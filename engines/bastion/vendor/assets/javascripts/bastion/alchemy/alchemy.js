'use strict';
    
angular.module('alch-templates', []);
angular.module('alchemy', ['alch-templates']);

'use strict';

angular.module('alchemy').directive('onEnter', function() {
    return {
        scope: true,

        link: function(scope, element, attrs) {
            element.bind('keydown keypress', function(event) {
                if(event.which === 13) {
                    scope.$apply(attrs.onEnter);
                }
            });
        }
    };
});

angular.module('Bastion.content-hosts').directive('registerOsClient', function () {
    return {
    restrict: 'E',
    scope: {
      userOs: '='
    },
    link: function($scope) {
        $scope.$watch('userOs', function(userOs) {
            if (userOs && userOs.length) {
                $scope.dynamicTemplateUrl = 'content-hosts/views/register-' + userOs + '.html';
            }
        });
    },

    template: '<ng-include src="dynamicTemplateUrl"></ng-include>'
  };
});

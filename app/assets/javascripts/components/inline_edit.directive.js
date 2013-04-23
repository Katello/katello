angular.module('Katello').directive('inlineEdit', function() {
    return {
        replace: true,
        templateUrl: 'inline-edit.html',
        controller: ['$scope', function($scope) {
            var previousValue;
          
            $scope.edit = function() {
                $scope.editMode = true;
                previousValue = $scope.model;
            };

            $scope.save = function() {
                $scope.editMode = false;
            };

            $scope.cancel = function() {
                $scope.editMode = false;
                $scope.model = previousValue;
            };
        }]
    };
});

angular.module('Katello').directive('inlineEditText', function() {
    return {
        template: '<input type="text" on-enter="save()" ng-model="model" ng-show="editMode">' + 
                  '<span inline-edit></span>',
        scope: {
            model: '=inlineEditText',
        },
        controller: ['$scope', function($scope) {
        }]
    };
});

angular.module('Katello').directive('inlineEditTextarea', function() {
    return {
        template: '<textarea on-enter="save()" rows=8 cols=40 ng-model="model" ng-show="editMode"></textarea>' + 
                  '<span inline-edit></span>',
        scope: {
            model: '=inlineEditTextarea',
        },
        controller: ['$scope', function($scope) {
        }]
    };
});

angular.module('Katello').directive('inlineEditSelect', function() {
    return {
        template: '<select on-enter="save()" ng-model="model" ng-show="editMode" ng-options="option.name for option in options">' + 
                  '</select>' + 
                  '<span inline-edit></span>',
        scope: {
            model: '=inlineEditSelect',
            options: '=inlineEditSelectOptions'
        },
        controller: ['$scope', function($scope) {
        }]
    };
});

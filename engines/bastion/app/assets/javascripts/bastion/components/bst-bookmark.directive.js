/**
* @ngdoc directive
* @name Bastion.components.directive:bookmark
*
* @requires BstBookmark
*
* @description
* Provides the bookmarked items for a dropdown menu
*/
angular.module('Bastion.components').directive('bstBookmark', ['BstBookmark', function (BstBookmark) {
    return {
        scope: {
            controllerName: '=',
            query: '='
        },
        templateUrl: 'components/views/bst-bookmark.html',
        controller: ['$scope', 'translate', function ($scope, translate) {
            $scope.newBookmark = {};

            $scope.load = function () {
                BstBookmark.queryPaged({search: 'controller=' + $scope.controllerName}, function (response) {
                    $scope.bookmarks = response.results;
                });
            };

            $scope.add = function () {
                if (angular.isDefined($scope.query)) {
                    $scope.newBookmark.query = $scope.query.trim();
                }
                $scope.openModal();
            };

            $scope.save = function () {
                var params, success, error;

                params = {
                    name: $scope.newBookmark.name,
                    query: $scope.newBookmark.query,
                    public: $scope.newBookmark.public,
                    controller: $scope.controllerName
                };

                success = function () {
                    $scope.bookmarks = $scope.load();
                    $scope.$parent.successMessages = [translate('Bookmark was successfully created.')];
                };

                error = function (response) {
                    $scope.$parent.errorMessages = [response.data.error.full_messages];
                };

                BstBookmark.create(params, success, error);
            };

            $scope.setQuery = function (bookmark) {
                $scope.query = bookmark.query;
            };

            $scope.load();
        }]
    };
}]);

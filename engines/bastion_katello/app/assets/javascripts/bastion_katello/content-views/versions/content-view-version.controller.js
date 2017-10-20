(function () {
    'use strict';

    /**
     * @ngdoc controller
     * @name  Bastion.content-views.versions.controller:ContentViewVersion
     *
     * @description
     *   Handles fetching of a content view version based on the route ID and putting it
     *   on the scope.
     */
    function ContentViewVersionController($scope, ContentViewVersion) {

        $scope.version = ContentViewVersion.get({id: $scope.$stateParams.versionId});

        $scope.hasRepositories = function (version, type) {
            var found;

            found = _.find(version.repositories, function (repository) {
                return repository['content_type'] === type;
            });

            return found;
        };

        $scope.hasErrata = function (version) {
            var found = false;

            if (version['errata_counts'] &&
                version['errata_counts'].total &&
                version['errata_counts'].total !== 0) {
                return true;
            }
            return found;
        };

    }

    angular
        .module('Bastion.content-views.versions')
        .controller('ContentViewVersionController', ContentViewVersionController);

    ContentViewVersionController.$inject = ['$scope', 'ContentViewVersion'];

})();

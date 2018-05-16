/**
 * @ngdoc controller
 * @name  Bastion.content-views.versions.controller:ContentViewVersion
 *
 * @requires $scope
 * @requires $state
 * @requires $q
 * @requires translate
 * @requires ContentViewVersion
 * @requires Notification
 *
 * @description
 *   Handles fetching of a content view version based on the route ID and putting it
 *   on the scope.
 */

angular.module('Bastion.content-views.versions').controller('ContentViewVersionController',
    ['$scope', '$state', '$q', 'translate', 'ContentViewVersion', 'Notification',
    function ($scope, $state, $q, translate, ContentViewVersion, Notification) {

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

        $scope.save = function (version) {
            var deferred = $q.defer();

            version.$update(function (response) {
                deferred.resolve(response);
                Notification.setSuccessMessage(translate('Content View version updated'));

            }, function (response) {
                deferred.reject(response);
                Notification.setErrorMessage(response.data.displayMessage);
            });

            return deferred.promise;
        };
    }]
);

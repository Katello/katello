/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostRegisterController
 *
 * @requires $scope
 * @requires $location
 * @requires Capsule
 * @requires Organization
 * @requires CurrentOrganization
 * @requires BastionConfig
 *
 * @description
 *     Provides values to populate the code commands for registering a content host.
 */
angular.module('Bastion.content-hosts').controller('ContentHostRegisterController',
    ['$scope', '$location', 'Capsule', 'Organization', 'CurrentOrganization', 'BastionConfig',
    function ($scope, $location, Capsule, Organization, CurrentOrganization, BastionConfig) {

        $scope.organization = Organization.get({id: CurrentOrganization});
        $scope.consumerCertRPM = BastionConfig.consumerCertRPM;
        $scope.katelloHostname = $location.host();
        $scope.noCapsulesFound = true;

        $scope.capsules = Capsule.queryUnpaged(function (data) {
            var defaultCapsule = _.filter(data.results, function (result) {
                var featureNames = _.map(result.features, 'name');
                return _.includes(featureNames, 'Pulp');
            });

            $scope.noCapsulesFound = _.isEmpty(data.results);
            $scope.selectedCapsule = _.isEmpty(defaultCapsule) ? data.results[0] : defaultCapsule[0];
        });
        $scope.hideSwitcher = true;

        $scope.hostname = function (url) {
            if (url) {
                url = url.split('://')[1].split(':')[0];
            }

            return url;
        };

    }]
);

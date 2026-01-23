/**
 * @ngdoc object
 * @name  Bastion.activation-keys.controller:NewActivationKeyController
 *
 * @requires $scope
 * @requires $q
 * @requires FormUtils
 * @requires ActivationKey
 * @requires Organization
 * @requires CurrentOrganization
 * @requires ContentView
 * @requires translate
 *
 * @description
 *   Controls the creation of an empty ActivationKey object for use by sub-controllers.
 */
angular.module('Bastion.activation-keys').controller('NewActivationKeyController',
    ['$scope', '$q', 'FormUtils', 'ActivationKey', 'Organization', 'CurrentOrganization', 'ContentView', 'translate',
    function ($scope, $q, FormUtils, ActivationKey, Organization, CurrentOrganization, ContentView, translate) {

        function success() {
            $scope.transitionTo('activation-key.info', {activationKeyId: $scope.activationKey.id});
        }

        // Labels so breadcrumb strings can be translated
        $scope.label = translate('New Activation Key');

        function error(response) {
            $scope.working = false;
            angular.forEach(response.data.errors, function (errors, field) {
                $scope.activationKeyForm[field].$setValidity('server', false);
                $scope.activationKeyForm[field].$error.messages = errors;
            });
        }

        $scope.activationKey = $scope.activationKey || new ActivationKey();
        $scope.activationKey['unlimited_hosts'] = true;

        $scope.panel = {loading: false};
        $scope.organization = CurrentOrganization;

        // Function for React component to call when assignments change
        $scope.updateContentViewEnvironments = function(assignments) {
            $scope.contentViewEnvironmentLabels = assignments
                .filter(function(a) {
                    return a.selectedCV && a.selectedEnv && a.selectedEnv.length > 0;
                })
                .map(function(a) {
                    var env = a.selectedEnv[0];
                    var cv = a.contentView;
                    var isLibraryEnv = env.lifecycle_environment_library || env.library;
                    var isDefaultCV = cv.content_view_default || cv.default;

                    // Match backend label logic
                    if (isDefaultCV && isLibraryEnv) {
                        return env.label;
                    }
                    return env.label + '/' + cv.label;
                });
        };

        $scope.save = function (activationKey) {
            activationKey['organization_id'] = CurrentOrganization;

            // Add content view environment labels if any were selected
            if ($scope.contentViewEnvironmentLabels && $scope.contentViewEnvironmentLabels.length > 0) {
                activationKey['content_view_environments'] = $scope.contentViewEnvironmentLabels;
            }

            activationKey.$save(success, error);
        };

    }]
);

/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:ContentViewPromotionController
 *
 * @requires $scope
 * @requires $q
 * @requires translate
 * @requires ContentViewVersion
 * @requires Organization
 * @requires CurrentOrganization
 * @requires Notification
 *
 * @description
 *   Provides the functionality specific to ContentViews for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.content-views').controller('ContentViewPromotionController',
    ['$scope', '$q', 'translate', 'ContentViewVersion', 'Organization', 'CurrentOrganization', 'Notification',
    function ($scope, $q, translate, ContentViewVersion, Organization, CurrentOrganization, Notification) {

        function success() {
            var message = translate('Successfully initiated promotion of %cv version %ver to %env.');
            message = message.replace('%cv', $scope.contentView.name).replace('%env', $scope.selectedEnvironment.name);
            message = message.replace('%ver', $scope.version.version);
            $scope.promoting = false;
            Notification.setSuccessMessage(message);
            $scope.transitionTo('content-view.versions', {contentViewId: $scope.contentView.id});
        }

        function failure(response) {
            $scope.promoting = false;
            Notification.setErrorMessage(response.data.displayMessage);
        }

        $scope.promotion = {};
        $scope.working = false;

        $scope.version = ContentViewVersion.get({id: $scope.$stateParams.versionId});
        $scope.currentOrganization = CurrentOrganization;
        $scope.availableEnvironments = Organization.paths({id: CurrentOrganization, 'permission_type': 'promotable'});
        $scope.suggestedEnvironments = [];

        $q.all([$scope.availableEnvironments.$promise, $scope.version.$promise]).then(function (args) {
            var environments = args[0],
                version = args[1];

            angular.forEach(environments, function (path) {
                angular.forEach(path.environments, function (environment) {
                    environment.disabled = $scope.checkDisabled(environment, version.environments);
                    if ($scope.checkSuggested(environment, version.environments)) {
                        environment.iconClass = 'fa fa-star';
                    }
                });
            });

            $scope.working = true;
        });

        $scope.checkDisabled = function (env, environments) {
            var enabled = false,
                envIds = _.map(environments, 'id');

            if (!env.prior) {
                env.prior = {};
            }

            if (envIds.indexOf(env.id) !== -1) {
                // if version is already promoted to the environment
                enabled = false;
            } else {
                enabled = true;
            }

            return !enabled;
        };

        $scope.checkSuggested = function (env, environments) {
            var suggest = false,
                envIds = _.map(environments, 'id');

            if (envIds.indexOf(env.id) === -1) {
                // if version is not promoted to the environment
                if (environments.length === 0 && env.library) {
                    // if version is not yet promoted to any environment & environment is library
                    suggest = true;
                    $scope.suggestedEnvironments.push(env);
                } else if (envIds.indexOf(env.prior.id) !== -1) {
                    // if environment is a successor an existing environment
                    suggest = true;
                    $scope.suggestedEnvironments.push(env);
                }
            }
            return suggest;
        };

        $scope.promote = function () {
            $scope.promoting = true;
            ContentViewVersion.promote({id: $scope.version.id,
                                        'environment_id': $scope.selectedEnvironment.id,
                                        'description': $scope.description,
                                        force: true},
                success, failure);
        };

        $scope.verifySelection = function () {
            if ($scope.suggestedEnvironments.indexOf($scope.selectedEnvironment) !== -1) {
                $scope.promote();
            } else {
                $scope.openModal();
            }
        };

        $scope.suggestedEnvironmentMessage = function () {
            var envs = _.uniq(_.map($scope.suggestedEnvironments, 'name')),
                message = "";

            if (envs.length === 0) {
                message = "There are no environments suggested in the promotion path.";
            } else if (envs.length === 1) {
                message = "Suggested environment is: ".concat(envs[0]);
            } else {
                message = "Suggested environments are: ".concat(envs.join(', '));
            }

            return message;
        };
    }]
);

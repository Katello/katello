/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:ContentViewDetailsController
 *
 * @requires $scope
 * @requires $q
 * @requires ContentView
 * @requires translate
 * @requires ApiErrorHandler
 * @requires Notification
 *
 * @description
 *   Provides the functionality specific to the Content View Details page.
 */
angular.module('Bastion.content-views').controller('ContentViewDetailsController',
    ['$scope', '$q', 'ContentView', 'translate', 'ApiErrorHandler', 'Notification', 'RepositoryTypesService',
    function ($scope, $q, ContentView, translate, ApiErrorHandler, Notification, RepositoryTypesService) {
        $scope.saveSuccess = function () {
            Notification.setSuccessMessage(translate('Content View updated.'));
        };

        $scope.saveError = function (response) {
            angular.forEach(response.data.errors, function (errorMessage) {
                Notification.setErrorMessage(translate("An error occurred updating the Content View: ") + errorMessage);
            });
        };

        $scope.panel = {
            error: false,
            loading: true
        };

        $scope.repositoryTypeEnabled = RepositoryTypesService.repositoryTypeEnabled;

        $scope.taskTypes = {
            publish: "Actions::Katello::ContentView::Publish",
            promotion: "Actions::Katello::ContentView::Promote",
            deletion: "Actions::Katello::ContentView::Remove",
            incrementalUpdate: "Actions::Katello::ContentView::IncrementalUpdates",
            export: "Actions::Katello::ContentViewVersion::Export"
        };

        $scope.copy = function (newName) {
            ContentView.copy({id: $scope.contentView.id, 'content_view': {name: newName}}, function (response) {
                $scope.transitionTo('content-view.info', {contentViewId: response.id});
            }, function (response) {
                Notification.setErrorMessage(response.data.displayMessage);
            });
        };

        $scope.save = function (contentView) {
            return contentView.$update($scope.saveSuccess, $scope.saveError);
        };

        $scope.fetchContentView = function () {
            $scope.contentView = ContentView.get({id: $scope.$stateParams.contentViewId}, function () {
                $scope.panel.loading = false;
            }, function (response) {
                $scope.panel.loading = false;
                ApiErrorHandler.handleGETRequestErrors(response, $scope);
            });
        };

        $scope.getAvailableVersions = function (paramContentView) {
            var deferred, latestVersion, latest;

            if (paramContentView.latest_version) {
                latestVersion = translate('Always Use Latest (Currently %s)').replace('%s', paramContentView.latest_version.toString());
                latest = [{id: "latest", version: latestVersion}];
            } else {
                return [];
            }

            if (angular.isUndefined(paramContentView.versions)) {
                deferred = $q.defer();

                ContentView.get({id: paramContentView.id}, function (response) {
                    deferred.resolve(latest.concat(response.versions.reverse()));
                });

                return deferred.promise;
            }
            return latest.concat(paramContentView.versions.reverse());
        };

        $scope.fetchContentView();
    }]
);

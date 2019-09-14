/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:NewFilterController
 *
 * @requires $scope
 * @requires translate
 * @requires Filter
 * @requires Rule
 * @requires Notification
 *
 * @description
 */
angular.module('Bastion.content-views').controller('NewFilterController',
    ['$scope', 'translate', 'Filter', 'Rule', 'Notification', function ($scope, translate, Filter, Rule, Notification) {
        var filterType;

        function transitionToDetails(filter) {
            var state = '';

            if (filterType === 'erratumId') {
                state = 'content-view.yum.filter.erratum.available';
            } else if (filterType === 'erratumDateType') {
                state = 'content-view.yum.filter.erratum.dateType';
            } else if (filterType === 'rpm') {
                state = 'content-view.yum.filter.rpm.details';
            } else if (filterType === 'package_group') {
                state = 'content-view.yum.filter.package_group.available';
            } else if (filterType === 'modulemd') {
                state = 'content-view.yum.filter.module-stream.available';
            } else if (filterType === 'docker') {
                state = 'content-view.docker.filter.tag.details';
            }

            $scope.$emit('filter.created');
            $scope.transitionTo(state, {filterId: filter.id, contentViewId: filter['content_view'].id});
        }

        function addErrataDateTypeRule(filter) {
            var rule = new Rule({
                    types: ['security', 'enhancement', 'bugfix']
                }),
                addSuccess, error;

            addSuccess = function () {
                transitionToDetails(filter);
            };

            error = function (response) {
                Notification.setErrorMessage(response.data.displayMessage);
            };

            rule.$save({filterId: filter.id}, addSuccess, error);
        }

        function success(filter) {
            if (filterType === 'erratumDateType') {
                addErrataDateTypeRule(filter);
            } else {
                transitionToDetails(filter);
            }
        }

        function failure(response) {
            $scope.working = false;
            angular.forEach(response.data.errors, function (errors, field) {
                $scope.filterForm[field].$setValidity('server', false);
                $scope.filterForm[field].$error.messages = errors;
            });
        }

        $scope.filter = new Filter();
        $scope.working = false;

        if ($scope.stateIncludes('content-view.yum')) {
            $scope.filterChoices = [
                {id: 'rpm', name: translate('Package')},
                {id: 'package_group', name: translate('Package Group')},
                {id: 'erratumId', name: translate('Erratum - by ID')},
                {id: 'erratumDateType', name: translate('Erratum - Date and Type')},
                {id: 'modulemd', name: translate('Module Stream')}
            ];
        } else {
            $scope.filter.type = "docker";
            $scope.filterChoices = [
                {id: 'docker', name: translate('Container Image Tag')}
            ];
        }

        $scope.save = function (filter, contentView) {
            filterType = filter.type;

            if (filter.type === 'erratumId' || filter.type === 'erratumDateType') {
                filter.type = 'erratum';
            }

            filter.$save({'content_view_id': contentView.id}, success, failure);
        };

    }]
);

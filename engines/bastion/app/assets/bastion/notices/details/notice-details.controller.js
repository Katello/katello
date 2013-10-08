/**
 * Copyright 2013 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 */

/**
 * @ngdoc object
 * @name  Bastion.notices.controller:NoticeDetailsController
 *
 * @requires $scope
 * @requires $state
 * @requires $q
 * @requires Notice
 *
 * @description
 *   Provides the functionality for the notice details action pane.
 */

angular.module('Bastion.notices').controller('NoticeDetailsController',
    ['$scope', '$state', '$q', 'i18nFilter', 'Notice',
    function($scope, $state, $q, i18nFilter, Notice) {

        $scope.notice = Notice.get({id: $scope.$stateParams.noticeId}, function(notice) {
            $scope.$watch("table.rows.length > 0", function() {
                $scope.table.replaceRow(notice);
            });

            $scope.$broadcast('notice.loaded', notice);
        });

        $scope.transitionToInfo = function(notice) {
            $scope.transitionTo('notices.details.info', {noticeId: notice.id});
        };

        $scope.save = function(notice) {
            var deferred = $q.defer();

            notice.$update(function(response) {
                deferred.resolve(response);
                $scope.saveSuccess = true;
            }, function(response) {
                deferred.reject(response);
                $scope.saveError = true;
                $scope.errors = response.data.errors;
            });

            return deferred.promise;
        };

        /*
        $scope.transitionTo = function(state, params) {
            var noticeId = $scope.$stateParams.noticeId;

            if ($scope.notice && $scope.notice.uuid) {
                noticeId = $scope.notice.uuid;
            }

            if (noticeId) {
                params = params ? params : {};
                params.noticeId  = noticeId;
                $state.transitionTo(state, params);
                return true;
            }
            return false;
        };
        */

        /*
        $scope.stateStartsWith = function(stateName) {
            return $state.current.name.indexOf(stateName) === 0;
        };
        */

        $scope.removeNotice = function (notice) {
            var noticeId = notice.id;

            notice.$delete(function() {
                $scope.removeRow(noticeId);
                $scope.saveSuccess = true;
                $scope.successMessages = [i18nFilter('Notice %s has been deleted.'.replace('%s', noticeId))];
                $scope.transitionTo('notices.index');
            });
        };
    }]
);

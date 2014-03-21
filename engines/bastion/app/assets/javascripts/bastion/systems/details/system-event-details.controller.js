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
 * @name  Bastion.systems.controller:SystemEventDetailsController
 *
 * @requires $scope
 * @requires SystemTask
 *
 * @description
 *   Provides the functionality for the details of a system event.
 */
angular.module('Bastion.systems').controller('SystemEventDetailsController',
    ['$scope', 'SystemTask',
    function ($scope, SystemTask) {
        var eventId, systemId, setEvent;

        eventId = $scope.$stateParams.eventId;
        systemId = $scope.$stateParams.systemId;

        setEvent = function (event) {
            $scope.event = event;
        };

        $scope.event = SystemTask.get({id: eventId, systemId: systemId}, function (data) {
            if (data.pending) {
                SystemTask.poll(data, setEvent);
            }
        });
    }
]);

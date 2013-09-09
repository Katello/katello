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
 * @name  Bastion.systems.controller:SystemErrataController
 *
 * @requires $scope
 * @requires SystemErratum
 * @requires SystemTask
 * @requires Nutupane
 *
 * @description
 *   Provides the functionality for the system package list and actions.
 */
/*jshint camelcase:false*/
angular.module('Bastion.systems').controller('SystemErrataController',
    ['$scope', 'SystemErratum', 'SystemTask', 'Nutupane',
    function($scope, SystemErratum, SystemTask, Nutupane) {
        var errataNutupane;

        //Used to transition from errata details to errata
        $scope.transitionToIndex = function() {
            $scope.transitionTo('systems.details.errata.index');
        };

        errataNutupane = new Nutupane(SystemErratum, {'id': $scope.$stateParams.systemId}, 'get');
        $scope.errataTable = errataNutupane.table;
        $scope.errataTable.errataFilterTerm = "";
        $scope.errataTable.errataCompare = function(item){
            var searchText = $scope.errataTable.errataFilterTerm;
            return item.type.indexOf(searchText)  >= 0 ||
                item.errata_id.indexOf(searchText) >= 0 ||
                item.title.indexOf(searchText) >= 0;
        };

        $scope.errataTable.transitionToErratum = function(erratum) {
            $scope.erratum = erratum;
            $scope.transitionTo('systems.details.errata.details', {errataId: erratum.errata_id});
        };

        $scope.openEventInfo = function(event) {
            $scope.transitionTo('systems.details.events.details', {eventId: event.id});
        };

        $scope.applySelected = function() {
            var selected, errataIds = [];
            selected = $scope.errataTable.getSelected();
            if(selected.length > 0){
                angular.forEach(selected, function(value){
                    errataIds.push(value.errata_id);
                });
                SystemErratum.apply({uuid: $scope.system.uuid, errata_ids: errataIds},
                                   function(task) {
                                     $scope.errataTable.selectAll(false);
                                     $scope.openEventInfo(task);
                                   });
            }
        };
    }
]);

/**
 * Copyright 2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/

(function () {
    'use strict';

    /**
     * @ngdoc controller
     * @name  Bastion.environments.controller:EnvironmentContent
     *
     * @description
     *   Enter a description!
     */
    function EnvironmentContentController($scope, Nutupane, Erratum) {
        var nutupane, contentTypes, currentState;

        currentState = $scope.$state.current.name.split('.').pop();

        contentTypes = {
            'errata': Erratum
        };

        nutupane = new Nutupane(contentTypes[currentState], {
                'environment_id': $scope.$stateParams.environmentId
            }
        );
        nutupane.masterOnly = true;

        $scope.nutupane = nutupane;
        $scope.detailsTable = nutupane.table;
    }

    angular
        .module('Bastion.environments')
        .controller('EnvironmentContentController', EnvironmentContentController);

    EnvironmentContentController.$inject = ['$scope', 'Nutupane', 'Erratum'];

})();

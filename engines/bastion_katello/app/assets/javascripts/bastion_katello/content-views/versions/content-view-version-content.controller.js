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
     * @name  Bastion.content-views.versions.controller:ContentViewVersionContent
     *
     * @description
     *   Handles fetching content view version content and populating Nutupane based on the current
     *   ui-router state.
     */
    function ContentViewVersionContentController($scope, Nutupane, Package, Erratum, PackageGroup, PuppetModule, Repository) {
        var nutupane, contentTypes, currentState, params;

        currentState = $scope.$state.current.name.split('.').pop();

        contentTypes = {
            'repositories': {
                type: Repository
            },
            'packages': {
                type: Package
            },
            'package-groups': {
                type: PackageGroup,
                params: {
                    'sort_by': 'name',
                    'sort_order': 'DESC'
                }
            },
            'errata': {
                type: Erratum
            },
            'puppet-modules': {
                type: PuppetModule
            }
        };

        params = angular.extend({'content_view_version_id': $scope.$stateParams.versionId}, contentTypes[currentState].params);
        nutupane = new Nutupane(contentTypes[currentState].type, params, 'queryPaged');
        nutupane.masterOnly = true;

        $scope.nutupane = nutupane;
        $scope.detailsTable = nutupane.table;
    }

    angular
        .module('Bastion.content-views.versions')
        .controller('ContentViewVersionContentController', ContentViewVersionContentController);

    ContentViewVersionContentController.$inject = ['$scope', 'Nutupane', 'Package', 'Erratum',
                                                   'PackageGroup', 'PuppetModule', 'Repository'];

})();

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
*/

/**
 * @ngdoc object
 * @name  Bastion.errata.controller:ErrataController
 *
 * @requires $scope
 * @requires $location
 * @requires Nutupane
 * @requires Erratum
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality specific to errata for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.errata').controller('ErrataController',
    ['$scope', '$location', 'Nutupane', 'Erratum', 'Repository', 'CurrentOrganization', 'translate',
    function ($scope, $location, Nutupane, Erratum, Repository, CurrentOrganization, translate) {

        var params = {
            'organization_id':  CurrentOrganization,
            'search':           $location.search().search || "",
            'sort_by':          'updated',
            'sort_order':       'DESC',
            'paged':            true
        };

        var nutupane = $scope.nutupane = new Nutupane(Erratum, params);
        $scope.table = nutupane.table;
        $scope.removeRow = nutupane.removeRow;

        $scope.table.closeItem = function () {
            $scope.transitionTo('errata.index');
        };

        $scope.repository = {name: translate('All Repositories'), id: 'all'};

        Repository.queryUnpaged({'organization_id': CurrentOrganization, 'content_type': 'yum'}, function (response) {
            $scope.repositories = [$scope.repository];
            $scope.repositories = $scope.repositories.concat(response.results);
        });

        $scope.$watch('repository', function (repository) {
            var params = nutupane.getParams();

            if (repository.id === 'all') {
                params['repository_id'] = null;
                nutupane.setParams(params);
            } else {
                params['repository_id'] = repository.id;
                nutupane.setParams(params);
            }

            nutupane.refresh();
        });

    }]
);

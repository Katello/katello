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

describe('Controller: ActivationKeyAddSystemGroupsController', function() {
    var $scope,
        ActivationKey,
        Nutupane,
        system_groups;

    beforeEach(module('Bastion.activation-keys', 'Bastion.system-groups', 'Bastion.test-mocks',
                      'activation-keys/details/views/activation-key-system-groups.html'));

    beforeEach(function() {
        Nutupane = function() {
            this.table = {
                showColumns: function() {}
            };
            this.get = function() {};
        };
        ActivationKey = {};
    });

    beforeEach(inject(function($controller, $rootScope, $location, $state, $injector) {
        $scope = $rootScope.$new();
        $q = $injector.get('$q');

        system_groups = {
            "total": 1,
            "subtotal": 1,
            "page": 1,
            "per_page": 20,
            "search": null,
            "sort": {
                "by": null,
                "order": null
            },
            "results": [
                {
                    "created_at": "2014-02-17T16:02:24Z",
                    "updated_at": "2014-02-17T16:02:24Z",
                    "name": "Employee",
                    "organization_id": 3,
                    "max_systems": -1,
                    "description": null,
                    "total_systems": 0,
                    "id": 14,
                    "permissions": {
                        "deletable": true,
                        "editable": true,
                        "systems_readable": true,
                        "system_editable": true
                    }
                }
            ]
        };

        $controller('ActivationKeyAddSystemGroupsController', {
            $scope: $scope,
            $q: $q,
            $location: $location,
            gettext: function() {},
            ActivationKey: ActivationKey,
            Nutupane: Nutupane
        });
    }));

    it('attaches the nutupane table to the scope', function () {
        expect($scope.systemGroupsTable).toBeDefined();
    });

});

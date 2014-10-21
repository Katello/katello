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

describe('Controller: HostCollectionAddContentHostsController', function() {
    var $scope,
        HostCollection,
        ContentHost,
        Nutupane;

    beforeEach(module('Bastion.host-collections', 'Bastion.test-mocks'));

    beforeEach(function() {
        Nutupane = function() {
            this.table = {
                showColumns: function() {},
                getSelected: function() {
                    return [{uuid: 'abcd'}]
                }
            };
            this.get = function() {};
        };
        HostCollection = {addContentHosts: function(){}};
        System = {};
    });

    beforeEach(inject(function($controller, $rootScope, $location) {
        $scope = $rootScope.$new();
        $scope.hostCollection = {id: 5};

        $controller('HostCollectionAddContentHostsController', {
            $scope: $scope,
            $location: $location,
            Nutupane: Nutupane,
            translate: function(){},
            HostCollection: HostCollection,
            ContentHost: ContentHost,
            CurrentOrganization: 'CurrentOrganization'
        });
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.addContentHostsTable).toBeDefined();
    });

    it('sets the closeItem function to not do anything', function() {
        spyOn($scope, "transitionTo");
        $scope.addContentHostsTable.closeItem();
        expect($scope.transitionTo).not.toHaveBeenCalled();
    });

    it('adds selected content hosts', function(){
        spyOn(HostCollection, "addContentHosts");
        $scope.addSelected();
        expected_params = {id: $scope.hostCollection.id, 'system_ids': ['abcd']};
        expect(HostCollection.addContentHosts).toHaveBeenCalledWith(expected_params, jasmine.any(Function), jasmine.any(Function));
    });

});

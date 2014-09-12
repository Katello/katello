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

describe('Controller: ContentHostsBulkActionHostCollectionsController', function() {
    var $scope, $q, translate, ContentHostBulkAction, HostCollection, Organization,
        Task, CurrentOrganization, Nutupane, $location, hostCollectionIds;

    beforeEach(module('Bastion.content-hosts', 'Bastion.test-mocks'));

    beforeEach(function() {
        hostCollectionIds =  ['hostCollection1', 'hostCollection2'];
        ContentHostBulkAction = {
            addHostCollections: function() {},
            removeHostCollections: function() {},
            installContent: function() {},
            updateContent: function() {},
            removeContent: function() {},
            removeContentHosts: function() {}
        };
        HostCollection = {
            query: function() {}
        };
        Organization = {
            query: function() {},
            autoAttach: function() {}
        };
        Nutupane = function() {
           this.getAllSelectedResults = function() {
               return {
                   included: { ids: hostCollectionIds }
               };
            };
            this.table = { };
        };
        Task = {
            query: function() {},
            poll: function() {}
        };
        translate = function() {};
        CurrentOrganization = 'foo';
    });

    beforeEach(inject(function($injector) {
        $location = $injector.get('$location');
    }));

    beforeEach(inject(function($controller, $rootScope, $q) {
        $scope = $rootScope.$new();
        $scope.setState = function(){};
        $scope.nutupane = new Nutupane();
        $scope.nutupane.getAllSelectedResults = function() {
            return {
                included: {
                    ids: ['sys1', 'sys2']
                }
            }
        };

        $controller('ContentHostsBulkActionHostCollectionsController', {$scope: $scope,
            $q: $q,
            $location: $location,
            ContentHostBulkAction: ContentHostBulkAction,
            HostCollection: HostCollection,
            Nutupane: Nutupane,
            translate: translate,
            Organization: Organization,
            CurrentOrganization: CurrentOrganization,
            Task: Task});
    }));

    it("can add host collections to multiple content hosts", function() {
        $scope.hostCollections = {
            action: 'add'
        };

        spyOn(ContentHostBulkAction, 'addHostCollections');
        $scope.performHostCollectionAction();

        expected = $scope.nutupane.getAllSelectedResults();
        expected.host_collection_ids = hostCollectionIds;
        expected.organization_id = CurrentOrganization;
        expect(ContentHostBulkAction.addHostCollections).toHaveBeenCalledWith(expected,
            jasmine.any(Function), jasmine.any(Function));
    });

    it("can remove host collections from multiple content hosts", function() {
        $scope.hostCollections = {
            action: 'remove'
        };

        spyOn(ContentHostBulkAction, 'removeHostCollections');
        $scope.performHostCollectionAction();

        expected = $scope.nutupane.getAllSelectedResults();
        expected.host_collection_ids = hostCollectionIds;
        expected.organization_id = CurrentOrganization;
        expect(ContentHostBulkAction.removeHostCollections).toHaveBeenCalledWith(expected,
            jasmine.any(Function), jasmine.any(Function));
    });

});

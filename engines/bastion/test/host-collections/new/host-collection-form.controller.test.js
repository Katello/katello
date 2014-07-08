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

describe('Controller: HostCollectionFormController', function() {
    var $scope,
        $httpBackend;

    beforeEach(module('Bastion.host-collections', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $http = $injector.get('$http'),
            $q = $injector.get('$q'),
            HostCollection= $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();
        $httpBackend = $injector.get('$httpBackend');


        $scope.hostCollectionForm = $injector.get('MockForm');
        $scope.table = {
            addRow: function() {},
            closeItem: function() {}
        };

        $controller('HostCollectionFormController', {
            $scope: $scope,
            $q: $q,
            CurrentOrganization: 'foo',
            HostCollection: HostCollection
        });
    }));

    it('should attach a new host collection resource on to the scope', function() {
        expect($scope.hostCollection).toBeDefined();
    });

    describe('should save a new host collection resource', function() {
        var hostCollection;

        beforeEach(function () {
            hostCollection = $scope.hostCollection;
            spyOn($scope.table, 'addRow');
            spyOn($scope, 'transitionTo');
            spyOn(hostCollection, '$save').andCallThrough();
        });

        afterEach(function () {
            expect(hostCollection.$save).toHaveBeenCalled();
            expect($scope.table.addRow).toHaveBeenCalled();
            expect($scope.transitionTo).toHaveBeenCalledWith('host-collections.details.info',
                {hostCollectionId: $scope.hostCollection.id})
        });

        it('with unlimited hosts', function () {
            hostCollection['max_content_hosts'] = 3;
            hostCollection.unlimited_content_hosts = true;
            $scope.save(hostCollection);
            expect(hostCollection['unlimited_content_hosts']).toBe(true);
        });

        it ('with a host limit', function () {
            hostCollection['max_content_hosts'] = 3;
            hostCollection.unlimited_content_hosts = false;
            $scope.save(hostCollection);
            expect(hostCollection['max_content_hosts']).toBe(3);
        });
    });

    it('should fail to save a new host collection resource', function() {
        var hostCollection = $scope.hostCollection;

        hostCollection.failed = true;
        spyOn(hostCollection, '$save').andCallThrough();
        $scope.save(hostCollection);

        expect(hostCollection.$save).toHaveBeenCalled();
        expect($scope.hostCollectionForm['name'].$invalid).toBe(true);
        expect($scope.hostCollectionForm['name'].$error.messages).toBeDefined();
    });
});

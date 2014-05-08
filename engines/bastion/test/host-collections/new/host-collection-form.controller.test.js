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

    it('should save a new host collection resource', function() {
        var hostCollection = $scope.hostCollection;

        spyOn($scope.table, 'addRow');
        spyOn($scope, 'transitionTo');
        spyOn(hostCollection, '$save').andCallThrough();
        $scope.save(hostCollection);

        expect(hostCollection.$save).toHaveBeenCalled();
        expect($scope.table.addRow).toHaveBeenCalled();
        expect($scope.transitionTo).toHaveBeenCalledWith('host-collections.details.info',
                                                         {hostCollectionId: $scope.hostCollection.id})
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

    it('should correctly determine unlimited', function() {
        $scope.hostCollection.max_content_hosts = -1;
        expect($scope.isUnlimited($scope.hostCollection)).toBe(true);
    });

    it('should correctly determine limited', function() {
        $scope.hostCollection.max_content_hosts = 0;
        expect($scope.isUnlimited($scope.hostCollection)).toBe(false);
    });

    it('should set unlimited to true if input changes if actually unlimited', function(){
        $scope.unlimited = false;
        $scope.hostCollection.max_content_hosts = -1;
       $scope.inputChanged($scope.hostCollection);
       expect($scope.unlimited).toBe(true);
    });

    it('should not set unlimited to true if input changes if not unlimited', function(){
       $scope.unlimited = false;
       $scope.hostCollection.max_content_hosts = 1;
       $scope.inputChanged($scope.hostCollection);
       expect($scope.unlimited).toBe(false);
    });

    it('should set max_content_hosts to 1 if unlimited unchecked', function(){
        $scope.unlimited = true;
        $scope.hostCollection.max_content_hosts = -1;
        $scope.unlimitedChanged($scope.hostCollection);

        expect($scope.unlimited).toBe(false);
        expect($scope.hostCollection.max_content_hosts).toBe(1);
    });

    it('should set max_content_hosts to -1 if unlimited checked', function(){
        $scope.unlimited = false;
        $scope.hostCollection.max_content_hosts = 0;
        $scope.unlimitedChanged($scope.hostCollection);

        expect($scope.unlimited).toBe(true);
        expect($scope.hostCollection.max_content_hosts).toBe(-1);
    });

});

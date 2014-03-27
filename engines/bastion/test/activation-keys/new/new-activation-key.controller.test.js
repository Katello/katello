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

describe('Controller: NewActivationKeyController', function() {
    var $scope,
        $httpBackend,
        paths,
        Organization,
        FormUtils,
        ContentView;

    beforeEach(module('Bastion.activation-keys', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $http = $injector.get('$http'),
            $q = $injector.get('$q'),
            ActivationKey= $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();
        $httpBackend = $injector.get('$httpBackend');


        $scope.activationKeyForm = $injector.get('MockForm');
        $scope.table = {
            addRow: function() {},
            closeItem: function() {}
        };

        paths = [[{name: "Library", id: 1}, {name: "Dev", id: 2}]]

        Organization = $injector.get('MockResource').$new();
        Organization.registerableEnvironments = function (params, callback) {
            var response = paths;

            if (callback) {
                callback.apply(this, response);
            }

            return response;
        };

        ContentView = $injector.get('MockResource').$new();
        ContentView.unPaged = function (params, callback) {};

        FormUtils = $injector.get('FormUtils');

        $controller('NewActivationKeyController', {
            $scope: $scope,
            $q: $q,
            FormUtils: FormUtils,
            ActivationKey: ActivationKey,
            Organization: Organization,
            CurrentOrganization: 'ACME',
            ContentView: ContentView
        });
    }));

    it('should attach a new activation key resource on to the scope', function() {
        expect($scope.activationKey).toBeDefined();
    });

    it('should fetch registerable environments', function() {
        expect($scope.environments).toBe(paths);
    });

    it('should save a new activation key resource', function() {
        var activationKey = $scope.activationKey;

        spyOn($scope.table, 'addRow');
        spyOn($scope, 'transitionTo');
        spyOn(activationKey, '$save').andCallThrough();
        $scope.save(activationKey);

        expect(activationKey.$save).toHaveBeenCalled();
        expect($scope.table.addRow).toHaveBeenCalled();
        expect($scope.transitionTo).toHaveBeenCalledWith('activation-keys.details.info',
                                                         {activationKeyId: $scope.activationKey.id})
    });

    it('should fail to save a new activation key resource', function() {
        var activationKey = $scope.activationKey;

        activationKey.failed = true;
        spyOn(activationKey, '$save').andCallThrough();
        $scope.save(activationKey);

        expect(activationKey.$save).toHaveBeenCalled();
        expect($scope.activationKeyForm['name'].$invalid).toBe(true);
        expect($scope.activationKeyForm['name'].$error.messages).toBeDefined();
    });

    it('should correctly determine unlimited', function() {
        $scope.activationKey.usage_limit = -1;
        expect($scope.isUnlimited($scope.activationKey)).toBe(true);
    });

    it('should correctly determine limited', function() {
        $scope.activationKey.usage_limit = 0;
        expect($scope.isUnlimited($scope.activationKey)).toBe(false);
    });

    it('should set unlimited to true if input changes if actually unlimited', function() {
       $scope.unlimited = false;
       $scope.activationKey.usage_limit = -1;
       $scope.inputChanged($scope.activationKey);
       expect($scope.unlimited).toBe(true);
    });

    it('should not set unlimited to true if input changes if not unlimited', function() {
       $scope.unlimited = false;
       $scope.activationKey.usage_limit = 1;
       $scope.inputChanged($scope.activationKey);
       expect($scope.unlimited).toBe(false);
    });

    it('should set usage_limit to 1 if unlimited unchecked', function() {
        $scope.unlimited = true;
        $scope.activationKey.usage_limit = -1;
        $scope.unlimitedChanged($scope.activationKey);

        expect($scope.unlimited).toBe(false);
        expect($scope.activationKey.usage_limit).toBe(1);
    });

    it('should set usage_limit to -1 if unlimited checked', function() {
        $scope.unlimited = false;
        $scope.activationKey.usage_limit = 0;
        $scope.unlimitedChanged($scope.activationKey);

        expect($scope.unlimited).toBe(true);
        expect($scope.activationKey.usage_limit).toBe(-1);
    });

    it('should labelize activation key name', function() {
        spyOn(FormUtils, 'labelize');
        $scope.activationKey.name = 'new name';
        $scope.$apply();
        expect(FormUtils.labelize).toHaveBeenCalled();
    });

    it("should fetch content views", function () {
        $httpBackend.expectGET('/organizations/default_label?name=Test+Resource').respond('changed_name');
        spyOn(ContentView, 'queryUnpaged');
        $scope.activationKey.environment = paths[0][0];
        $scope.$apply();

        expect(ContentView.queryUnpaged).toHaveBeenCalled();
    });

});

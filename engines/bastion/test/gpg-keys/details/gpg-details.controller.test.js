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

describe('Controller: GPGKeyDetailsController', function() {
    var $scope, translate;

    beforeEach(module(
        'Bastion.gpg-keys',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q'),
            GPGKey = $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {
            gpgKeyId: 1
        };

        translate = function(message) {
            return message;
        };

        $scope.removeRow = function(id) {};
        $scope.table = {
            replaceRow: function() {}
        };

        $controller('GPGKeyDetailsController', {
            $scope: $scope,
            GPGKey: GPGKey,
            $q: $q,
            translate: translate,
        });

    }));

    it('retrieves and puts a gpg key on the scope', function() {
        expect($scope.gpgKey).toBeDefined();
    });

    it('should save the gpg key and return a promise', function() {
        var promise = $scope.save($scope.gpgKey);

        expect(promise.then).toBeDefined();
    });

    it('should save the gpg key successfully', function() {
        $scope.save($scope.gpgKey);

        expect($scope.errorMessages.length).toBe(0);
        expect($scope.successMessages.length).toBe(1);
    });

    it('should fail to save the gpg key', function() {
        $scope.gpgKey.failed = true;
        $scope.save($scope.gpgKey);

        expect($scope.successMessages.length).toBe(0);
        expect($scope.errorMessages.length).toBe(1);
    });

    it('should provide a way to remove a gpg key', function() {
        spyOn($scope, 'removeRow');
        spyOn($scope, 'transitionTo');
        $scope.removeGPGKey($scope.gpgKey);
        expect($scope.transitionTo).toHaveBeenCalledWith('gpgKeys.index');
        expect($scope.removeRow).toHaveBeenCalledWith(1);
    });

});

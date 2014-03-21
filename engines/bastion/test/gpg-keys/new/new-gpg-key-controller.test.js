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

describe('Controller: NewGPGKeyController', function() {
    var $scope, gettext;

    beforeEach(module(
        'Bastion.gpg-keys',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q'),
            GPGKey = $injector.get('MockResource').$new(),
            CurrentOrganization = "Foo";

        $scope = $injector.get('$rootScope').$new();

        $scope.table = {
            addRow: function() {},
            closeItem: function() {}
        };

        $controller('NewGPGKeyController', {
            $scope: $scope,
            GPGKey: GPGKey,
            CurrentOrganization:CurrentOrganization,
        });

    }));

    it('should attach a  gpg key resource on to the scope', function() {
        expect($scope.gpgKey).toBeDefined();
    });

    it('should save a new gpg key resource', function() {
        spyOn($scope.table, 'addRow');
        spyOn($scope, 'transitionTo');
        $scope.uploadContent({"status": "success"});

        expect($scope.errorMessages).not.toBeDefined();
        expect($scope.uploadStatus).toBe('success');

        expect($scope.table.addRow).toHaveBeenCalled();
        expect($scope.transitionTo).toHaveBeenCalledWith('gpgKeys.index');
    });

    it('should error on a new gpg key resource', function() {
        spyOn($scope.table, 'addRow');
        spyOn($scope, 'transitionTo');
        $scope.uploadContent({"errors": "....", "displayMessage":"......"});

        expect($scope.errorMessages.length).toBe(1);
        expect($scope.uploadStatus).toBe('error');
        expect($scope.table.addRow).not.toHaveBeenCalled();
    });

});

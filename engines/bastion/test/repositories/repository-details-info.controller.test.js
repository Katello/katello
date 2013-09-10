/**
 * Copyright 2013 Red Hat, Inc.
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

describe('Controller: RepositoryDetailsInfoController', function() {
    var $scope,
        $q;

    beforeEach(module(
        'Bastion.repositories',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q'),
            GPGKey = $injector.get('MockResource'),
            Repository = $injector.get('MockResource');

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {
            productId: 1,
            repositoryId: 1
        };

        $controller('RepositoryDetailsInfoController', {
            $scope: $scope,
            $q: $q,
            Repository: Repository,
            GPGKey: GPGKey
        });
    }));

    it('retrieves and puts a repository on the scope', function() {
        expect($scope.repository).toBeDefined();
    });

    it('provides a method to retrieve available gpg keys', function() {
        var promise = $scope.gpgKeys();

        promise.then(function() {
            expect(gpgKeys).toBeDefined();
        });
    });

    it('should save the product and return a promise', function() {
        var promise = $scope.save($scope.repository);

        expect(promise.then).toBeDefined();
    });

    it('should save the system successfully', function() {
        $scope.save($scope.repository);

        expect($scope.saveSuccess).toBe(true);
    });

    it('should fail to save the system', function() {
        $scope.repository.failed = true;
        $scope.save($scope.repository);

        expect($scope.saveSuccess).toBe(false);
        expect($scope.saveError).toBe(true);
    });

    it('should provide a way to remove a repository', function() {
        spyOn($scope, 'transitionTo');
        $scope.removeRepository($scope.repository);

        expect($scope.transitionTo).toHaveBeenCalled();
    });

});

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

describe('Controller: RepositoryDetailsInfoController', function() {
    var $scope, $state, gettext, Repository;

    beforeEach(module(
        'Bastion.repositories',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q'),
            GPGKey = $injector.get('MockResource').$new(),
            Repository = $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();
        $state = $injector.get('$state');
        $scope.$stateParams = {
            productId: 1,
            repositoryId: 1
        };

        gettext = function(message) {
            return message;
        };

        Repository.sync = function(params, callback) {
            callback.call(this, {'state': 'running'});
        };

        $controller('RepositoryDetailsInfoController', {
            $scope: $scope,
            $state: $state,
            $q: $q,
            gettext: gettext,
            Repository: Repository,
            GPGKey: GPGKey
        });
    }));

    it('retrieves and puts a repository on the scope', function() {
        expect($scope.repository).toBeDefined();
    });

    it('provides a method to retrieve available gpg keys', function() {
        var promise = $scope.gpgKeys();

        expect(promise.then).toBeDefined();
        promise.then(function(gpgKeys) {
            expect(gpgKeys).toBeDefined();
            expect(gpgKeys).toContain({id: null});
        });

        $scope.$apply();
    });

    it('should save the repository and return a promise', function() {
        var promise = $scope.save($scope.repository);

        expect(promise.then).toBeDefined();
    });

    it('should save the repository successfully', function() {
        $scope.save($scope.repository);

        expect($scope.errorMessages.length).toBe(0);
        expect($scope.successMessages.length).toBe(1);
    });

    it('should fail to save the repository', function() {
        $scope.repository.failed = true;
        $scope.save($scope.repository);

        expect($scope.successMessages.length).toBe(0);
        expect($scope.errorMessages.length).toBe(1);
    });

    it('should set an error message if a file upload status is not success', function() {
        $scope.uploadContent('<pre>"There was an error"</pre>', true);

        expect($scope.uploadSuccessMessages.length).toBe(0);
        expect($scope.uploadErrorMessages.length).toBe(1);
    });

    it('should set the upload status to success and refresh the repository if a file upload status is success', function() {
        spyOn($scope.repository, '$get');
        $scope.uploadContent('<pre>{"status": "success"}</pre>', true);

        expect($scope.uploadErrorMessages.length).toBe(0);
        expect($scope.uploadSuccessMessages.length).toBe(1);
        expect($scope.repository.$get).toHaveBeenCalled();
    });

    it('should provide a method to determine if a repository is currently being syncd', function() {
        expect($scope.syncInProgress($scope.repository['sync_state'])).toBe(false);
    });

    it('should provide a method to determine if a repository is currently being syncd', function() {
        expect($scope.syncInProgress('running')).toBe(true);
    });

    it("provides a way to sync a repository", function() {
        spyOn($state, 'go');
        $scope.syncRepository($scope.repository);
        expect($state.go).toHaveBeenCalled();
    });
});

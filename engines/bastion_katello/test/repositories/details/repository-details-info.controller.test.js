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
    var $scope, $state, translate, repository;

    beforeEach(module(
        'Bastion.repositories',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q'),
            GPGKey = $injector.get('MockResource').$new(),
            Repository = $injector.get('MockResource').$new();

        repository = new Repository();

        $scope = $injector.get('$rootScope').$new();
        $state = $injector.get('$state');
        $scope.$stateParams = {
            productId: 1,
            repositoryId: 1
        };

        $scope.repositoriesTable = {
            replaceRow: function (row) {},
            removeRow: function () {}
        };

        translate = function(message) {
            return message;
        };

        Repository.sync = function(params, callback) {
            callback.call(this, {'state': 'running'});
        };

        $controller('RepositoryDetailsInfoController', {
            $scope: $scope,
            $state: $state,
            $q: $q,
            translate: translate,
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
        var promise;
        spyOn($scope.repositoriesTable, 'replaceRow');

        promise = $scope.save($scope.repository);

        expect(promise.then).toBeDefined();
        expect($scope.repositoriesTable.replaceRow).toHaveBeenCalledWith($scope.repository);
    });

    it('should save the repository successfully', function() {
        spyOn($scope.repositoriesTable, 'replaceRow');

        $scope.save($scope.repository);

        expect($scope.errorMessages.length).toBe(0);
        expect($scope.successMessages.length).toBe(1);
        expect($scope.repositoriesTable.replaceRow).toHaveBeenCalledWith($scope.repository);
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

    it('should handle 413 (file too large) responses by showing an error', function() {
        var text = '<html><head> \
            <title>413 Request Entity Too Large</title> \
            </head><body> \
            <h1>Request Entity Too Large</h1> \
            The requested resource<br />/katello/api/v2/repositories/1/upload_content<br /> \
            does not allow request data with POST requests, or the amount of data provided in \
            the request exceeds the capacity limit. \
            </body></html>';

        $scope.uploadContent(text, true);
        expect($scope.uploadSuccessMessages.length).toBe(0);
        expect($scope.uploadErrorMessages.length).toBe(1);
        expect($scope.uploadErrorMessages[0]).toContain('File too large');

    });

    it('should set the upload status to success and refresh the repository if a file upload status is success', function() {
        spyOn($scope.repositoriesTable, 'replaceRow');
        spyOn($scope.repository, '$get');
        $scope.uploadContent('<pre>{"status": "success"}</pre>', true);

        expect($scope.uploadErrorMessages.length).toBe(0);
        expect($scope.uploadSuccessMessages.length).toBe(1);
        expect($scope.repository.$get).toHaveBeenCalled();
        expect($scope.repositoriesTable.replaceRow).toHaveBeenCalledWith($scope.repository);
    });

    it('should provide a method to determine if a repository is currently being syncd', function() {
        expect($scope.syncInProgress($scope.repository['sync_state'])).toBe(false);
    });

    it('should provide a method to determine if a repository is currently being syncd', function() {
        var lastSync = {state: 'running'};
        expect($scope.syncInProgress(lastSync)).toBe(true);
    });

    it("provides a way to sync a repository", function() {
        spyOn($state, 'go');
        spyOn($scope.repositoriesTable, 'replaceRow');

        $scope.syncRepository($scope.repository);
        expect($state.go).toHaveBeenCalled();
        expect($scope.repositoriesTable.replaceRow).toHaveBeenCalledWith($scope.repository);
    });

    it("should provide a valid reason for a repo deletion disablement", function() {
        var product = {id: 100, $resolved: true},
            repository = {id: 200, $resolved: true};

        $scope.denied = function (perm, prod) {
            expect(perm).toBe("destroy_products");
            return true;
        };
        expect($scope.getRepoNonDeletableReason(repository, product)).toBe("permissions");
        expect($scope.canRemove(repository, product)).toBe(false);

        $scope.denied = function (perm, prod) {
            return false;
        };
        repository.promoted = true;
        expect($scope.getRepoNonDeletableReason(repository, product)).toBe("published");
        expect($scope.canRemove(repository, product)).toBe(false);

        repository.promoted = false;
        repository.product_type = "redhat";
        expect($scope.getRepoNonDeletableReason(repository, product)).toBe("redhat");
        expect($scope.canRemove(repository, product)).toBe(false);

        repository.product_type = "custom";
        expect($scope.getRepoNonDeletableReason(repository, product)).toBe(null);
        expect($scope.canRemove(repository, product)).toBe(true);
    });

    it('should provide a way to remove a repository', function() {
        repository.id = 1;

        spyOn($scope.repositoriesTable, 'removeRow');
        spyOn($scope, 'transitionTo');

        $scope.removeRepository(repository);

        expect($scope.repositoriesTable.removeRow).toHaveBeenCalledWith(1);
        expect($scope.transitionTo).toHaveBeenCalledWith('products.details.repositories.index', {productId: 1});
    });
});

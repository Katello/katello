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
        $scope.repository = repository;

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

        promise = $scope.save($scope.repository);

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

    it('should handle 413 (file too large) responses by showing an error', function() {
        var error = 'Could not parse JSON',
            text = '<html><head> \
            <title>413 Request Entity Too Large</title> \
            </head><body> \
            <h1>Request Entity Too Large</h1> \
            The requested resource<br />/katello/api/v2/repositories/1/upload_content<br /> \
            does not allow request data with POST requests, or the amount of data provided in \
            the request exceeds the capacity limit. \
            </body></html>';

        $scope.uploadError(error, text);
        expect($scope.uploadSuccessMessages.length).toBe(0);
        expect($scope.uploadErrorMessages.length).toBe(1);
        expect($scope.uploadErrorMessages[0]).toContain('File too large');
    });

    it('should set the upload status to success and refresh the repository if a file upload status is success', function() {
        spyOn($scope.repository, '$get');
        $scope.uploadContent('<pre>{"status": "success", "filenames": ["uploaded_file"]}</pre>', true);

        expect($scope.uploadErrorMessages.length).toBe(0);
        expect($scope.uploadSuccessMessages.length).toBe(1);
        expect($scope.repository.$get).toHaveBeenCalled();
    });
});

describe('Controller: RepositoryDetailsInfoController', function() {
    var $scope, $state, translate, Notification, repository, DownloadPolicy, OstreeUpstreamSyncPolicy, YumContentUnits, HttpProxy, HttpProxyPolicy;

    beforeEach(module(
        'Bastion.repositories',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q'),
            ContentCredential = $injector.get('MockResource').$new(),
            Repository = $injector.get('MockResource').$new(),
            HttpProxy = $injector.get('MockResource').$new();

        repository = new Repository();
        DownloadPolicy = $injector.get("DownloadPolicy");
        OstreeUpstreamSyncPolicy = $injector.get("OstreeUpstreamSyncPolicy");
        YumContentUnits = $injector.get("YumContentUnits");
        HttpProxyPolicy = $injector.get("HttpProxyPolicy");
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

        Notification = {
            setSuccessMessage: function () {},
            setErrorMessage: function () {}
        };

        Repository.sync = function(params, callback) {
            callback.call(this, {'state': 'running'});
        };

        $controller('RepositoryDetailsInfoController', {
            $scope: $scope,
            $state: $state,
            $q: $q,
            translate: translate,
            Notification: Notification,
            Repository: Repository,
            ContentCredential: ContentCredential,
            HttpProxyPolicy: HttpProxyPolicy,
            HttpProxy: HttpProxy
        });
    }));

    it('provides a method to retrieve available certs', function() {
        var promise = $scope.certs();

        expect(promise.then).toBeDefined();
        promise.then(function(contentCredentials) {
            expect(contentCredentials).toBeDefined();
            expect(contentCredentials).toContain({id: null, name: ''});
        });

        $scope.$apply();
    });

    it('provides a method to retrieve available gpgKeys', function() {
        var promise = $scope.gpgKeys();

        expect(promise.then).toBeDefined();
        promise.then(function(contentCredentials) {
            expect(contentCredentials).toBeDefined();
            expect(contentCredentials).toContain({id: null, name: ''});
        });

        $scope.$apply();
    });

    it('should save the repository and return a promise', function() {
        var promise;

        promise = $scope.save($scope.repository);

        expect(promise.then).toBeDefined();
    });

    it('should clear the repo upstream password and username on clearUpstreamAuth', function() {
        spyOn($scope, 'save');
        $scope.clearUpstreamAuth($scope.repository);
        expect($scope.save).toHaveBeenCalledWith($scope.repository);
        expect($scope.repository["upstream_password"]).toBe(null);
        expect($scope.repository["upstream_username"]).toBe(null);
        expect($scope.repository["upstream_auth_exists"]).toBe(false);
    });

    it('should save the repository successfully', function() {
        spyOn(Notification, 'setSuccessMessage');

        $scope.save($scope.repository);

        expect(Notification.setSuccessMessage).toHaveBeenCalledWith('Repository Saved.');
    });

    it('should ignore upstream auth on save unless specified', function() {
        var repo = new Repository({
            upstream_username: 'autofilled',
            upstream_password: 'autofilled'
        })

        $scope.save(repo);

        expect(repo.upstream_username).toBe(undefined);
        expect(repo.upstream_password).toBe(undefined);
    });

    it('should not ignore upstream auth on save unless specified', function() {
        var repo = new Repository({
            upstream_username: 'autofilled',
            upstream_password: 'autofilled'
        })

        $scope.save(repo, true);

        expect(repo.upstream_username).toBe('autofilled');
        expect(repo.upstream_password).toBe('autofilled');
    });


    it('should fail to save the repository', function() {
        spyOn(Notification, 'setErrorMessage');

        $scope.repository.failed = true;
        $scope.save($scope.repository);

        expect(Notification.setErrorMessage).toHaveBeenCalledWith('An error occurred saving the Repository: error!');
    });

    it('should set an error message if a file upload status is not success', function() {
        spyOn(Notification, 'setErrorMessage');
        $scope.uploadContent('<pre>{"displayMessage": "blah"}</pre>', true);
        expect(Notification.setErrorMessage).toHaveBeenCalledWith('Error during upload: blah');
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

        spyOn(Notification, 'setErrorMessage');
        $scope.uploadError(error, text);
        expect(Notification.setErrorMessage).toHaveBeenCalledWith('Error during upload: File too large. Please use the CLI instead.');
    });

    it ('should set download policies', function() {
       expect($scope.downloadPolicies).toBe(DownloadPolicy.downloadPolicies);
    });

    it ('should set ostree upstream sync policies', function() {
       expect($scope.ostreeUpstreamSyncPolicies).toBe(OstreeUpstreamSyncPolicy.syncPolicies);
    });

    it ('should set yum content units', function() {
       expect($scope.ignorableYumContentUnits).toBe(YumContentUnits.units);
    });

    it('should set the upload status to success and refresh the repository if a file upload status is success', function() {
        spyOn(Notification, 'setSuccessMessage');
        spyOn($scope.repository, '$get');
        $scope.uploadContent('<pre>{"status": "success", "filenames": ["uploaded_file"]}</pre>', true);

        expect(Notification.setSuccessMessage).toHaveBeenCalledWith('Successfully uploaded content: uploaded_file');
        expect($scope.repository.$get).toHaveBeenCalled();
    });
});

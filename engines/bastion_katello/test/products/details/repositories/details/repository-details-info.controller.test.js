describe('Controller: RepositoryDetailsInfoController', function() {
    var $scope, $state, translate, Notification, repository, DownloadPolicy, YumContentUnits, Repository, HttpProxy, HttpProxyPolicy, RepositoryTypesService;

    beforeEach(module(
        'Bastion.repositories',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q'),
            RepositoryTypesService = {},
            ContentCredential = $injector.get('MockResource').$new(),
            Repository = $injector.get('MockResource').$new(),
            HttpProxy = $injector.get('MockResource').$new();

        repository = new Repository();
        DownloadPolicy = $injector.get("DownloadPolicy");
        YumContentUnits = $injector.get("YumContentUnits");
        HttpProxyPolicy = $injector.get("HttpProxyPolicy");
        RepositoryTypesService.genericContentTypes = function() {};
        $scope = $injector.get('$rootScope').$new();
        $state = $injector.get('$state');

        $scope.$stateParams = {
            productId: 1,
            repositoryId: 1
        };
        $scope.repository = repository;
        $scope.repository['ignorable_content'] = [];

        RepositoryTypesService = {};
        RepositoryTypesService.genericContentTypes = function () {
            return []
        };
        RepositoryTypesService.getAttribute = function () {
            return null;
        };

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
            HttpProxy: HttpProxy,
            RepositoryTypesService: RepositoryTypesService
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
        expect($scope.repository["upstream_authentication_token"]).toBe(null);
        expect($scope.repository["upstream_auth_exists"]).toBe(false);
    });

    it('should clear the repo auth_url and token on clearAnsibleCollectionAuth', function() {
        spyOn($scope, 'save');
        $scope.repository["ansible_collection_auth_url"] = "https://abc.com";
        $scope.repository["ansible_collection_auth_token"] = "1234";
        $scope.clearAnsibleCollectionAuth($scope.repository);
        expect($scope.save).toHaveBeenCalledWith($scope.repository);
        expect($scope.repository["ansible_collection_auth_url"]).toBe(null);
        expect($scope.repository["ansible_collection_auth_token"]).toBe(null);
        expect($scope.repository["ansible_collection_auth_exists"]).toBe(false);
    });

    it('should save the repository successfully', function() {
        spyOn(Notification, 'setSuccessMessage');

        $scope.save($scope.repository);

        expect(Notification.setSuccessMessage).toHaveBeenCalledWith('Repository Saved.');
    });

    it('should clear out auth fields on save if blank', inject(function($injector) {
        var Repository = $injector.get('MockResource').$new(),
        repo = new Repository({
        upstream_username: '',
        upstream_password: '',
        upstream_authentication_token: '',
        ansible_collection_auth_url: '',
        ansible_collection_auth_token: '',
      })

      $scope.save(repo);

      expect(repo.upstream_username).toBe(null);
      expect(repo.upstream_password).toBe(null);
      expect(repo.upstream_authentication_token).toBe(null);
      expect(repo.ansible_collection_auth_token).toBe(null);
      expect(repo.ansible_collection_auth_url).toBe(null);
    }));

    it('should not clear out auth fields on save if not blank', inject(function($injector) {
      var Repository = $injector.get('MockResource').$new(),
      repo = new Repository({
      upstream_username: 'upstream',
      upstream_password: 'passwd',
      upstream_authentication_token: 'token',
      ansible_collection_auth_url: 'https://url.com',
      ansible_collection_auth_token: 'some_token',
    })

    $scope.save(repo);

    expect(repo.upstream_username).not.toBe(null);
    expect(repo.upstream_password).not.toBe(null);
    expect(repo.upstream_authentication_token).not.toBe(null);
    expect(repo.ansible_collection_auth_token).not.toBe(null);
    expect(repo.ansible_collection_auth_url).not.toBe(null);
  }));

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

    it('should set the upload status to success and refresh the repository if a file upload status is success', function() {
        spyOn(Notification, 'setSuccessMessage');
        spyOn($scope.repository, '$get');
        $scope.uploadContent('<pre>{"status": "success", "filenames": ["uploaded_file"]}</pre>', true);

        expect(Notification.setSuccessMessage).toHaveBeenCalledWith('Successfully uploaded content: uploaded_file');
        expect($scope.repository.$get).toHaveBeenCalled();
    });
});

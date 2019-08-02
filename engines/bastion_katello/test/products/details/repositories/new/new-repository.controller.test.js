describe('Controller: NewRepositoryController', function() {
    var $scope,
        FormUtils,
        Notification,
        DownloadPolicy,
        OstreeUpstreamSyncPolicy,
        YumContentUnits,
        $httpBackend,
        HttpProxyPolicy,
        HttpProxy,
        RepositoryTypesService;

    beforeEach(module('Bastion.repositories', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $http = $injector.get('$http'),
            Repository = $injector.get('MockResource').$new(),
            Product = $injector.get('MockResource').$new(),
            Setting = $injector.get('MockResource').$new(),
            ContentCredential = $injector.get('MockResource').$new(),
            Architecture = $injector.get('MockResource').$new(),
            HttpProxy = $injector.get('MockResource').$new();

        DownloadPolicy = $injector.get('DownloadPolicy');
        OstreeUpstreamSyncPolicy = $injector.get('OstreeUpstreamSyncPolicy');
        YumContentUnits = $injector.get('YumContentUnits');
        $scope = $injector.get('$rootScope').$new();
        $httpBackend = $injector.get('$httpBackend');
        FormUtils = $injector.get('FormUtils');
        Notification = $injector.get('Notification');
        HttpProxyPolicy = $injector.get('HttpProxyPolicy');

        $scope.detailsTable = {rows: []};
        $scope.$stateParams = {productId: 1};
        $scope.repositoryForm = $injector.get('MockForm');

        RepositoryTypesService = {};
        RepositoryTypesService.creatable = function () {
            return [{name: 'yum', name: 'puppet'}]
        };

        Setting.get = function (data, succ, err) {
            return { results: [{ value: 'true' }]};
        };

        $controller('NewRepositoryController', {
            $scope: $scope,
            $http: $http,
            Repository: Repository,
            Product: Product,
            ContentCredential: ContentCredential,
            Architecture: Architecture,
            Notification: Notification,
            Setting: Setting,
            RepositoryTypesService: RepositoryTypesService,
            HttpProxyPolicy: HttpProxyPolicy,
            HttpProxy: HttpProxy
        });
    }));

    it('should attach a new repository resource on to the scope', function() {
        expect($scope.repository).toBeDefined();
    });


    it('should fetch available Content Credentials', function() {
        expect($scope.contentCredentials).toBeDefined();
    });

    it('should fetch available Architectures', function() {
        expect($scope.architecture).toBeDefined();
    });

    it('should save a new repository resource', function() {
        var repository = $scope.repository;

        spyOn($scope, 'transitionTo');
        spyOn(repository, '$save').and.callThrough();
        spyOn(Notification, "setSuccessMessage");
        $scope.save(repository);

        expect(repository.$save).toHaveBeenCalled();
        expect(Notification.setSuccessMessage).toHaveBeenCalled();
        expect($scope.transitionTo).toHaveBeenCalledWith('product.repositories', {productId: 1});
    });

    it('should fail to save a new repository resource', function() {
        var repository = $scope.repository;

        repository.failed = true;
        spyOn(repository, '$save').and.callThrough();
        $scope.save(repository);

        expect(repository.$save).toHaveBeenCalled();
        expect($scope.repositoryForm['name'].$invalid).toBe(true);
        expect($scope.repositoryForm['name'].$error.messages).toBeDefined();
    });

    it('should fetch a label whenever the name changes', function() {
        spyOn(FormUtils, 'labelize');

        $scope.repository.name = 'ChangedName';
        $scope.$apply();

        expect(FormUtils.labelize).toHaveBeenCalled();
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

});

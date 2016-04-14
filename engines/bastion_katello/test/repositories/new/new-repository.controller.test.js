describe('Controller: NewRepositoryController', function() {
    var $scope,
        FormUtils,
        GlobalNotification,
        Setting,
        $httpBackend;

    beforeEach(module('Bastion.repositories', 'Bastion.test-mocks'));

    beforeEach(module({
        Setting: {
            get: function() {
                return { results: [{ value: 'true' }]};
            }
        }
    }));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $http = $injector.get('$http'),
            Repository = $injector.get('MockResource').$new(),
            GPGKey = $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();
        $httpBackend = $injector.get('$httpBackend');
        FormUtils = $injector.get('FormUtils');
        GlobalNotification = $injector.get('GlobalNotification');

        $scope.detailsTable = {rows: []};
        $scope.$stateParams = {productId: 1};
        $scope.repositoryForm = $injector.get('MockForm');

        Repository.repositoryTypes = function (data, func) {
            $scope.repositoryTypesTestData = data;
            $scope.repositoryTypesTestCalled = true;
        };

        $controller('NewRepositoryController', {
            $scope: $scope,
            $http: $http,
            Repository: Repository,
            GPGKey: GPGKey,
            GlobalNotification: GlobalNotification
        });
    }));

    it('should attach a new repository resource on to the scope', function() {
        expect($scope.repository).toBeDefined();
    });

    it('should define a set of repository types', function() {
        expect($scope.repositoryTypesTestCalled).toBe(true);
        expect($scope.repositoryTypesTestData["creatable"]).toBeDefined();
    });

    it('should fetch available GPG Keys', function() {
        expect($scope.gpgKeys).toBeDefined();
    });

    it('should save a new repository resource', function() {
        var repository = $scope.repository;

        spyOn($scope, 'transitionTo');
        spyOn(repository, '$save').andCallThrough();
        spyOn(GlobalNotification, "setSuccessMessage");
        $scope.save(repository);

        expect(repository.$save).toHaveBeenCalled();
        expect(GlobalNotification.setSuccessMessage).toHaveBeenCalled();
        expect($scope.transitionTo).toHaveBeenCalledWith('products.details.repositories.index', {productId: 1});
    });

    it('should fail to save a new repository resource', function() {
        var repository = $scope.repository;

        repository.failed = true;
        spyOn(repository, '$save').andCallThrough();
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
});

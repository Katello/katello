describe('Controller: ProductFormController', function() {
    var $scope,
        FormUtils,
        Notification,
        modalResponse,
        SyncPlan,
        $uibModal,
        $httpBackend;

    beforeEach(module('Bastion.products', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $http = $injector.get('$http'),
            $q = $injector.get('$q'),
            Product = $injector.get('MockResource').$new(),
            Provider = $injector.get('MockResource').$new(),
            ContentCredential = $injector.get('MockResource').$new();

        SyncPlan = $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();
        $httpBackend = $injector.get('$httpBackend');
        FormUtils = $injector.get('FormUtils');
        Notification = $injector.get('Notification');

        $scope.productForm = $injector.get('MockForm');
        $scope.panel = {};

        modalResponse = {
            id: 3
        };

        $uibModal = {
            open: function () {
                return {
                    result: {
                        then: function (callback) {
                            callback(modalResponse);
                        }
                    }
                }
            }
        };


        $controller('ProductFormController', {
            $scope: $scope,
            $http: $http,
            $q: $q,
            $uibModal: $uibModal,
            Product: Product,
            Provider: Provider,
            ContentCredential: ContentCredential,
            SyncPlan: SyncPlan,
            FormUtils: FormUtils,
            Notification: Notification
        });
    }));

    it('should attach a new product resource on to the scope', function() {
        expect($scope.product).toBeDefined();
    });

    it('should save a new product resource', function() {
        var product = $scope.product;

        spyOn($scope, 'transitionTo');
        spyOn(product, '$save').and.callThrough();
        $scope.save(product);

        expect(product.$save).toHaveBeenCalled();
        expect($scope.transitionTo).toHaveBeenCalledWith('product.repositories',
                                                         {productId: $scope.product.id})
    });

    it('should fail to save a new product resource', function() {
        var product = $scope.product;

        product.failed = true;
        spyOn(product, '$save').and.callThrough();
        $scope.save(product);

        expect(product.$save).toHaveBeenCalled();
        expect($scope.productForm['name'].$invalid).toBe(true);
        expect($scope.productForm['name'].$error.messages).toBeDefined();
    });

    it('should fetch a label whenever the name changes', function() {
        spyOn(FormUtils, 'labelize');

        $scope.product.name = 'ChangedName';
        $scope.$apply();

        expect(FormUtils.labelize).toHaveBeenCalled();
    });

    it("should open a new sync plan modal", function () {
        var result;

        spyOn(SyncPlan, 'queryUnpaged').and.callFake(function () {
            return {
                $promise: {
                    then: function (callback) {
                        callback();
                    }
                }
            };
        });

        spyOn($uibModal, 'open').and.callThrough();

        $scope.openSyncPlanModal();

        result = $uibModal.open.calls.argsFor(0)[0];

        expect(result.templateUrl).toContain('new-sync-plan-modal.html');
        expect(result.controller).toBe('NewSyncPlanModalController');
        expect($scope.product['sync_plan_id']).toBe(modalResponse.id);
    });
});


describe('Controller: ProductsBulkHttpProxyModalController', function() {
    var $scope, $q, $uibModalInstance, translate, ProductBulkAction,
        CurrentOrganization, Notification, bulkParams, HttpProxy, HttpProxyPolicy;

    beforeEach(module('Bastion.products', 'Bastion.repositories'));

    beforeEach(function() {
        bulkParams = {ids: [1, 2, 3]};
        ProductBulkAction = {
            updateProductHttpProxy: function() {
                var deferred = $q.defer();
                return {$promise: deferred.promise};
            },
        };

        HttpProxy = {
            queryUnpaged: function() {}
        }

        $uibModalInstance = {
            close: function () {},
            dismiss: function () {}
        };

        translate = function() {};
        CurrentOrganization = 'foo';
    });

    beforeEach(inject(function($injector) {
        HttpProxyPolicy = $injector.get('HttpProxyPolicy');
    }));

    beforeEach(inject(function(_Notification_, $controller, $rootScope, _$q_, $injector) {
        $scope = $rootScope.$new();
        $q = _$q_;
        Notification = _Notification_;


        $scope.table = {
            getSelected: function () { return selected; }
        };

        spyOn(HttpProxy, 'queryUnpaged')

        $controller('ProductsBulkHttpProxyModalController', {
            $scope: $scope,
            $uibModalInstance: $uibModalInstance,
            bulkParams: bulkParams,
            translate: translate,
            ProductBulkAction: ProductBulkAction,
            CurrentOrganization: CurrentOrganization,
            Notification: Notification,
            HttpProxy: HttpProxy,
            HttpProxyPolicy: HttpProxyPolicy
        });
    }));

    it("Fetches HttpProxys", function() {
        expect(HttpProxy.queryUnpaged).toHaveBeenCalled();
    });

    it("should update proxy", function() {
        spyOn(ProductBulkAction, 'updateProductHttpProxy').and.callThrough();

        $scope.proxyOptions.httpProxyPolicy = 'global_default_http_proxy';
        $scope.update();

        expect(ProductBulkAction.updateProductHttpProxy).toHaveBeenCalledWith({ids: [1, 2, 3],
                'http_proxy_policy': 'global_default_http_proxy',
                'http_proxy_id': null},
            jasmine.any(Function), jasmine.any(Function));
    });

    it("provides a function for closing the modal", function () {
        spyOn($uibModalInstance, 'close');
        $scope.ok();
        expect($uibModalInstance.close).toHaveBeenCalled();
    });

    it("provides a function for cancelling the modal", function () {
        spyOn($uibModalInstance, 'dismiss');
        $scope.cancel();
        expect($uibModalInstance.dismiss).toHaveBeenCalled();
    });

});

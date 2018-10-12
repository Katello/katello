describe('Controller: ProductsBulkSyncPlanModalController', function() {
    var $scope, $q, $uibModalInstance, translate, ProductBulkAction, CurrentOrganization, Notification, bulkParams;

    beforeEach(module('Bastion.products'));

    beforeEach(function() {
        bulkParams = {ids: [1, 2, 3]};
        ProductBulkAction = {
            syncProducts: function() {
                var deferred = $q.defer();
                return {$promise: deferred.promise};
            },
        };

        $uibModalInstance = {
            close: function () {},
            dismiss: function () {}
        };

        translate = function() {};
        CurrentOrganization = 'foo';
    });

    beforeEach(inject(function(_Notification_, $controller, $rootScope, _$q_) {
        $scope = $rootScope.$new();
        $q = _$q_;
        Notification = _Notification_;

        $scope.table = {
            getSelected: function () { return selected; }
        };

        $controller('ProductsBulkAdvancedSyncModalController', {
            $scope: $scope,
            $uibModalInstance: $uibModalInstance,
            bulkParams: bulkParams,
            translate: translate,
            ProductBulkAction: ProductBulkAction,
            CurrentOrganization: CurrentOrganization,
            Notification: Notification
        });
    }));

    it("allows skip_metadata_generate sync", function() {
        spyOn(ProductBulkAction, 'syncProducts').and.callThrough();

        $scope.syncType = 'skipMetadataCheck';
        $scope.ok();

        expect(ProductBulkAction.syncProducts).toHaveBeenCalledWith({ids: [1, 2, 3], 'skip_metadata_check': true},
            jasmine.any(Function), jasmine.any(Function));
    });

    it("allows validate_contents sync", function() {
        spyOn(ProductBulkAction, 'syncProducts').and.callThrough();

        $scope.syncType = 'validateContents';
        $scope.ok();

        expect(ProductBulkAction.syncProducts).toHaveBeenCalledWith({ids: [1, 2, 3], 'validate_contents': true},
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

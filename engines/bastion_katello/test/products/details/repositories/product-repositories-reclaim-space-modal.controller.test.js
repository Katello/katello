describe('Controller: ProductRepositoriesReclaimSpaceModalController', function() {
    var $scope, $q, $uibModalInstance, translate, RepositoryBulkAction, Notification, reclaimParams;

    beforeEach(module('Bastion.repositories'));

    beforeEach(function() {
        reclaimParams = {ids: [1,2,3]};
        RepositoryBulkAction = {
            reclaimSpaceFromRepositories: function() {
                var deferred = $q.defer();
                return {$promise: deferred.promise};
            },
        };

        $uibModalInstance = {
            close: function () {},
            dismiss: function () {}
        };

        translate = function() {};
    });

    beforeEach(inject(function(_Notification_, $controller, $rootScope, _$q_) {
        $scope = $rootScope.$new();
        $q = _$q_;
        Notification = _Notification_;

        $controller('ProductRepositoriesReclaimSpaceModalController', {
            $scope: $scope,
            $uibModalInstance: $uibModalInstance,
            translate: translate,
            RepositoryBulkAction: RepositoryBulkAction,
            Notification: Notification,
            reclaimParams: reclaimParams
        });
    }));

    it("allows reclaiming space", function() {
        spyOn(RepositoryBulkAction, 'reclaimSpaceFromRepositories').and.callThrough();
        $scope.ok();
        expect(RepositoryBulkAction.reclaimSpaceFromRepositories).toHaveBeenCalledWith({ids: [1,2,3]},
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

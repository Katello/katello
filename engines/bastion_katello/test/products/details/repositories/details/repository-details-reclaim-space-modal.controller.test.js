describe('Controller: RepositoryDetailsReclaimSpaceModalController', function() {
    var $scope, $q, $uibModalInstance, translate, Repository, CurrentOrganization, Notification, reclaimParams;

    beforeEach(module('Bastion.repositories'));

    beforeEach(function() {
        reclaimParams = {repository: {id: 10}}
        Repository = {
            reclaimSpace: function() {
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

        $controller('RepositoryDetailsReclaimSpaceModalController', {
            $scope: $scope,
            $uibModalInstance: $uibModalInstance,
            translate: translate,
            Repository: Repository,
            Notification: Notification,
            reclaimParams: reclaimParams
        });
    }));

    it("allows reclaiming space", function() {
        spyOn(Repository, 'reclaimSpace').and.callThrough();
        $scope.ok();
        expect(Repository.reclaimSpace).toHaveBeenCalledWith({id: 10},
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

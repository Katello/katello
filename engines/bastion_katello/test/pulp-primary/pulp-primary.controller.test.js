describe('Controller: PulpPrimaryController', function() {
    var $scope, $q, $urlMatcherFactory, $location, PulpPrimary, Notification;

    beforeEach(module('Bastion.pulp-primary'));

    beforeEach(function() {
        PulpPrimary = {
            reclaimSpace: function() {
                var deferred = $q.defer();
                return {$promise: deferred.promise};
            },
        };
    });

    beforeEach(inject(function(_Notification_, $controller, $rootScope, _$q_, $injector) {
        $scope = $rootScope.$new();
        $q = _$q_;
        Notification = _Notification_;
        $urlMatcherFactory = $injector.get('$urlMatcherFactory');
        $location =  { path: function(){ return '/smart_proxies/1' } };

        $controller('PulpPrimaryController', {
            $scope: $scope,
            $urlMatcherFactory: $urlMatcherFactory,
            $location: $location,
            PulpPrimary: PulpPrimary,
            Notification: Notification
        });
    }));

    it("allows reclaiming space", function() {
        spyOn(PulpPrimary, 'reclaimSpace').and.callThrough();
        $scope.reclaimSpace();
        expect(PulpPrimary.reclaimSpace).toHaveBeenCalledWith({id: '1'},
            jasmine.any(Function), jasmine.any(Function));
    });
});

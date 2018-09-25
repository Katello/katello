describe('Controller: NewSyncPlanController', function() {
    var $scope, translate, SyncPlan, SyncPlanHelper, Notification;

    beforeEach(module(
        'Bastion.sync-plans',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller');

        SyncPlan = $injector.get('MockResource').$new()
        Notification = $injector.get('Notification');
        $scope = $injector.get('$rootScope').$new();
        $scope.$state = {go: function () {}};
        SyncPlanHelper = {
            createSyncPlan: function (syncPlan, success, error) {
                if (this.failed) {
                    var response = {
                        data: {errors:
                            {
                                name: 'has already been taken'
                            }
                        }
                    };

                    error(response);
                } else {
                    success(syncPlan);
                }
            },
            getIntervals: function () {
                return [{id: 1}];
            },
            getForm: function () {},
            setForm: function () {}
        };

        translate = function (string) { return string; };

        $controller('NewSyncPlanController', {
            $scope: $scope,
            translate: translate,
            SyncPlan: SyncPlan,
            SyncPlanHelper: SyncPlanHelper,
            Notification: Notification
        });
    }));

    it('should attach a sync plan resource on to the scope', function() {
        expect($scope.syncPlan).toBeDefined();
    });

    it('should set the sync plan intervals on the $scope', function() {
        expect($scope.intervals).toBeDefined();
    });

    it('should set a default interval for the syncPlan', function() {
        expect($scope.syncPlan.interval).toBe(1);
    });

    describe("should save a new sync plan", function () {
        var startDate, syncPlan;

        beforeEach(function () {
            startDate = new Date('11/17/1982');
            syncPlan = {id: 1, startDate: startDate, endDate: '14:40'};
            spyOn(SyncPlanHelper, 'createSyncPlan').and.callThrough();
        });

        afterEach(function () {
            expect(SyncPlanHelper.createSyncPlan).toHaveBeenCalledWith(syncPlan, jasmine.any(Function), jasmine.any(Function));
        });

        it('and succeed', function() {
            spyOn($scope.$state, 'go');
            spyOn(Notification, "setSuccessMessage");

            $scope.createSyncPlan(syncPlan);

            expect($scope.isWorking).toBe(false);
            expect(Notification.setSuccessMessage).toHaveBeenCalled();
            expect($scope.$state.go).toHaveBeenCalledWith('sync-plan.info', {syncPlanId: syncPlan.id});
        });

        it('and fail', function() {
            var form = {
                name: {
                    $setValidity: function () {},
                    $error: {
                        messages: []
                    }
                }
            };
            
            SyncPlanHelper.failed = true;

            spyOn(SyncPlanHelper, 'getForm').and.returnValue(form);
            spyOn($scope.$state, 'go');
            spyOn(form.name, '$setValidity');

            $scope.createSyncPlan(syncPlan);

            expect($scope.isWorking).toBe(false);
            expect($scope.$state.go).not.toHaveBeenCalled();
            expect(form.name.$setValidity).toHaveBeenCalledWith('server', false);
            expect(form.name.$error.messages).toBe('has already been taken');
        });

    });

    it("should set the form via the sync plan helper", function () {
        var form = {blah: 'blah'};
        spyOn(SyncPlanHelper, 'setForm');
        $scope.setForm(form);
        expect(SyncPlanHelper.setForm).toHaveBeenCalledWith(form);
    });
});

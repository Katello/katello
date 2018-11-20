describe('Controller: NewSyncPlanModalController', function() {
    var $scope, $uibModalInstance, SyncPlan, SyncPlanHelper, Notification;

    beforeEach(module(
        'Bastion.sync-plans',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller');
        SyncPlan = $injector.get('MockResource').$new();
        $scope = $injector.get('$rootScope').$new();

        $uibModalInstance = {
            close: function () {},
            dismiss: function () {}
        };

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

        Notification = {
            setSuccessMessage: function () {},
            setErrorMessage: function () {}
        };

        $controller('NewSyncPlanModalController', {
            $scope: $scope,
            $uibModalInstance: $uibModalInstance,
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

    describe("should save a sync plan", function () {
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
            spyOn(Notification, 'setSuccessMessage');
            spyOn($uibModalInstance, 'close');
            $scope.ok(syncPlan);
            expect(Notification.setSuccessMessage).toHaveBeenCalled();
            expect($uibModalInstance.close).toHaveBeenCalledWith(syncPlan);
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
            spyOn(form.name, '$setValidity');

            $scope.ok(syncPlan);

            expect(form.name.$setValidity).toHaveBeenCalledWith('server', false);
            expect(form.name.$error.messages).toBe('has already been taken');
        });
    });

    it("provides a function for cancelling the modal", function () {
        spyOn($uibModalInstance, 'dismiss');
        $scope.cancel();
        expect($uibModalInstance.dismiss).toHaveBeenCalled();
    });

    it("provides a function for determining if the form is disabled", function () {
        spyOn(SyncPlanHelper, 'getForm');
        $scope.isFormDisabled();
        expect(SyncPlanHelper.getForm).toHaveBeenCalled();
    });
});

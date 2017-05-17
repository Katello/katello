describe('Controller: ActivationKeyRepositorySetsController', function () {
    var $scope,
        $controller,
        translate,
        ActivationKey,
        expectedTableSelection,
        ContentOverrideHelper,
        GlobalNotification,
        CurrentOrganization;

    beforeEach(module('Bastion.activation-keys'));

    beforeEach(inject(function (_$controller_, $rootScope) {
        $controller = _$controller_;
        $scope = $rootScope.$new();

        translate = function (message) {
            return message;
        };

        ActivationKey = {
            failed: false,
            repositorySets: function () {},
            contentOverride: function (params, overrides, success, failure) {
                if (this.failed) {
                    failure({data: {}})
                } else {
                    success();
                }
            }
        };

        ContentOverrideHelper = {
            getEnabledContentOverrides: function () {},
            getDisabledContentOverrides: function () {},
            getDefaultContentOverrides: function () {}
        };

        GlobalNotification = {
            setSuccessMessage: function () {},
            setErrorMessage: function () {}
        };

        expectedTableSelection = [
            {
                "enabled": false,
                "content": {
                    "id": "1",
                    "label": "false-content-not-overridden",
                    "name": "False Content Not Overridden"
                }
            }, {
                "enabled": false,
                "content": {
                    "id": "2",
                    "label": "content-override-true",
                    "name": "Content Override True"
                }
            }, {
                "enabled": true,
                "content": {
                    "id": "3",
                    "label": "content-override-false",
                    "name": "Content Override False"
                }
            }, {
                "enabled": true,
                "content": {
                    "id": "4",
                    "label": "true-content-not-overridden",
                    "name": "True Content Not Overridden"
                }
            }
        ];

        $controller('ActivationKeyRepositorySetsController', {
            $scope: $scope,
            translate: translate,
            ActivationKey: ActivationKey,
            GlobalNotification: GlobalNotification,
            ContentOverrideHelper: ContentOverrideHelper,
            CurrentOrganization: CurrentOrganization
        });

        $scope.table = {
            getSelected: function () {}
        };

        $scope.$stateParams.activationKeyId = 1;
    }));

    it('sets the repository sets table on the scope', function () {
        expect($scope.table).toBeDefined();
    });

    describe("can override a repository and set to enabled", function () {
        beforeEach(function () {
            spyOn($scope.table, 'getSelected').and.returnValue(expectedTableSelection);
            spyOn(ActivationKey, 'contentOverride').and.callThrough();
            spyOn(ContentOverrideHelper, 'getEnabledContentOverrides');
        });

        afterEach(function () {
            expect($scope.table.getSelected).toHaveBeenCalled();
            expect(ActivationKey.contentOverride).toHaveBeenCalled();
            expect(ContentOverrideHelper.getEnabledContentOverrides).toHaveBeenCalled()
        });

        it("and succeed", function () {
            spyOn(GlobalNotification, 'setSuccessMessage');
            $scope.overrideToEnabled();
            expect(GlobalNotification.setSuccessMessage).toHaveBeenCalled();
        });

        it("and fail", function () {
            spyOn(GlobalNotification, 'setErrorMessage');
            ActivationKey.failed = true;
            $scope.overrideToEnabled();
            expect(GlobalNotification.setErrorMessage).toHaveBeenCalled();
        });
    });

    describe("can override a repository and set to disabled", function () {
        beforeEach(function () {
            spyOn($scope.table, 'getSelected').and.returnValue(expectedTableSelection);
            spyOn(ActivationKey, 'contentOverride').and.callThrough();
            spyOn(ContentOverrideHelper, 'getDisabledContentOverrides');
        });

        afterEach(function () {
            expect($scope.table.getSelected).toHaveBeenCalled();
            expect(ActivationKey.contentOverride).toHaveBeenCalled();
            expect(ContentOverrideHelper.getDisabledContentOverrides).toHaveBeenCalled()
        });

        it("and succeed", function () {
            spyOn(GlobalNotification, 'setSuccessMessage');
            $scope.overrideToDisabled();
            expect(GlobalNotification.setSuccessMessage).toHaveBeenCalled();
        });

        it("and fail", function () {
            spyOn(GlobalNotification, 'setErrorMessage');
            ActivationKey.failed = true;
            $scope.overrideToDisabled();
            expect(GlobalNotification.setErrorMessage).toHaveBeenCalled();
        });
    });

    describe("can override a repository and set to default", function () {
        beforeEach(function () {
            spyOn($scope.table, 'getSelected').and.returnValue(expectedTableSelection);
            spyOn(ActivationKey, 'contentOverride').and.callThrough();
            spyOn(ContentOverrideHelper, 'getDefaultContentOverrides');
        });

        afterEach(function () {
            expect($scope.table.getSelected).toHaveBeenCalled();
            expect(ActivationKey.contentOverride).toHaveBeenCalled();
            expect(ContentOverrideHelper.getDefaultContentOverrides).toHaveBeenCalled()
        });

        it("and succeed", function () {
            spyOn(GlobalNotification, 'setSuccessMessage');
            $scope.resetToDefault();
            expect(GlobalNotification.setSuccessMessage).toHaveBeenCalled();
        });

        it("and fail", function () {
            spyOn(GlobalNotification, 'setErrorMessage');
            ActivationKey.failed = true;
            $scope.resetToDefault();
            expect(GlobalNotification.setErrorMessage).toHaveBeenCalled();
        });
    });

    describe("can toggle repository set filters", function () {
        it("all and env toggles", function () {
            $scope.contentAccessModes.contentAccessModeAll = false;
            $scope.contentAccessModes.contentAccessModeEnv = false;
            $scope.toggleFilters();
            expect($scope.nutupane.table.params['content_access_mode_env']).toEqual($scope.contentAccessModes.contentAccessModeEnv);
            expect($scope.nutupane.table.params['content_access_mode_all']).toEqual($scope.contentAccessModes.contentAccessModeAll);
        });
    });
});

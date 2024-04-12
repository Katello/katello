describe('Controller: ActivationKeyRepositorySetsController', function () {
    var $scope,
        $controller,
        translate,
        ActivationKey,
        expectedTableSelection,
        ContentOverrideHelper,
        Notification,
        CurrentOrganization;

    beforeEach(module('Bastion.activation-keys'));

    beforeEach(inject(function (_$controller_, $rootScope, $q) {
        $controller = _$controller_;
        $scope = $rootScope.$new();

        translate = function (message) {
            return message;
        };

        ActivationKey = {
            failed: false,
            repositorySets: function () {
                return {
                    $promise: $q.defer().promise
                }
            },
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

        Notification = {
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
            Notification: Notification,
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
            spyOn(Notification, 'setSuccessMessage');
            $scope.overrideToEnabled();
            expect(Notification.setSuccessMessage).toHaveBeenCalled();
        });

        it("and fail", function () {
            spyOn(Notification, 'setErrorMessage');
            ActivationKey.failed = true;
            $scope.overrideToEnabled();
            expect(Notification.setErrorMessage).toHaveBeenCalled();
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
            spyOn(Notification, 'setSuccessMessage');
            $scope.overrideToDisabled();
            expect(Notification.setSuccessMessage).toHaveBeenCalled();
        });

        it("and fail", function () {
            spyOn(Notification, 'setErrorMessage');
            ActivationKey.failed = true;
            $scope.overrideToDisabled();
            expect(Notification.setErrorMessage).toHaveBeenCalled();
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
            spyOn(Notification, 'setSuccessMessage');
            $scope.resetToDefault();
            expect(Notification.setSuccessMessage).toHaveBeenCalled();
        });

        it("and fail", function () {
            spyOn(Notification, 'setErrorMessage');
            ActivationKey.failed = true;
            $scope.resetToDefault();
            expect(Notification.setErrorMessage).toHaveBeenCalled();
        });
    });

    describe("can select repository type", function () {
        it("correctly sets the repo params for redhat", function () {
            $scope.repositoryType["value"] = "redhat";
            $scope.selectRepositoryType();
            expect($scope.nutupane.table.params['repository_type']).toEqual("redhat");
        });
    });

});

describe('Controller: ActivationKeyRepositorySetsControllerWithSCA', function () {
    var $scope,
        $controller,
        translate,
        ActivationKey,
        expectedTableSelection,
        ContentOverrideHelper,
        Notification,
        CurrentOrganization;

    beforeEach(module('Bastion.activation-keys'));

    beforeEach(inject(function (_$controller_, $rootScope, $q) {
        $controller = _$controller_;
        $scope = $rootScope.$new();
        $rootScope.simpleContentAccessEnabled = true;
        translate = function (message) {
            return message;
        };

        ActivationKey = {
            failed: false,
            repositorySets: function () {
                return {
                    $promise: $q.defer().promise
                }
            },
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

        Notification = {
            setSuccessMessage: function () {},
            setErrorMessage: function () {}
        };


        $controller('ActivationKeyRepositorySetsController', {
            $scope: $scope,
            translate: translate,
            ActivationKey: ActivationKey,
            Notification: Notification,
            ContentOverrideHelper: ContentOverrideHelper,
            CurrentOrganization: CurrentOrganization
        });

        $scope.table = {
            getSelected: function () {}
        };

        $scope.$stateParams.activationKeyId = 1;
    }));

    it('sets the content access mode correctly', function () {
        expect($scope.contentAccessModes.contentAccessModeAll).toBe(true);
    });
});

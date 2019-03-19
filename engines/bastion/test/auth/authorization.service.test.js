describe('Service:Authorization', function() {
    var Authorization, CurrentUser, Permissions;

    beforeEach(module('Bastion.auth', 'Bastion.test-mocks'));

    beforeEach(module(function($provide) {
        CurrentUser = {};
        Permissions = [{permission: {name: 'view_tests'}}];

        $provide.value('CurrentUser', CurrentUser);
        $provide.value('Permissions', Permissions);
    }));

    beforeEach(inject(function(_Permissions_, _Authorization_) {
        Permissions = _Permissions_;
        Authorization = _Authorization_;
    }));

    describe("provides a function determines if the user has permission to perform an action", function () {
        it("which returns true if the user is an admin", function () {
            CurrentUser.admin = true;
            expect(Authorization.permitted('randomPermission')).toBe(true);
        });

        describe("which checks for the permission in the provided model", function () {
            var model = {permissions: {}};

            it("and succeeds", function () {
                model.permissions.view_tests = true;
                expect(Authorization.permitted('view_tests', model)).toBe(true);
            });

            it("and fails", function () {
                model.permissions.view_tests = false;
                expect(Authorization.permitted('view_tests', model)).toBe(false);
                expect(Authorization.permitted('view_results', model)).toBe(false);
            });
        });

        describe("which checks if the permission name is in the Permissions list", function () {
            it("and succeeds", function () {
                expect(Authorization.permitted('view_tests')).toBe(true);
            });

            it("and fails", function () {
                expect(Authorization.permitted('view_results')).toBe(false);
            });
        });
    });

    it("returns the current user", function () {
        expect(Authorization.getCurrentUser()).toBe(CurrentUser);
    });
});

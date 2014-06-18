/**
 * Copyright 2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 */

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
});

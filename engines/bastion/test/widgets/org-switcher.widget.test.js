/**
 * Copyright 2013 Red Hat, Inc.
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
describe('Directive:orgSwitcher', function() {
    // Mocks
    var $rootScope, elementScope, $compile, $document, $window, $httpBackend, Organization;

    var orgSwitcherElement;

    // load the widgets module
    beforeEach(module('Bastion.widgets', 'widgets/views/org-switcher.html', 'Bastion.test-mocks'));

    beforeEach(function() {
        module(function($provide) {
            var Routes = {
                apiUsersPath: function() {
                    return "user";
                },
                setOrgUserSessionPath: function(organizationId) {
                    return "set_org";
                },
                setupDefaultOrgUserPath: function(userId) {
                    return "set_fav";
                },
                dashboardIndexPath: function() {
                    return "dashboard";
                }
            };

            gettext = function() {
                this.$get = function() {
                    return function() {};
                };

                return this;
            };

            Organization = {
                get: function() {}
            };

            $window = {
                navigator: {
                    userAgent: {}
                }
            };

            $provide.value('Routes', Routes);
            $provide.value('CurrentUser', 1);
            $provide.value('CurrentOrganization', 1);
            $provide.value('Organization', Organization);
//            $provide.value('$window', $window);
            $provide.provider('translateFilter', gettext);
        });

        inject(function(_$compile_, _$rootScope_, _$document_, _$httpBackend_) {
            $compile = _$compile_;
            $rootScope = _$rootScope_;
            $document = _$document_;
            $httpBackend = _$httpBackend_;
        });
    });

    beforeEach(function() {
        orgSwitcherElement = $compile('<ul id="allowed-orgs" org-switcher style="height:31px;"></ul>')($rootScope);
        $rootScope.$digest();
        elementScope = orgSwitcherElement.scope();
    });

    describe("retrieves user from Routes.apiUsersPath().", function() {
        var response;

        beforeEach(function() {
            response = {
                allowed_organizations: [{id: 1}, {id: 2}, {id: 3}],
                preferences: {
                    user: {
                        'default_org': 2
                    }
                }
            };
            $httpBackend.expectGET('user/1').respond(200, response);
        });

        afterEach(function () {
            $httpBackend.verifyNoOutstandingExpectation();
            $httpBackend.verifyNoOutstandingRequest();
        });

        it("populates a list of orgs from the request", function() {
            expect(orgSwitcherElement.find('.allowed-orgs li').length).toBe(0);
            elementScope.refresh();
            $httpBackend.flush();
            expect(orgSwitcherElement.find('.allowed-orgs li').length).toBe(3);
        });

        it("populates favorite org from the request", function() {
            elementScope.refresh();
            expect(elementScope.working).toBe(true);
            $httpBackend.flush();
            expect(elementScope.working).toBe(false);
            expect(elementScope.favoriteOrg).toBe(2);
        });
    });

    it("provides an API to toggle it's visibility, defaulting to false.", function() {
        expect(elementScope.visible).toBe(false);
        elementScope.toggleVisibility();
        expect(elementScope.visible).toBe(true);
    });

    it("refreshes the list of orgs if visible.", function() {
        spyOn(elementScope, 'refresh');
        elementScope.toggleVisibility();
        elementScope.$digest();
        expect(elementScope.refresh).toHaveBeenCalled();
    });

    describe("determines the visibility of the org switcher based on click event", function() {
        it("hides the org switcher menu if a user clicks outside of it.", function() {
            $document.trigger('click');
            expect(elementScope.visible).toBe(false);
        });

        it("keeps the org switcher open if a user clicks on it", function() {
            elementScope.visible = true;
            $('<div id="organizationSwitcher"></div>').trigger('click');
            expect(elementScope.visible).toBe(true);
        });
    });

    it("provides a way to select an org", function() {
        $httpBackend.expectPOST('set_org').respond();
        elementScope.selectOrg({id: 3});
    });

    it("provides a way to make an org default", function() {
        // mock the event argument
        var event = { preventDefault: function() {}};
        elementScope.user = {id: 1};
        $httpBackend.expectPUT('set_fav').respond();

        elementScope.setDefaultOrg(event, {id: 3});
        $httpBackend.flush();

        expect(elementScope.favoriteOrg).toBe(3);
    });
});

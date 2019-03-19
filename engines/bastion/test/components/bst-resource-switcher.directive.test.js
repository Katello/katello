describe('Directive: bstResourceSwitcher', function() {
    var $breadcrumb, $location, $state, scope, compile, element, elementScope, TableCache;

    function createDirective () {
        element = angular.element('<div bst-resource-switcher></div>');
        compile(element)(scope);
        scope.$digest();
        elementScope = element.isolateScope();
    }

    beforeEach(module('Bastion.components', 'components/views/bst-resource-switcher.html'));

    beforeEach(module(function ($provide) {
        $breadcrumb = {
            getStatesChain: function () {
                return [];
            }
        };

        $location = {
            path: function () {
                return "/products/3";
            }
        };

        $state = {
            go: function () {},
            get: function () {
                return [];
            },
            href: function () {},
            current: {}
        };

        TableCache = {
            getTable: function () {}
        };
        hideSwitcher = true;
        $provide.value('translateFilter',  function(a) { return a; });
        $provide.value('$breadcrumb', $breadcrumb);
        $provide.value('$location', $location);
        $provide.value('$state', $state);
        $provide.value('TableCache', TableCache);
    }));

    beforeEach(inject(function(_$compile_, _$rootScope_) {
        compile = _$compile_;
        scope = _$rootScope_;
    }));

    beforeEach(function() {
        createDirective();
    });

    it("should display the resource switcher", function() {
        expect(element.find('.fa-exchange').length).toBe(1);
        expect(element.find('.dropdown-menu').length).toBe(1);
        expect(element.find('.content-view-pf-pagination').length).toBe(1);
    });

    describe("should", function () {
        var breadcrumbs = [{ncyBreadcrumbLink: '/fake'}, {ncyBreadcrumbLink: '/fake/1'}];

        beforeEach(function () {
            spyOn($breadcrumb, 'getStatesChain').and.returnValue(breadcrumbs);
            spyOn(TableCache, 'getTable');
        });

        afterEach(function () {
            expect($breadcrumb.getStatesChain).toHaveBeenCalled();
        });

        it("get the table from the table cache", function () {
            createDirective();
            expect(TableCache.getTable).toHaveBeenCalledWith('fake');
        });

        it("be able to change the resource", function () {
            spyOn($location, 'path').and.returnValue('/fake/1');

            createDirective();
            scope.changeResource(2);

            expect($location.path).toHaveBeenCalledWith('/fake/2');
        });

        it("be able to show the resource switcher", function () {
            createDirective();
            scope.table = {
                rows : {
                    length : 5
                }
            };
            scope.hideSwitcher = false;
            expect(scope.showSwitcher()).toBe(true);
        });

        it("be able to hide the resource switcher", function () {
            createDirective();
            scope.table = {
                rows : {
                    length : 5
                }
            };
            scope.hideSwitcher = true;
            expect(scope.showSwitcher()).toBe(false);
        });
    });
});

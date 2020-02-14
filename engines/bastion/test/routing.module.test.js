describe('config: Bastion.routing', function () {
    var $rootScope, $location, $sniffer, $window, $state;

    function goTo(url) {
        $location.url(url);
        $rootScope.$digest();
    }

    beforeEach(module('Bastion.routing', 'layouts/404.html'));

    beforeEach(module(function ($provide) {
        $sniffer = {
            history: true
        };

        $window = {
            location: {
                href: '',
                reload: function () {}
            }
        };

        $provide.value('$sniffer', $sniffer);
        $provide.value('$window', $window);
    }));

    beforeEach(inject(function (_$rootScope_, _$state_, _$location_) {
        $rootScope = _$rootScope_;
        $state = _$state_;
        $location = _$location_;
    }));

    describe("provides a rule that", function () {
        it("removes any trailing slashes from the url", function () {
            goTo('/state///');
            expect($window.location.href).toBe('/state');
        });

        it("doesn't remove slashes if whitelisted", function () {
            goTo('/pulp/repos/');
            expect($window.location.href).toBe('/pulp/repos/');
        });
    });

    describe("provides an otherwise method that", function () {
        it('replaces encoded + characters with their decoded counterpart', function () {
            goTo('/some-state%2B%2B');
            expect($window.location.href).toBe('/some-state++');
        });

        it('removes the old browser compatibility path', function () {
            spyOn($location, 'url').and.returnValue('/bastion#/some-state');
            goTo('/some-state');
            expect($window.location.href).toBe('/some-state');
        });

        describe("handles undefined states by", function () {
            it("redirecting to a 404 page if the parent state is found", function () {
                spyOn($state, 'get').and.returnValue([{url: '/found-state'}]);
                spyOn($state, 'href').and.returnValue('/found-state');
                spyOn($state, 'go');

                goTo('/found_state/does_not_exist');

                expect($state.go).toHaveBeenCalledWith('404');
            });

            it("redirecting to the url if no parent state is found", function () {
                goTo('/non-parent');
                expect($window.location.href).toBe('/non-parent');
            });

        });
    });
});

describe('Factory: FencedPages', function() {
    var $state, FencedPages;

    beforeEach(module('Bastion.organizations'));

    beforeEach(inject(function (_$state_, _FencedPages_) {
        $state = _$state_;
        FencedPages = _FencedPages_;
    }));

    it("should add page to the list", function () {
        var expectedLength = FencedPages.list().length + 2;
        FencedPages.addPages(["testpage", "testpage2"]);
        expect(FencedPages.list().length).toBe(expectedLength);
    });

    it("should find if page is in the list", function () {
        spyOn($state, 'href').and.returnValue('/products/repositories/blah/blah');
        expect(FencedPages.isFenced({name: 'doesnt matter'})).toBe(true);
    });

    it("should not find if page is in the list", function () {
        spyOn($state, 'href').and.returnValue('/not/in/the/list');
        expect(FencedPages.isFenced({name: 'doesnt matter'})).toBe(false);
    });
});

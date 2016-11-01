describe('Factory: FencedPages', function() {
    beforeEach(module('Bastion.organizations'));

    beforeEach(inject(function (_FencedPages_) {
        FencedPages = _FencedPages_;
    }));

    it("should add page to the list", function () {
        var expectedLength = FencedPages.list().length + 2;
        FencedPages.addPages(["testpage", "testpage2"]);
        expect(FencedPages.list().length).toBe(expectedLength);
    });

    it("should find if page is in the list", function () {
        expect(FencedPages.isFenced({name: "sync-plan.info"})).toBe(true);
        expect(FencedPages.isFenced({name: "non-fenced-page.details.show"})).toBe(false);
    });
});
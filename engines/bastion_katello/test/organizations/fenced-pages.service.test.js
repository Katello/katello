describe('Factory: FencedPages', function() {
    beforeEach(module('Bastion.organizations'));

    beforeEach(inject(function (_FencedPages_) {
        FencedPages = _FencedPages_;
    }));

    it("should list all the fenced pages", function () {
        expect(FencedPages.list().length).toBe(10);
    });

    it("should add page to the list", function () {
        FencedPages.addPages(["testpage", "testpage2"]);
        expect(FencedPages.list().length).toBe(12);
    });

    it("should find if page is in the list", function () {
        expect(FencedPages.isFenced({name: "sync-plans.details.show"})).toBe(true);
        expect(FencedPages.isFenced({name: "non-fenced-page.details.show"})).toBe(false);
    });
});
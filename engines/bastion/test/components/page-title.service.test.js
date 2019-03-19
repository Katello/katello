describe('Factory: PageTitle', function () {
    var $window, $interpolate, PageTitle;

    beforeEach(module('Bastion.components'));

    beforeEach(inject(function (_$window_, _$interpolate_, _PageTitle_) {
        $window = _$window_;
        $interpolate = _$interpolate_;
        PageTitle = _PageTitle_;
    }));

    it("provides a way to set titles", function () {
        PageTitle.setTitle("my new title: {{ title }}", {title: 'blah'})
        expect(PageTitle.titles.length).toBe(1);
        expect($window.document.title).toBe("my new title: blah");
    });

    it("provides a way to reset to the first title", function () {
        PageTitle.setTitle("my new title: {{ title }}", {title: 'blah'})
        PageTitle.setTitle('title 1');
        PageTitle.setTitle('title 2');

        PageTitle.resetToFirst();
        expect(PageTitle.titles.length).toBe(1);
        expect($window.document.title).toBe("my new title: blah");
    });

    it("stores a stack of titles and provides a way to retrieve it", function () {
        expect(PageTitle.titles.length).toBe(0);

        PageTitle.setTitle('title 1');
        expect(PageTitle.titles.length).toBe(1);

        PageTitle.setTitle('title 2');
        expect(PageTitle.titles.length).toBe(2);
        expect(PageTitle.titles[1]).toBe('title 2');
    })
});

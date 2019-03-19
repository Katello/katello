describe('Service: translate', function() {
    var translate, gettextCatalog;

    beforeEach(module('Bastion.i18n'));

    beforeEach(inject(function(_translate_, _gettextCatalog_) {
        translate = _translate_;
        gettextCatalog = _gettextCatalog_;
    }));

    it('passes through to the gettextCatalog.getString', function() {
        var string = 'lalala';
        spyOn(gettextCatalog, 'getString').and.returnValue(string);
        expect(translate(string)).toBe(string);
        expect(gettextCatalog.getString).toHaveBeenCalledWith(string);
    });
});


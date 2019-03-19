var BastionConfig,
    PrefixInterceptor;

describe('PrefixInterceptor', function() {
    beforeEach(module('gettext'));
    beforeEach(module('Bastion'));

    beforeEach(inject(function(_PrefixInterceptor_, _BastionConfig_) {
        PrefixInterceptor = _PrefixInterceptor_;
        BastionConfig = _BastionConfig_;
    }));

    describe('uncached template URL and no relativeUrlRoot', function() {
        it('prepends / to config.url', function() {
            var result = PrefixInterceptor.request({ url: 'template.html'});
            expect(result.url).toBe('/template.html');
        });
    });

    describe('relativeUrlRoot configured', function() {
        beforeEach(function() {
          BastionConfig.relativeUrlRoot = '/foreman/';
        });

        describe('uncached template URL', function() {
            it('prepends the relative URL prefix', function() {
                var result = PrefixInterceptor.request({ url: 'template.html'});
                expect(result.url).toBe('/foreman/template.html');
            });
        });

        describe('non-template URL', function() {
            it('prepends the relative URL prefix', function() {
                var result = PrefixInterceptor.request({ url: 'api/v2/hosts'});
                expect(result.url).toBe('/foreman/api/v2/hosts');
            });
        });
    });
});

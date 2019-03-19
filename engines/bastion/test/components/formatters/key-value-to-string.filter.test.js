describe('Filter:keyValueToString', function() {
    var keyValues, keyValueFilter;

    beforeEach(module('Bastion.components.formatters'));

    beforeEach(inject(function($filter) {
        keyValues = [
            {keyname: 'keyOne', value: 'valueOne'},
            {keyname: 'keyTwo', value: 'valueTwo'},
            {keyname: 'keyThree', value: 'valueThree'},
        ];
        keyValueFilter = $filter('keyValueToString');
    }));

    it("transforms an array of key, values to a string.", function() {
        expect(keyValueFilter(keyValues)).
            toBe('keyOne: valueOne, keyTwo: valueTwo, keyThree: valueThree');
    });

    it("ensures transform value is an array before proceeding", function() {
        expect(keyValueFilter({keyname: 'key', value: 'value'})).toBe('key: value');
    });

    describe("allows overriding default defaults.", function() {
        var options;
        beforeEach(function() {
            options = {};
        });

        it("by providing a custom separator", function() {
            options.separator = '='
            expect(keyValueFilter(keyValues, options)).
                toBe('keyOne=valueOne, keyTwo=valueTwo, keyThree=valueThree');
        });

        it('by providing a custom key name', function() {
            options.keyName = 'key';
            expect(keyValueFilter({key: 'key', value: 'value'}, options)).
                toBe('key: value');
        });

        it('by providing a custom value name', function() {
            options.valueName = 'valueeee';
            expect(keyValueFilter({keyname: 'key', valueeee: 'value'}, options)).
                toBe('key: value');
        });
    });
});

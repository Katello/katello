describe('Factory: TableCahce', function () {
    var $cacheFactory, cache, TableCache, table;

    beforeEach(module('Bastion.components'));

    beforeEach(module(function ($provide) {
        cache = {
            get: function () {
                return table;
            },
            put: function () {},
            remove: function () {}
        };

        $cacheFactory = function () {
            return cache;
        };

        $provide.value('$cacheFactory', $cacheFactory);
    }));

    beforeEach(inject(function (_TableCache_) {
        TableCache = _TableCache_;
        table = {id: 1};
    }));

    it("allows adding a table to the cache", function () {
        spyOn(cache, 'put').and.callThrough();
        TableCache.setTable("table", table);
        expect(cache.put).toHaveBeenCalledWith("table", table);
    });

    it("allows removing a table from the cache", function () {
        spyOn(cache, 'remove').and.callThrough();
        TableCache.removeTable("table");
        expect(cache.remove).toHaveBeenCalledWith("table");
    });

    it("allows getting a table from the cache", function () {
        var result;
        spyOn(cache, 'get').and.callThrough();
        result = TableCache.getTable("table");
        expect(cache.get).toHaveBeenCalledWith("table");
        expect(result).toBe(table);
    });
});

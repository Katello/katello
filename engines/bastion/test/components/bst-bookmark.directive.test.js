describe('Directive: bstBookmark', function() {
    var scope,
        compile,
        compileDirective,
        element,
        elementScope,
        BstBookmark,
        bookmarks,
        $uibModal;

    compileDirective = function () {
        compile(element)(scope);
        scope.$digest();
    };

    beforeEach(module('Bastion.test-mocks', 'Bastion.components', 'components/views/bst-bookmark.html'));

    beforeEach(module(function($provide) {
        var translate = function() {
            this.$get = function() {
                return function() {};
            };

            return this;
        };

        $uibModal = {
            $get: function() {
                return this;
            }
        };

        bookmarks = ['bookmark'];

        BstBookmark = {
            failed: false,

            $get: function() {
                return this;
            },

            queryPaged: function (params, callback) {
                callback({results: bookmarks});
            },

            create: function (params, success, error) {
                if (this.failed) {
                    var response = {
                        data: {
                            error: {
                                full_message: ''
                            }
                        }
                    };
                    error(response);
                } else {
                    success();
                }
            }
        };

        $provide.provider('$uibModal', $uibModal);
        $provide.provider('translate', translate);
        $provide.provider('BstBookmark', BstBookmark);
    }));

    beforeEach(inject(function(_$compile_, _$rootScope_) {
        compile = _$compile_;
        scope = _$rootScope_;
    }));

    beforeEach(function() {
        scope.controllerName = 'controller';
        element = angular.element('<ul bst-bookmark controller-name="controllerName"></ul>');
        compileDirective();
        elementScope = element.isolateScope();
    });

    it("should set bookmarks on the scope", function () {
        spyOn(BstBookmark, 'queryPaged').and.callThrough();
        compileDirective();
        expect(BstBookmark.queryPaged).toHaveBeenCalled();
        expect(elementScope.bookmarks).toEqual(['bookmark']);
    });

    it("should display a <li>", function() {
        expect(element.find('li').length).toBe(4);
    });

    it("should open a modal upon triggering", function() {
        spyOn(elementScope, 'openModal');
        elementScope.add();
        expect(elementScope.openModal).toHaveBeenCalled();
    });

    describe("should save the bookmark", function () {
        var expectedParams;

        beforeEach(function () {
            var bookmark = {
                name: 'a bookmark',
                query: 'query',
                public: true
            };

            elementScope.newBookmark = bookmark;

            expectedParams = {
                name: bookmark.name,
                query: bookmark.query,
                public: bookmark.public,
                controller: scope.controllerName
            };

            spyOn(BstBookmark, 'create').and.callThrough();
            spyOn(BstBookmark, 'queryPaged');
        });

        afterEach(function () {
            expect(BstBookmark.create).toHaveBeenCalledWith(expectedParams, jasmine.any(Function), jasmine.any(Function));
        });

        it("and succeed", function () {
            elementScope.save();

            expect(BstBookmark.queryPaged).toHaveBeenCalled();
            expect(elementScope.$parent.successMessages.length).toBe(1);
        });

        it("and fail", function () {
            BstBookmark.failed = true;

            elementScope.save();

            expect(BstBookmark.queryPaged).not.toHaveBeenCalled();
            expect(elementScope.$parent.errorMessages.length).toBe(1);
        });
    });

    it("sets the query on bookmark selection", function () {
        var bookmark = {query: 'blah'};
        elementScope.setQuery(bookmark);
        expect(elementScope.query).toBe(bookmark.query);
    });
});

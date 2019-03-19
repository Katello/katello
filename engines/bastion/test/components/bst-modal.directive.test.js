describe('Directive: bstModal', function() {
    var scope,
        compile,
        $uibModal,
        $templateCache,
        $q,
        modalId,
        testItem,
        element,
        elementScope;

    beforeEach(module('Bastion.components', 'components/views/bst-modal.html'));

    beforeEach(module(function($provide) {
        testItem = {
            name: 'Test Name',
            taco: 'carnitas',
            delete: function() {}
        };

        $uibModal = {
            $get: function() {
                return this;
            },
            open: function() {
                var deferred = $q.defer();
                deferred.resolve({});

                return {
                    result: deferred.promise
                }
            }
        };

        $provide.provider('$uibModal', $uibModal);
    }));

    beforeEach(inject(function(_$compile_, _$rootScope_, _$q_, _$templateCache_) {
        compile = _$compile_;
        scope = _$rootScope_;
        $q = _$q_;
        $templateCache = _$templateCache_;
    }));

    beforeEach(function() {
        var html = '<span bst-modal="item.delete(item)">' +
                     '<p data-block="modal-header">Header</p>' +
                     '<p data-block="modal-body">Body</p>' +
                   '</span>';

        element = angular.element(html);
        spyOn($templateCache, 'put').and.callThrough();

        compile(element)(scope);
        scope.$digest();

        elementScope = element.scope();
        modalId = $templateCache.put.calls.mostRecent().args[0];
    });

    it("uses angular-blocks to extend a modal template", function () {
        var modal = $templateCache.get(modalId);

        expect($templateCache.put).toHaveBeenCalled();
        expect(modal.attr('extend-template')).toBe('components/views/bst-modal.html');
        expect(modal.find('[data-block="modal-header"]').html()).toBe('Header');
        expect(modal.find('[data-block="modal-body"]').html()).toBe('Body');
    });

    it("allows the opening of a modal dialog via bootstrap ui", function() {
        spyOn($uibModal, 'open').and.callThrough();

        elementScope.openModal();

        expect($uibModal.open).toHaveBeenCalled();
    });
    
    it("allows the specification of a modal templateUrl", function() {
        var html = '<span bst-modal="item.delete(item)" template-url="blah.html"></span>';

        element = angular.element(html);
        compile(element)(scope);
        scope.$digest();

        spyOn($uibModal, 'open').and.callThrough();

        elementScope.openModal();

        expect($uibModal.open.calls.mostRecent().args[0].templateUrl).toBe('blah.html');
    });
});

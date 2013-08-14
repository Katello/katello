angular.module('alchemy').directive('scrollWithPage', ['$window', function ($window) {
    return {
        link: function (scope, element){
            var elementOriginalOffset = $(element).offset().top;
            angular.element($window).bind('scroll', function () {
                var windowScrollTop = $($window).scrollTop();
                if (windowScrollTop > elementOriginalOffset) {
                    element.addClass('scrolling');
                } else {
                    element.removeClass('scrolling');
                }
            });
        }
    };
}]);
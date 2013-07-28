angular.module('alchemy').directive('scrollWithPage', ['$window', function ($window) {
    return {
        link: function (scope, element){
            var element_original_offset = $(element).offset().top;
            angular.element($window).bind('scroll', function () {
                var window_scroll_top = $($window).scrollTop();
                if (window_scroll_top > element_original_offset) {
                    element.addClass('scrolling');
                } else {
                    element.removeClass('scrolling');
                }
            });
        }
    };
}]);
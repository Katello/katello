$(function(){
    $('.scroll-pane').jScrollPane({ hideFocus: true });
    $('.jspPane').resize(function(event){
        var element = $('.scroll-pane');
        if (element.length){
            element.data('jsp').reinitialise();
        }
    });
});
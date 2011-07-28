$(function(){
    $('.scroll-pane').jScrollPane();
    $('.jspPane').resize(function(event){
        var element = $('.scroll-pane');
        if (element.length){
            element.data('jsp').reinitialise();
        }
    });
});
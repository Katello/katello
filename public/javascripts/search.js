$(document).ready(function() {
    $('#search_favorite_save').live("click", favorite.save);
    $('#search_favorite_destroy').live("click", favorite.destroy);
});

var favorite = (function() {
    return {
        //custom successCreate - calls notices update and list/panel updates from panel.js
        success : function(data) {
            $(".qdropdown").html(data);
        },
        error : function(data) {
        },
        save : function(event) {
            // we want to submit the request using Ajax (prevent page refresh)
            event.preventDefault();

            var newFavorite = $('input[id^=search]').attr('value');
            var url = $(this).attr('data-url');

            // send a request to the server to save/create this favorite
            search.create_favorite(newFavorite, url, favorite.success, favorite.error);
        },
        destroy : function (data) {
            var id  = $(this).attr('data-id');
            var url = $(this).attr('data-url');

            // send a request to the server to save/create this favorite
            client_common.destroy(url, favorite.success, favorite.error);
        }
    }
})();

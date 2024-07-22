$(document).on('loadJS', function() {
    $('body').on('click', '#download_debug_cert_key', function(e) {
        e.preventDefault();
        window.location.href = $("#download_debug_cert_key").data("url");
        return false;
    });
});

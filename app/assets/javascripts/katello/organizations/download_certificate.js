$(document).ready(function() {
    $('#download_debug_cert_key').live('click', function(e) {
        e.preventDefault();
        window.location.href = $("#download_debug_cert_key").data("url");
        return false;
    });
});

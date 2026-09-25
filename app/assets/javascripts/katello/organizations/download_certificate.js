$(document).on('loadJS', function() {
    // Load available key algorithms dynamically using cert_mapping approach
    var $select = $('#key_algorithm_select');
    var algorithmsUrl = $select.data('algorithms-url');
    var algorithmData = {}; // Store algorithm data including signature OIDs

    if (algorithmsUrl) {
        $.ajax({
            url: algorithmsUrl,
            type: 'GET',
            dataType: 'json',
            success: function(data) {
                $select.empty();

                // Add algorithm options from cert_mapping-based API
                if (data.results && data.results.length > 0) {
                    $.each(data.results, function(index, algorithm) {
                        // Store the full algorithm data for later use
                        algorithmData[algorithm.oid] = algorithm;

                        $select.append($('<option></option>')
                            .attr('value', algorithm.oid)
                            .text(algorithm.name));
                    });
                } else {
                    // Fallback if no algorithms are available
                    $select.append($('<option></option>')
                        .attr('value', '')
                        .text('No algorithms available'));
                }
            },
            error: function() {
                $select.empty();
                $select.append($('<option></option>')
                    .attr('value', '')
                    .text('Error loading algorithms'));
            }
        });
    }

    // Handle download button click
    $('body').on('click', '#download_debug_cert_key', function(e) {
        e.preventDefault();
        var baseUrl = $("#download_debug_cert_key").data("url");
        var keyAlgorithm = $("#key_algorithm_select").val();
        var url = baseUrl;

        if (keyAlgorithm) {
            var algorithm = algorithmData[keyAlgorithm];
            url = baseUrl + "?key_algorithms[]=" + encodeURIComponent(keyAlgorithm);

            // Add signature algorithm if available
            if (algorithm && algorithm.signature_oid) {
                url += "&signature_algorithms[]=" + encodeURIComponent(algorithm.signature_oid);
            }
        }

        window.location.href = url;
        return false;
    });
});

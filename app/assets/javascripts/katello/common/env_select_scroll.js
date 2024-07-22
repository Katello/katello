

KT.env_select_scroll = function(options) {


    var anchor_padding = 0, //amount of padding each anchor has
        min_size = 40,
        min_size_selected = 75,
        px_per_sec = 400,
        freq = 20;

    var bind = function(element) {
        if (!element) {
            element = ".jbreadcrumb";
        }

        $(element).find('ul').each(function() {
            var trail = $(this),
                cont_width = $('.path_selector').width(),
                combined_width = 0,
                anchors = trail.find("a, label"),
                my_min_size_selected = min_size_selected;
            anchors.off("mouseout").off("mouseover").width('auto');

            anchors.each(function() {
                combined_width += $(this).width() + anchor_padding;
            });


            //if nothing is selected in this path, we won't have a special node that is bigger
            //   so reset min-size_selected to normal min_size for calculations
            if (trail.find(".active").length === 0) {
                my_min_size_selected = min_size;
            }


            //if we don't actually need more room, then don't add the scrolling
            if (combined_width < cont_width) {
                return true;
            }


            anchors.each(function(index) {
                var anchor = $(this),
                    out_interval,
                    over_interval,
                    total_width = anchor.outerWidth(),
                    my_min_size = min_size;


                //taken width is the width of all of the nodes contracted minus this one (includes selected ndoe)
                var taken_width = ((anchor_padding + min_size) * (anchors.length-2)) + anchor_padding + my_min_size_selected;

                //if the container is smaller than all of the other nodes + this one expanded, we need to shorten it
                if (cont_width <  (taken_width + total_width + anchor_padding) ) {
                    total_width = cont_width - taken_width - anchor_padding - 5 ;
                }

                //if its active and the min size of a selected node is smaller than what we had calculated, just use that
                if (anchor.hasClass("active")) {
                    my_min_size = my_min_size_selected;
                    if (my_min_size > total_width) {
                        return;
                    }
                }

                //reset the width to contracted state
                $(this).width(my_min_size);

                var total_time = (total_width - min_size)/px_per_sec,  //total time of animation
                    num_iterations = total_time*1000/freq,  //number of 'frames'
                    chunk_size = (total_width - min_size)/num_iterations; //how many pixels to move each frame


                var clear_out = function() {
                    if (out_interval) {
                        clearInterval(out_interval);
                        out_interval = undefined;
                    }
                },
                clear_over = function() {
                    if (over_interval) {
                        clearInterval(over_interval);
                        over_interval = undefined;
                    }
                };


                anchor.on("mouseover", function() {
                    if (over_interval) {
                        return false;
                    }

                    clear_out();

                    over_interval = setInterval(function() {
                        var width = anchor.outerWidth();
                        if (width < total_width) {
                            clear_out();
                            anchor.width((width+chunk_size));
                        }
                        else {
                            clear_over();
                        }
                    }, freq);
                });

                anchor.on("mouseout", function() {
                    if (out_interval) {
                        return false;
                    }

                    clear_over();


                    out_interval = setInterval(function() {
                        var width = anchor.width();
                        if (width >= my_min_size) {
                            clear_over();
                            anchor.width(width-chunk_size);
                        }
                        else {
                            clear_out();
                        }
                    }, freq);
                });

            });
        });
    };

    return {bind:bind};
};

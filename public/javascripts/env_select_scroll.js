

KT.env_select_scroll = function(options) {


    var anchor_padding = 20, //amount of padding each anchor has
        min_size = 25,
        px_per_sec = 400,
        freq = 20;

    var bind = function(element) {
        if (!element) {
            element = ".jbreadcrumb";
        }

        $(element).each(function() {
            var trail = $(this),
                cont_width = $(this).width(),
                combined_width = 0,
                anchors = trail.find("a");
                
            anchors.unbind("mouseout").unbind("mouseover").width('auto');

            anchors.each(function() {
                combined_width += $(this).width() + anchor_padding;

            });

            

            //if we don't actually need more room, then don't add the scrolling
            if (combined_width < cont_width) {
                return true;
            }


            
            anchors.each(function() {
                var anchor = $(this),
                    out_interval = undefined,
                    over_interval= undefined,
                    total_width = anchor.width();


                if (cont_width < ((anchor_padding + min_size) * (anchors.length)) + anchor_padding + total_width - 10) {
                    total_width = cont_width -  ((anchor_padding + min_size) * (anchors.length) + anchor_padding -10);

                }

                $(this).width(min_size);

                var total_time = (total_width - min_size)/px_per_sec,
                    num_iterations = total_time*1000/freq,
                    chunk_size = (total_width - min_size)/num_iterations;


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


                anchor.mouseover(function() {
                    if (over_interval) {
                        return false;
                    }

                    clear_out();

                    over_interval = setInterval(function() {
                        var width = anchor.width();
                        if (width < total_width) {
                            clear_out();
                            anchor.width(width+chunk_size);
                        }
                        else {
                            clear_over();
                        }
                    }, freq);
                });

                anchor.mouseout(function() {
                    if (out_interval) {

                        return false;
                    }

                    clear_over();

                    out_interval = setInterval(function() {
                        var width = anchor.width();
                        if (width > min_size) {
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

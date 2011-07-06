/**
 Copyright 2011 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
*/

$(document).ready(function() {

  $('form[id^=new_sync_plan]').live('submit', function(e) {
    //disable submit
    $(':submit', this).attr('disabled', 'disabled');
    e.preventDefault();
    $(this).ajaxSubmit({success:sync_plan.successCreate, error:sync_plan.errorCreate});
  });

  $.editable.addInputType( 'datepicker', {

    /* create input element */
    element: function( settings, original ) {
      var form = $( this ), input = $( '<input data-change="false"/>' );
      if (settings.width != 'none') { input.width(settings.width); }
      if (settings.height != 'none') { input.height(settings.height); }
      input.attr( 'autocomplete','off' );
      form.append( input );
      return input;
    },

    /* attach jquery.ui.datepicker to the input element */
    plugin: function( settings, original ) {
      var form = this, input = form.find( "input" );
      settings.onblur = 'nothing';

      datepicker = {
        // keep track of date selection state
        onSelect: function() {
          input.attr('data-change', 'true'); 
        },
        // reset form if we lose focus and date was not selected
        onClose: function() {
          if ($(this).attr('data-change') == 'false') {
            original.reset( form );
          } 
        }
      };
      input.datepicker(datepicker);
    }
  } );

  $.editable.addInputType( 'timepicker', {

    /* create input element */
    element: function( settings, original ) {
      var form = $( this ), input = $( '<input data-change="false"/>' );
      if (settings.width != 'none') { input.width(settings.width); }
      if (settings.height != 'none') { input.height(settings.height); }
      input.attr( 'autocomplete','off' );
      form.append( input );
      return input;
    },

    plugin: function( settings, original ) {
      var form = this, input = form.find( "input" );
      settings.onblur = 'ignore';
      input.timepickr({convention: 12})
      .click();
    }
  } );

  $("#datepicker").live('mousedown', function() {
     $(this).datepicker({
       changeMonth: true,
       changeYear: true
     });
  });

  $("#timepicker").live('mousedown', function() {
     $(this).timepickr({
       convention: 12
     });
  });

});

var sync_plan = (function() {
    return {
      successCreate : function(data) {
        //panel.js calls
        list.add(data);
        panel.closePanel($('#panel'));
      },
      errorCreate : function(data) {
        $('#plan_save:submit').removeAttr("disabled");
      }
    }

})();

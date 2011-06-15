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

   ratings =
      [{'minScore': 0,
       'className': 'meterFail',
       'text': i18n.very_weak
      },
      {'minScore': 25,
       'className': 'meterWarn',
       'text': i18n.weak
      },
      {'minScore': 50,
       'className': 'meterGood',
       'text': i18n.good
      },
      {'minScore': 75,
       'className': 'meterExcel',
       'text': i18n.strong
      }];

   $('#password_field').simplePassMeter({
      'container': '#password_meter',
      'offset': 10,
      'showOnFocus':false,
      'requirements': {},
      'defaultText':i18n.meterText,
      'ratings':ratings});



    $('#helptips_enabled').bind('change', checkboxChanged);

    $(".multiselect").multiselect({"dividerLocation":0.5, "sortable":false});
});

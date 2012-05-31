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


    KT.my_env_select = KT.path_select('my_env_selector', 'env', KT.available_environments,
        {select_mode:'multi', button_text:"Go"})

    $(document).bind(KT.my_env_select.get_event(), function(event, foo){console.log(foo)});
});
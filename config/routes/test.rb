if Rails.env.test?
  Src::Application.routes.draw do

    match 'a_test/a_controller/failing_action' => 'a_controller_test/a#failing_action', :via => :get

  end
end

namespace :gettext do
  def files_to_translate
    Dir.glob("{app,lib,config,locale,vendor/converge-ui}/**/*.{rb,erb,haml,slim,rhtml}")
  end
end

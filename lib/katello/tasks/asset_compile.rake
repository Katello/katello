desc 'Compile Katello assets'
task 'assets:precompile:katello' do
 
  # Partially load the Rails environment to avoid
  # the need of a database being setup
  Rails.application.initialize!(:assets)

  def compile_assets(args)
    require 'uglifier'

    precompile = args.fetch(:precompile, [])

    _ = ActionView::Base
    
    target = File.join(Katello::Engine.root, 'public', 'assets')

    config = Rails.application.config
    env = Rails.application.assets

    config.assets.digests   = {}
    config.assets.manifest  = File.join(target)
    config.assets.compile   = args.fetch(:compile, true)
    config.assets.compress  = args.fetch(:compress, true)
    config.assets.digest    = args.fetch(:digest, true)
    config.assets.js_compressor = Uglifier.new(:mangle => false)

    Sprockets::Bootstrap.new(Rails.application).run
    compiler = Sprockets::StaticCompiler.new(env,
                                             target,
                                             precompile,
                                             :manifest_path => config.assets.manifest,
                                             :digest => config.assets.digest,
                                             :manifest => true)
    compiler.compile
  end

  def compile_fonts
    compile_assets(
      precompile: [/\.(?:svg|eot|woff|ttf)$/],
      digest: false
    )
  end

  def compile_javascript_stylesheets
    asset_dir = "#{Katello::Engine.root}/app/assets/javascripts/"

    asset_paths = Dir[File.join(asset_dir, '**', '*') ].reject { |file| File.directory?(file) }
    asset_paths.each do |file| 
      file.slice!(asset_dir)
    end

    precompile = [
      'katello/katello.css',
      'stylesheets/less/bastion.css',
      'stylesheets/scss/bastion.css',
      'bastion.js',
    ]

    asset_paths.each do |asset|
      precompile.append(asset)
    end


    compile_assets(
      precompile: precompile
    )
  end

  compile_fonts
  compile_javascript_stylesheets
end

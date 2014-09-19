desc 'Compile Katello assets'
task 'assets:precompile:katello' do
  # Partially load the Rails environment to avoid
  # the need of a database being setup
  Rails.application.initialize!(:assets)

  def compile_assets(args = {})
    require 'uglifier'
    require 'less-rails'

    precompile = args.fetch(:precompile, [])

    _ = ActionView::Base
    
    target = File.join(Katello::Engine.root, 'public', 'assets')

    config = Rails.application.config
    env = Rails.application.assets

    config.assets.digests   = {}
    config.assets.manifest  = File.join(target, 'katello')
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

  def find_assets(args = {})
    type = args.fetch(:type, nil)
    asset_dir = "#{Katello::Engine.root}/app/assets/#{type}/"

    asset_paths = Dir[File.join(asset_dir, '**', '*') ].reject { |file| File.directory?(file) }
    asset_paths.each { |file| file.slice!(asset_dir) }

    asset_paths
  end

  def compile_fonts
    compile_assets(
      precompile: [/bastion\S+.(?:svg|eot|woff|ttf)$/],
      digest: false
    )
  end

  def compile_javascript_stylesheets
    javascripts = find_assets(:type => 'javascripts')
    images = find_assets(:type => 'images')

    precompile = [
      'katello/katello.css',
      'bastion/bastion.css',
      'bastion/bastion.js',
    ]
    precompile.concat(javascripts)
    precompile.concat(images)

    # Used to add index manifest files to the paths for
    # proper resolution and addition when running Rails 3.2.8
    # in the SCL
    precompile.each do |asset|
      if File.basename(asset)[/[^\.]+/, 0] == 'index'
        asset.sub!(/\/index\./, '.')
        precompile << asset
      end
    end

    compile_assets(:precompile => precompile, :digest => false)
    compile_assets(:precompile => precompile)
  end

  compile_fonts
  compile_javascript_stylesheets
end

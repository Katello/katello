module YARD
  module Server
    module Commands
      class DisplayFileCommand < LibraryCommand

        # return svg images in responses
        def run
          ppath = library.source_path
          filename = File.cleanpath(File.join(library.source_path, path))
          raise NotFoundError if !File.file?(filename)
          if filename =~ /\.(jpe?g|gif|png|bmp|svg)$/i
            headers['Content-Type'] = StaticFileCommand::DefaultMimeTypes[$1.downcase] ||
                ("image/svg+xml" if $1.downcase == 'svg') || 'text/html'
            render IO.read(filename)
          else
            file = CodeObjects::ExtraFileObject.new(filename)
            options.update(:object => Registry.root, :type => :layout, :file => file)
            render
          end
        end
      end
    end
  end
end

path = File.expand_path("../../yard-template/default/fulldoc/html/", File.dirname(__FILE__))
YARD::Server.register_static_path path

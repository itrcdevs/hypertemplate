require 'hypertemplate' unless defined? ::Hypertemplate

module Hypertemplate
  module Hook
    module Tilt

      class HypertemplateTilt < ::Tilt::Template

        self.default_mime_type = 'application/json'

        def self.engine_initialized?
          defined? ::Hook::Tilt::HypertemplateTilt
        end

        def initialize_engine
          require_template_library 'hypertemplate'
        end

        def prepare
          #@media_type = options[:media_type] || @options[:media_type]
          #raise Hypertemplate::BuilderError.new("Content type required to build representation.") unless @media_type
        end

        def precompiled_preamble(locals)
          local_assigns = super
          <<-RUBY
            begin
              unless self.class.method_defined?(:hypertemplate_registry)
                def hypertemplate_registry
                  Hypertemplate::Registry.new.tap do |registry|
                    registry << Hypertemplate::Builder::Json
                    registry << Hypertemplate::Builder::Xml
                  end
                end
              end
              @content_type_helpers = hypertemplate_registry["#{@options[:media_type]}"].helper
              extend @content_type_helpers
              extend Hypertemplate::Hook::Rails::Helpers
              #{local_assigns}
          RUBY
        end

        def precompiled_postamble(locals)
          <<-RUBY
            end
          RUBY
        end

        def precompiled_template(locals)
          data.to_str
        end
      end

      ::Tilt.register HypertemplateTilt, 'hypertemplate'
      ::Tilt.register HypertemplateTilt, 'tokamak'
      ::Tilt.register HypertemplateTilt, 'hyper'

    end
  end
end

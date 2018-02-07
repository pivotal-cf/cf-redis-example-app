require 'yaml'

module CF::App
  class Environment
    class Variable
      attr_reader :name, :method, :parameter, :key

      TYPES_TO_METHOD_NAMES = {
        'label' => 'find_by_service_label',
        'name' => 'find_by_service_name'
      }

      def initialize(options)
        @name = options.fetch('name')
        @method = options.fetch('method')
        @parameter = options.fetch('parameter')
        @key = options.fetch('key')
      end

      def derived_method
        TYPES_TO_METHOD_NAMES.fetch(method)
      end
    end

    class << self
      def set!(*args)
        environment.set!(*args)
      end

      def set_from_yaml!(*args)
        environment.set_from_yaml!(*args)
      end

      def environment
        Environment.new(ENV)
      end

      private :environment
    end

    def initialize(env)
      @credentials = Credentials.new(env)
      @env = env
    end

    def set!(*env_var_config)
      env_var_config.flatten.each do |ev_config|
        var = Variable.new(ev_config)
        env[var.name] = credential_value(var)
      end
    end


    def set_from_yaml!(yaml_file)
      env_var_config = YAML.load_file(yaml_file)
      set!(env_var_config)
    end

    private

    def credential_value(var)
      credential = credentials.public_send(var.derived_method, var.parameter)
      raise KeyError unless credential
      credential.fetch(var.key)
    end

    attr_reader :credentials, :env
  end
end

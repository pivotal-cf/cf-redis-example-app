module CF::App
  class Credentials
    class << self
      def find_by_service_name(name)
        credentials.find_by_service_name(name)
      end

      def find_all_by_service_tag(tag)
        credentials.find_all_by_service_tag(tag)
      end

      # Returns credentials for the service instances with all the given +tags+.
      def find_all_by_all_service_tags(tags)
        credentials.find_all_by_all_service_tags(tags)
      end

      # Returns credentials for the first service instance with the given +tag+.
      def find_by_service_tag(tag)
        credentials.find_by_service_tag(tag)
      end

      # Returns credentials for the first service instance with the given +label+.
      def find_by_service_label(label)
        credentials.find_by_service_label(label)
      end

      # Returns credentials for all service instances with the given +label+.
      def find_all_by_service_label(label)
        credentials.find_all_by_service_label(label)
      end

      def credentials
        Credentials.new(ENV)
      end
      private :credentials
    end

    def initialize(env)
      @locator = Service.new(env)
    end

    # Returns credentials for the service instance with the given +name+.
    def find_by_service_name(name)
      service = locator.find_by_name(name)
      service['credentials'] if service
    end

    # Returns credentials for the first service instance with the given +tag+.
    def find_by_service_tag(tag)
      service = locator.find_by_tag(tag)
      service['credentials'] if service
    end

    def find_all_by_service_tag(tag)
      services = locator.find_all_by_tag(tag)
      services.map do |service|
        service['credentials']
      end
    end

    # Returns credentials for the service instances with all the given +tags+.
    def find_all_by_all_service_tags(tags)
      return [] if tags.empty?

      locator.find_all_by_tags(tags).map { |service| service['credentials'] }
    end

    # Returns credentials for the first service instance with the given +label+.
    def find_by_service_label(label)
      service = locator.find_by_label(label)
      service['credentials'] if service
    end

    # Returns credentials for all service instances with the given +label+.
    def find_all_by_service_label(label)
      services = locator.find_all_by_label(label)
      services.map do |service|
        service['credentials']
      end
    end

    private

    attr_reader :locator

  end
end

require 'open-uri'

module Rhomobile
  module Nav
    class Base
      def initialize(app, options={})
        @app     = app
        @options = options
        @options[:status] ||= [200]
      end

      def call(env)
        @enviroment = env
        @status, @headers, @body = @app.call(env)
        @body.extend(Enumerable)
        @body = @body.to_a.join
        insert! if can_insert?(env)
        [@status, @headers, [@body]]
      end

      def can_insert?(env)
        return unless @options[:status].include?(@status)
        return unless @headers['Content-Type'] =~ /text\/html/ || @headers['content-type'] =~ /text\/html/
        true
      end
      
      def insert!
        @body.gsub!(/(<\/head>)/i, "\\1#{header}")
        @body.gsub!(/(<\/body>)/i, "#{footer}\\1")
        @headers['Content-Length'] = @body.length.to_s
      end
      
      def footer
        open(footer_uri).read
      end
      
      def header
        if @enviroment['HTTP_COOKIE'] && @enviroment['HTTP_COOKIE'].include?('rho_user')
          user = @enviroment['HTTP_COOKIE']
          open(header_uri(user)).read
        else
          open(header_uri).read
        end
      end
      
      def header_uri(user=nil)
        if user
          "#{host}+/nav/#{user}"
        else
          "#{host}+/nav"
        end
      end
      
      def footer_uri
        "#{host}+/footer"
      end
      
      def host
        host = @enviroment['HTTP_HOST'] || "#{@enviroment['SERVER_NAME'] || @enviroment['SERVER_ADDR']}:#{@enviroment['SERVER_PORT']}"
        host
      end

    end

  end
end

require 'open-uri'

module Rhomobile
  module Nav
    class Base
      def initialize(app, options={})
        @app     = app
        @options = options
        @options[:nav_host] ||= "http://rhohub.com"
        @nav_host = @options[:nav_host]
      end

      def call(env)
        @env = env
        @status, @headers, @body = @app.call(env)
        @body.extend(Enumerable)
        @body = @body.to_a.join
        insert! if can_insert?(env)
        [@status, @headers, [@body]]
      end

      def can_insert?(env)
        return unless @status == 200
        return unless @headers['Content-Type'] =~ /text\/html/ || @headers['content-type'] =~ /text\/html/
        return if env['PATH_INFO'] == "/nav"
        true
      end
      
      def insert!
        @body.gsub!(/(<body>)/i, "\\1#{header}")
        #@body.gsub!(/(<\/body>)/i, "#{footer}\\1")
        @headers['Content-Length'] = @body.length.to_s
      end
      
      def footer
        open("#{@nav_host}/footer").read
      end
      
      def header
        if @env['HTTP_COOKIE'] && @env['HTTP_COOKIE'].include?('rho_user')
          user = @env['HTTP_COOKIE']['rho_user']
          open("#{@nav_host}/nav/#{user}").read
        else
          open("#{@nav_host}/nav").read
        end
      end

    end

  end
end

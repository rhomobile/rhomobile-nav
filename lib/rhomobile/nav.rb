require 'open-uri'

module Rhomobile
  module Nav
    class Base
      def initialize(app, options={})
        @app     = app
        @options = options
        @options[:nav_host] ||= "http://rhonav.rhohub.com"
        @nav_host = @options[:nav_host]
      end
      
      def call(env)
        dup._call(env)
      end
      

      def _call(env)
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
        true
      end
      
      def insert!
        @body.gsub!(/(<body.*>)/i, "\\1#{header}")
        #@body.gsub!(/(<\/body>)/i, "#{footer}\\1")
        @headers['Content-Length'] = @body.length.to_s
      end
      
      def footer
        open("#{@nav_host}/footer").read
      end
      
      def header
        cookies = Rack::Request.new(@env).cookies
        user = cookies["rho_user"]
        if user
          open("#{@nav_host}/nav/#{user}").read
        else
          open("#{@nav_host}/nav").read
        end
      end

    end

  end
end

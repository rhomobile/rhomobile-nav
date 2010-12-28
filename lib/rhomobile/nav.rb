require 'open-uri'

module Rhomobile
  module Nav
    class Base
      def initialize(app, options={})
        @app     = app
        @options = options
        @options[:nav_host] ||= "http://rhonav.rhohub.com"
        @options[:blog] ||= false
        @options[:subscribe] ||= false
        @options[:support] ||= false
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
        return unless @headers['Content-Type'] =~ /text\/html/ || @headers['content-type'] =~ /text\/html/
        true
      end
      
      def insert!
        @body.gsub!(/(<body.*>)/i, "\\1#{header}")        
        @headers['Content-Length'] = @body.length.to_s        
        @body.gsub!(/(<\/body>)/i, "#{footer}\\1")
      end
      
      def footer         
        open("#{@nav_host}/footer/nav").read
      end
      
      def header
        cookies = Rack::Request.new(@env).cookies
        user = cookies["rho_user"]
        url = "#{@nav_host}/nav"
        if user
          open("#{url}/#{user}?blog=#{@options[:blog]}&subscribe=#{@options[:subscribe]}&support=#{@options[:support]}").read
        else
          open(url+"?blog=#{@options[:blog]}&subscribe=#{@options[:subscribe]}&support=#{@options[:support]}").read
        end
      end

    end

  end
end

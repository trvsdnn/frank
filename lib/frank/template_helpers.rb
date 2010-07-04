require 'frank/lorem'

module Frank
  module TemplateHelpers
    include FrankHelpers if defined? FrankHelpers
  
    def render_partial(path, *locals)
      pieces = path.split('/')
      partial = '_' + pieces.pop
      locals = locals.empty? ? nil : locals[0]
      render(File.join(pieces.join('/'), partial), partial=true, locals)
    end
    
    def lorem
      Frank::Lorem.new(@environment)
    end
    
    def refresh
      if @environment == :output || @environment == :production
        nil
      else
        <<-JS
          <script type="text/javascript">
          (function(){
            var when = #{Time.now.to_i};

            function process( raw ){
              if( eval(raw)[0] > when )
                window.location.reload();
            }

            (function poll(){
              var req = new XMLHttpRequest();  
              req.open('GET', '/__refresh__', true);  
              req.onreadystatechange = function (aEvt) {  
                if ( req.readyState == 4 && req.status == 200 )
                  process(req.responseText);
              };
              req.send(null);
              setTimeout( poll, 1000 );
            })();

          })();
          </script>
        JS
      end
    end
    
  end
end

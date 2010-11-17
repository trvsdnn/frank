require 'frank/lorem'

module Frank
  module TemplateHelpers
    include FrankHelpers if defined? FrankHelpers

    def render_partial(path, *locals)
      pieces = path.split('/')
      partial = '_' + pieces.pop
      locals = locals.empty? ? nil : locals[0]
      render(File.join(pieces.join('/'), partial), partial = true, locals)
    end

    def lorem
      Frank::Lorem.new
    end

    def refresh
      if Frank.exporting?
        nil
      else
        <<-JS
          <script type="text/javascript">
          (function(){
            var when = #{Time.now.to_i};

            function process( raw ){
              var num = parseInt(raw);
              if( parseInt(raw) > when ) {
                window.location.reload();
              }
            }
            
            (function (){
              var req = (typeof XMLHttpRequest !== "undefined") ? new XMLHttpRequest() : new ActiveXObject("Microsoft.XMLHTTP");
              req.onreadystatechange = function (aEvt) {
                if ( req.readyState === 4 ) {
                  process( req.responseText );
                }
              };
              req.open('GET', '/__refresh__', true);
              req.send( null );
              setTimeout( arguments.callee, 1000 );
            })();

          })();
          </script>
        JS
      end
    end

  end
end

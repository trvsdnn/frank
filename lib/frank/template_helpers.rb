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
    
    def content_for(name, &block)
      @content_for ||= {}
      
      if block_given?
        @content_for[name.to_sym] = capture(&block)
      else
        @content_for[name.to_sym]
      end
    end
    
    def content_for?(name)
      !@content_for[name.to_sym].nil?
    end
    
    def capture(&block)
      erbout        = eval('_erbout', block.binding)
      erbout_length = erbout.length

      block.call
      
      erbout_addition = erbout[erbout_length..-1]
      erbout[erbout_length..-1] = ''

      erbout_addition
    end

    def refresh
      if Frank.exporting?
        nil
      else
        <<-JS
          <script type="text/javascript">
          (function(){
            var when = #{Time.now.to_i};
            var loading = false
            function addLoadingIndicator() {
              var body = document.getElementsByTagName("body")[0]
              var div = document.createElement('div')
              div.innerHTML = 'Change detected. Reloading. Please wait ...'
              div.setAttribute('style', 'z-index: 1000; position: fixed; top: 0; right: 40%; background: #901010; font-weight: bold; color: white; font-size: 16px; text-align: center; padding-top: 10px; width: 400px; font-family: sans; height: 30px; opacity: 0.8; border: 1px solid #601010')
              body.appendChild(div)
            }

            function process( raw ){
              if( parseInt(raw) > when ) {
                if (!loading) {
                  loading = true
                  addLoadingIndicator();
                  window.location.reload();
                }
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
              if (!loading)
                setTimeout( arguments.callee, 1000 );
            })();

          })();
          </script>
        JS
      end
    end

  end
end

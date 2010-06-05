require 'frank/lorem'

module Frank
  module TemplateHelpers
    include FrankHelpers if defined? FrankHelpers
  
    def render_partial(path)
      pieces = path.split('/')
      partial = '_' + pieces.pop
      render(File.join(pieces.join('/'), partial))
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
            var template_path = '#{@template_path}',
                layout_path = '#{@layout_path}',
                when = #{Time.now.to_i};

            function process( raw ){
              var stamps = eval(raw);
              if( stamps[0] > when || stamps[1] > when )
                window.location.reload();
            }

            (function poll(){
              var req = new XMLHttpRequest();  
              req.open('GET', '/__refresh__?template_path=' + template_path + '&layout_path=' + layout_path, true);  
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
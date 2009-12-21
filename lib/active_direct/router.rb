# this is the router of ActiveDirect, implemented as rack middleware
module ActiveDirect
  class Router
    def initialize(app, router_path)
      @app = app
      @router_path = router_path
    end

    def call(env)
      @env = env
      if env["PATH_INFO"].match("^#{@router_path}")
        @post_data = get_post_data
        result = process_rpc
        [200, { "Content-Type" => "text/plain"}, [result]]
      else
        @app.call(@env)
      end
    end

    def process_rpc
      resp = []
      actions.each { |a| resp << invoke_method(a.model, a.method, a.parameters, a.tid) }

      if form_post_and_upload?
        "<html><body><textarea>#{resp.to_json}</textarea></body></html>"
      else
        resp.to_json
      end
    end

    def invoke_method(model, method, parameters, tid)
      result = {
        'type'    =>    'rpc',
        'tid'     =>    tid,
        'action'  =>    model,
        'method'  =>    method
      }
      if(!Config.has_model?(model))
        raise "Invalid Model."
      end

      if(!Config.has_method?(model, method))
        raise "Invalid method:#{method} called on model:#{model}."
      end
      unless parameters.nil?
        return_val = model.constantize.send(method, *normalize_params_for(model,parameters))
      else
        return_val = model.constantize.send(method)
      end
      result['result'] = return_val.nil? ?  "" : return_val
    rescue => e
      Rails.logger.error result['type'] = 'exception'
      Rails.logger.error result['message'] = e.message
      Rails.logger.error result['where'] = e.backtrace.join("\n")
    ensure
      return result
    end

    private

    def actions
      req_actions = []
      if raw_post?
        if @post_data.is_a? Array
          @post_data.each {|p| req_actions << Action.new(p['action'], p['method'], p['data'], p['tid']) }
        else
          req_actions << Action.new(@post_data['action'], @post_data['method'], @post_data['data'], @post_data['tid'])
        end
      else
        req_actions << Action.new(@post_data['extAction'], @post_data['extMethod'], @post_data,  @post_data['extTID'])
      end
      req_actions
    end

    def normalize_params_for(model, params)
      if raw_post?
				params = params.map {|p| Hash === p ? p.symbolize_keys : p }
        return params
      else
        normalized_params = params[model.downcase]
        normalized_params.each do |k, v|
          if v.is_a?(Hash) && v.include?('tempfile') && v['tempfile'].is_a?(Tempfile)
            normalized_params[k] = v['tempfile']
          end
        end
        [normalized_params.symbolize_keys]
      end
    end

    def get_post_data
      @env["RAW_POST_DATA"] ? get_raw_post_data : get_form_post_data
    end

    def get_raw_post_data
      raw_post_data = ActiveSupport::JSON.decode(@env['RAW_POST_DATA'])
      with_indifferent_access_for_hash(raw_post_data)
    end

    def get_form_post_data
      form_post_data = @env['rack.request'].params
      with_indifferent_access_for_hash(form_post_data)
    end

    def with_indifferent_access_for_hash(data)
      return unless Array === data || Hash === data
      Array === data ? data.map {|hsh| hsh.with_indifferent_access } : data.with_indifferent_access
    end


    def raw_post?
      @env["RAW_POST_DATA"]
    end

    def form_post_and_upload?
      form_post? && @post_data["extUpload"] == 'true'
    end

    def form_post?
      !@post_data.is_a?(Array) && @post_data["extAction"]
    end

  end
end
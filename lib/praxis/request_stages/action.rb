module Praxis
  module RequestStages

    class Action < RequestStage 
      
      def execute
        if controller.method(action.name).arity == 0
          response = controller.__send__(action.name)
        else
          response = controller.__send__(action.name, **request.params_hash)
        end

        case response
        when String
          controller.response.body = response
        when Praxis::Response
          controller.response = response
        else
          raise "Action #{action.name} in #{controller.class} returned #{response.inspect}. Only Response objects or Strings allowed."
        end
        controller.response.request = request
        nil # Action cannot return its OK request, as it would indicate the end of the stage chain
      end
            
    end

  end
end
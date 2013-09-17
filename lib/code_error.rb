module CodeError

  SUCCESS_CODE = 0
  SUCCESS_STATUS = :success
  SUCCESS_MSG = ''

  INTERNAL_CODE = 99999
  INTERNAL_STATUS = :internal
  INTERNAL_MSG = 'An internal error occurs.'

  MASKED_MSG = 'An error occurs.'

  class Base < StandardError
    attr_reader :code, :status, :info

    def initialize(code = nil, msg = nil, info = {})
      @code = code
      @info = info
      if error_codes.keys.include?(code)
        @status = error_codes[code][:status]
        @msg = error_codes[code][:msg]
        @masked = error_codes[code][:masked] || false
        if msg == :masked
          @masked = true
        elsif msg.is_a?(String)
          @masked = false
          @msg = msg
        end
      elsif code == config[:success][:code]
        @code = config[:success][:code]
        @status = config[:success][:status]
        @msg = config[:success][:msg]
      else
        # unknown code
        @status = config[:internal][:status]
        if code.is_a?(String)
          @code = config[:internal][:code]
          @msg = code
        else
          @code = code || config[:internal][:code]
          @msg = msg || config[:internal][:msg]
        end
      end
    end

    def message
      self.data.inspect
    end

    def data(masked = nil)
      msg = show_message(@code, @msg, masked)
      { status: @status, code: @code, msg: msg, info: @info }
    end

    def msg(masked = nil)
      show_message(@code, @msg, masked)
    end

    def internal?
      @status == config[:internal][:status]
    end

    private

    def error_codes
      raise 'You should implement error_codes method in your code-based class.'
    end

    def config
      {
        :success => {
          :code => SUCCESS_CODE,
          :status => SUCCESS_STATUS,
          :msg => SUCCESS_MSG
        },
        :internal => {
          :code => INTERNAL_CODE,
          :status => INTERNAL_STATUS,
          :msg => INTERNAL_MSG
        },
        :masked_msg => MASKED_MSG,
        :code_in_msg => :append
      }
    end

    def show_message(code, msg, masked = nil)
      if masked == nil
        masked = @masked || false
      end
      m = masked ? config[:masked_msg] : msg
      code_in_msg = config[:code_in_msg]
      if code != config[:success][:code]
        if code_in_msg == :append
          m = "#{m}(#{code})"
        elsif code_in_msg == :prepand
          m = "(#{code})#{m}"
        end
      end
      m
    end
  end
end

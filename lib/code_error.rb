module CodeError

  SUCCESS_CODE = :success
  SUCCESS_STATUS = :success
  SUCCESS_MSG = ''

  INTERNAL_CODE = :internal
  INTERNAL_STATUS = :internal
  INTERNAL_MSG = 'An internal error occurs.'

  DEFAULT_MASKED_MSG = 'An error occurs.'

  DEFAULT_POS = :none

  DEFAULT_MASKED = false

  class Base < StandardError
    attr_reader :code, :status, :info

    @@global_config = {
      :success => {
        :code =>   SUCCESS_CODE,
        :status => SUCCESS_STATUS,
        :msg =>    SUCCESS_MSG,
        :pos =>    DEFAULT_POS,
        :masked => DEFAULT_MASKED
      },
      :internal => {
        :code =>   INTERNAL_CODE,
        :status => INTERNAL_STATUS,
        :msg =>    INTERNAL_MSG,
        :pos =>    DEFAULT_POS,
        :masked => DEFAULT_MASKED
      },
      :masked_msg => DEFAULT_MASKED_MSG,
      :pos =>        DEFAULT_POS,
      :masked =>     DEFAULT_MASKED
    }

    def self.gen(code = nil, options = {})
      merge_klass_config
      @error_codes = {} unless @error_codes
      new(code, options, @error_codes, @klass_config)
    end

    def self.error_codes(data = {})
      @error_codes = data
    end

    def self.success(data = {})
      merge_klass_config( success: data )
    end

    def self.internal(data = {})
      merge_klass_config( internal: data )
    end

    def self.masked_msg(msg = nil)
      merge_klass_config( masked_msg: msg )
    end

    def self.masked(masked = false)
      merge_klass_config( masked: masked )
    end

    def self.pos(pos = nil)
      merge_klass_config( pos: pos )
    end

    def message
      self.data.inspect
    end

    def data(options = {})
      {
        :status => @status,
        :code => @code,
        :msg => show_message(@code, @msg, options),
        :info => @info
      }
    end

    def msg(options = {})
      show_message(@code, @msg, options)
    end

    def internal?
      @status == @internal_status
    end

    # === private methods ===

    def self.merge_klass_config(new_option = {})
      unless @klass_config
        @klass_config = {
          :success => {},
          :internal => {},
          :masked_msg => nil,
          :pos => nil,
          :masked => nil
        }
      end
      @klass_config.merge!(new_option)
    end

    private_class_method :merge_klass_config

    def initialize(code = nil, options = {}, code_map, klass_config)
      @code =       code
      @info =       options[:info]
      @masked_msg = options[:masked_msg] || klass_config[:masked_msg] || @@global_config[:masked_msg]
      @success_code =    klass_config[:success][:code]    || @@global_config[:success][:code]
      @internal_code =   klass_config[:internal][:code]   || @@global_config[:internal][:code]
      @internal_status = klass_config[:internal][:status] || @@global_config[:internal][:status]
      if code_map.keys.include?(code)
        @status = code_map[code][:status]
        @msg =    options[:msg] || code_map[code][:msg] || klass_config[:internal][:msg]  || @@global_config[:internal][:msg]
        @pos =    nil_next(options[:pos],    nil_next(code_map[code][:pos],    nil_next(klass_config[:pos],    @@global_config[:pos])))
        @masked = nil_next(options[:masked], nil_next(code_map[code][:masked], nil_next(klass_config[:masked], @@global_config[:masked])))
      elsif code == @success_code
        @code = @success_code
        @status = options[:status] || klass_config[:success][:status] || @@global_config[:success][:status]
        @msg =    options[:msg]    || klass_config[:success][:msg]    || @@global_config[:success][:msg]
        @pos =    options[:pos]    || klass_config[:success][:pos]    || @@global_config[:success][:pos]
        @masked = nil_next(options[:masked], nil_next(klass_config[:success][:masked], @@global_config[:success][:masked]))
      else
        # :internal or unknown code
        if code.is_a?(String)
          @code = @internal_code
          @msg = code
        else
          @code = code
          @msg =  options[:msg]    || klass_config[:internal][:msg]    || @@global_config[:internal][:msg]
        end
        @status = options[:status] || @internal_status
        @pos =    options[:pos]    || klass_config[:internal][:pos]    || @@global_config[:internal][:pos]
        @masked = nil_next(options[:masked], nil_next(klass_config[:internal][:masked], @@global_config[:internal][:masked]))
      end
    end

    private_class_method :new

    private

    def show_message(code, msg, options = {})
      masked = nil_next(options[:masked], @masked)
      pos = nil_next(options[:pos], @pos)
      display_msg = masked ? @masked_msg : msg
      case pos
        when :append then "#{display_msg} (#{code})"
        when :prepend then "(#{code}) #{display_msg}"
        else
          "#{display_msg}"
      end
    end

    def nil_next(first, second)
      (first.nil? ? second : first)
    end
  end
end

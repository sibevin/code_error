lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'code_error/version'

Gem::Specification.new do |spec|
  spec.name          = "code_error"
  spec.version       = CodeError::VERSION
  spec.authors       = ["Sibevin Wang"]
  spec.email         = ["sibevin@gmail.com"]
  spec.description   = %q{A code-based customized error.}
  spec.summary       = <<-EOF
Inherit CodeError::Base to create your own code-based error. You need to implement the "error_codes" method which provides a hash to define your own error code map.

    class MyError < CodeError::Base

      private

      def error_codes
        {
          20001 => {
            status: :failed,
            msg: 'Purchase information format is incorrect.'
          },
          20002 => {
            status: :failed,
            msg: 'Device information format is incorrect.'
          },
          20003 => {
            status: :failed,
            msg: 'Unknown store.'
          },
          20100 => {
            status: :duplicated,
            msg: 'A duplicated IAP request is sent.'
          },
          20200 => {
            status: :retry,
            msg: 'Client should send the IAP request again.'
          }
        }
      end
    end

Raise an error with a code when you need.

    raise MyError.new(20001)

Rescue and handle it.

    begin
      #...
      raise MyError.new(20001)
      #...
    rescue MyError => e
      raise e if e.internal?
      msg = e.msg
      code = e.code
      info = e.info
      data = e.data
      case(e.status)
      when :failed
        #...
      when :duplicated
        #...
      else
        #...
      end
      #...
    end

Please see "README" to get more details.
  EOF
  spec.homepage      = "https://github.com/sibevin/code_error"
  spec.license       = "MIT"
  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
end

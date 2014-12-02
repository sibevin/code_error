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
Inherit CodeError::Base to create your own code-based error. You need to assign "error_codes" with a hash to define your own error code map.

    class MyError < CodeError::Base

      error_codes({
        purchase_info_incorrect: {
          status: :failed,
          msg: 'Purchase information format is incorrect.'
        },
        device_info_incorrect: {
          status: :failed,
          msg: 'Device information format is incorrect.'
        },
        unknown_store: {
          status: :failed,
          msg: 'Unknown store.'
        },
        duplicated_request: {
          status: :duplicated,
          msg: 'A duplicated IAP request is sent.'
        },
        resend_iap: {
          status: :retry,
          msg: 'Client should send the IAP request again.'
        }
      })

    end

Raise an error with a code when you need.

    raise MyError.gen(:purchase_info_incorrect)

Rescue and handle it.

    begin
      #...
      raise MyError.gen(:purchase_info_incorrect)
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
  spec.add_development_dependency 'minitest', '~> 5.0'
end

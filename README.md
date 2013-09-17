# Code Error

A code-based customized error.

    raise MyError.new(10002)

## Why?

It is a standard error but it provides more.

* All error cases are defined in the same place. Easy to find and reference.
* Just raising an error with a code, then the corresponding status and message are ready to use.
* Highly customizable and extendable, you can even re-define the default messages to what you want.

## Usage

### Basic

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

### Customize error code hash

A customized code-based error class need to implement the "error_codes" method which provides a hash like:

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
          msg: 'A duplicated IAP request is sent.',
          masked: true
        },
        20200 => {
          status: :retry,
          msg: 'Client should send the IAP request again.'
        }
      }
    end

where keys are the supported codes and each value is an another hash to store the code information corresponding each codes. The code information hash contains the following keys:

* :status - [any type you like] The error status to define the error handling flow. You can get it by calling the "status" method.
* :msg - [String] The error message. You can get it by calling the "msg" method.
* :masked - (optional)[Boolean] To define the error message is masked by default or not. The default value is false if no `:masked` is given.

### Raise a code-based error

Once you define the error_codes method, raising a code-based error is easy.

    raise MyError.new(20001)

There are three argments in the new method, `MyError.new(code, msg, info)`. If the given code is defined in the error_codes, the error would contain the corresponding status and msg.

    e = MyError.new(20001)
    e.code # 20001
    e.status # :failed
    e.msg # "Purchase information format is incorrect.(20001)"

You can give another string in "msg" arg to overwrite the original message:

    e = MyError.new(20001, "The another message which would override the original one.")
    e.code # 20001
    e.status # :failed
    e.msg # "The another message which would override the original one.(20001)"

If the given code is unknown, the error would become an internal error, i.e., the status is the `:internal` status.

    e = MyError.new(1111)
    e.code # 1111
    e.status # :internal
    e.msg # "An internal error occurs.(1111)"
    e.internal? # true

If a string is given, the error is also an internal error, but the "msg" would keep this string.

    e = MyError.new("Invalid input!!")
    e.code # 99999
    e.status # :internal
    e.msg # "Invalid input!!"(99999)
    e.internal? # true

You can pass anything to the error handling you want through the "info" arg.

    something = 'what you want...'
    e = MyError.new(20001, nil, something)
    e.info # 'what you want...'

There is a special code `:success` which used in the success case.

    e = MyError.new(:success)
    e.code # 0
    e.status # :success
    e.msg # ""
    e.internal? # false

### Handle the code-base error

When you rescue a code-based error, some useful methods are ready to use.

* code - The error code
* status - The error status
* msg - The error message
* info - The error information
* data - A hash contains the values of code, status, msg, info.
* internal? - To show this error is an internal error or not.

Here is an example:

    e = MyError.new(20001, nil, 'some information')
    e.code # 20001
    e.status # :failed
    e.msg # "Purchase information format is incorrect.(20001)"
    e.info # "some information"
    e.data # { code: 20001, status: :failed, msg: "Purchase information format is incorrect.(20001)", info: 'some information' }
    e.internal? # false

### Configure your code-base error

You can override the `config` method in your code-based error to customize the default behavior. Here is an example:

    class MyError < CodeError::Base

      private

      def error_codes
        #...
      end

      def config
        super.merge({
          success: {
            code: CodeError::SUCCESS_CODE,
            status: CodeError::SUCCESS_STATUS,
            msg: "My own success message." 
          },
          internal: {
            code: CodeError::INTERNAL_CODE,
            status: CodeError::INTERNAL_STATUS,
            msg: "My own internal error message."
          },
          masked_msg: "My own masked message",
          append_code_in_msg: :none
        })
      end
    end

where the config hash contains the following keys:

* :success - Define the success code, status and message.
* :internal - Define the internal error code, status and message.
* :masked_msg - [String] Define the message to replace the masked one.
* :code_in_msg - [:append/:prepend/:none] Define how to embed code in the message. The default option is :append.

### Mask the error message

You can mask an error message if you don't want to show it. A masked message would be replaced with the default masked message. There are several ways to do it, they are listed below sorted by the precedence.

* Pass `true` to the "masked" arg in the "msg" or "data" method.

    e = MyError.new(20001)
    e.msg(ture) # "An error occurs.(20001)"
    e.data(true) # { code: 20001, status: :failed, msg: "An error occurs.(20001)", info: {} }

* Pass the `:masked` to the "msg" arg in the "new" method. 

    e = MyError.new(20001, :masked)
    e.msg # "An error occurs.(20001)"

* Add `masked: true` in the error_codes hash for particular error. Please see [Customize error code hash].

The default masked message can be customized to your own message by overwriting the `:masked_msg` in your config hash. Please see [Configure your code-base error].

## I18n

We don't support the i18n for simpleness but you can do it yourself. Here is an example:

    class MyError < CodeError::Base

      private

      def error_codes
        {
          20001 => {
            status: :failed,
            msg: 'code_error.my_error.purchase_info_incorrect' 
          },
          20002 => {
            status: :failed,
            msg: 'code_error.my_error.device_info_incorrect'
          },
          20003 => {
            status: :failed,
            msg: 'code_error.my_error.unknown_store'
          },
          20100 => {
            status: :duplicated,
            msg: 'code_error.my_error.duplicated_request' 
          },
          20200 => {
            status: :retry,
            msg: 'code_error.my_error.retry'
          }
        }
      end

      def config
        super.merge({
          success: {
            code: CodeError::SUCCESS_CODE,
            status: CodeError::SUCCESS_STATUS,
            msg: 'code_error_my_error.success_msg' 
          },
          internal: {
            code: CodeError::INTERNAL_CODE,
            status: CodeError::INTERNAL_STATUS,
            msg: 'code_error_my_error.internal_msg' 
          },
          masked_msg: 'code_error_my_error.masked_msg',
          append_code_in_msg: :append
        })
      end
    end

    def show_message(code, msg, masked = false)
      masked = masked || @masked || false
      m = masked ? I18n.t(config[:masked_msg]) : I18n.t(msg)
      code_in_msg = config[:code_in_msg]
      if code != config[:success][:code]
        if code_in_message == :append
          m = I18n.t('code_error.my_error.append_code_msg', msg: m, code: code)
        elsif code_in_message == :prepand
          m = I18n.t('code_error.my_error.prepend_code_msg', msg: m, code: code)
        end
      end
      m
    end

And the i18n yml file is:

    en:
      code_error:
        my_error:
          append_code_msg: "%{msg}(%{code})"
          prepend_code_msg: "(%{code})%{msg}"
          purchase_info_invalid: "Purchase information format is incorrect."
          device_info_invalid: "Device information format is incorrect."
          unknown_store: "Unknown Store."
          duplicated_request: "A duplicated IAP request is sent."
          retry: "Client should send the IAP request again."

## Test

Go to code_error gem folder and run

    ruby ./test/test_all.rb

## Authors

Sibevin Wang

## Copyright

Copyright (c) 2013 Sibevin Wang. Released under the MIT license.

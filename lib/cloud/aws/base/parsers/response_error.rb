#--
# Copyright (c) 2013 RightScale, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# 'Software'), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

module RightScale
  module CloudApi
    # Parsers namespace
    module Parser
      # AWS parsers namespace
      module AWS

        # AWS response error parser, case 1
        #
        class ResponseErrorV1

          # Parse HTTP error message from a response body
          #
          # @param [RightScale::CloudApi::HTTPResponse] response
          # @param [Hash] options
          # @option options [Class] :xml_parser
          #
          # @return [String]
          #
          # @example
          #  # For the call below:
          #  ec2.DescribeInstances('InstanceId' => 'hohoho')
          #  # Generates an XML error:
          #  <?xml version="1.0" encoding="UTF-8"?>
          #  <Response>
          #    <Errors>
          #      <Error>
          #        <Code>InvalidInstanceID.Malformed</Code>
          #        <Message>Invalid id: "hohoho"</Message>
          #      </Error>
          #    </Errors>
          #    <RequestID>84bb3005-0b9f-4a1f-9f78-8fbc2a41a401</RequestID>
          #  </Response>
          #  # And the method parse all above into:
          #  400: InvalidInstanceID.Malformed: Invalid id: "hohoho" (RequestID: 84bb3005-0b9f-4a1f-9f78-8fbc2a41a401)
          #
          def self.parse(response, options={})
            result = "#{response.code}: "
            body   = response.body.to_s
            if response['content-type'].to_s[/xml/] || body[/\A<\?xml /]
              hash = Utils::get_xml_parser_class(options[:xml_parser]).parse(body)
              if hash["Response"] && hash["Response"]["Errors"]
                errors = hash["Response"]["Errors"]["Error"]
                errors = [ errors ] if errors.is_a?(Hash)
                result += errors.map{ |error| "#{error['Code']}: #{error['Message']}" }.join('; ')
                # Display a RequestId here
                result << " (RequestID: #{hash["Response"]["RequestID"]})"
              end
            else
              result << "#{body}" unless body._blank?
            end
            result
          end
        end

        
        # AWS response error parser, case 2
        #
        class ResponseErrorV2

          # Parse HTTP error message from a response body
          #
          # @param [RightScale::CloudApi::HTTPResponse] response
          # @param [Hash] options
          # @option options [Class] :xml_parser
          #
          # @return a String to be displayed/logged.
          #
          # @example
          #   # error is a response from ELB
          #   parse(error) #=>
          #     400: ErrorName: SomethingIsWrong (RequestID: 32455505-2345-43245-f432-34543523451)
          # 
          # @return [String]
          #
          def self.parse(response, options={})
            result = "#{response.code}: "
            body   = response.body.to_s
            if response['content-type'].to_s[/xml/] || body[/\A<\?xml /]
              hash = Utils::get_xml_parser_class(options[:xml_parser]).parse(body)
              error = hash["ErrorResponse"] && hash["ErrorResponse"]["Error"]
              if error
                request_id = hash["ErrorResponse"]["RequestID"] || hash["ErrorResponse"]["RequestId"] 
                result += "#{error['Type']}.#{error['Code']}: #{error['Message']} (RequestId: #{request_id})"
              end
            end
            result
          end
        end
        
      end
    end
  end
end
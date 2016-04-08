#--
# Copyright (c) 2016 RightScale, Inc.
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
    module Parser
      # MWS namespace
      module MWS

        class ResponseError

          # Parse HTTP error message from a response body
          #
          # @param [RightScale::CloudApi::HTTPResponse] response
          # @param [Hash] options
          # @option options [Class] :xml_parser
          #
          # @return [String]
          #
          # @example
          #  <?xml version="1.0" encoding="UTF-8"?>
          #  <ErrorResponse xmlns="http://mws.amazonaws.com/FulfillmentInboundShipment/2010-10-01/">
          #    <Error>
          #      <Type>Sender</Type>
          #      <Code>InvalidRequestException</Code>
          #      <Message>Reason: Cannot change Status of Shipment.</Message>
          #    </Error>
          #    <RequestId>dc32b07f-0ffb-4a4b-aab4-9f5fbb8d8797</RequestId>
          #  </ErrorResponse>
          #  # And the method parse all above into:
          #  400: InvalidRequestException: Reason: Cannot change Status of Shipment. (RequestID: dc32b07f-0ffb-4a4b-aab4-9f5fbb8d8797)
          #
          def self.parse(response, options={})
            result = "#{response.code}: "
            body   = response.body.to_s
            if response['content-type'].to_s[/xml/] || body[/\A<\?xml /]
              hash = Utils::get_xml_parser_class(options[:xml_parser]).parse(body)
              if hash["ErrorResponse"]
                error  = hash["ErrorResponse"]["Error"]
                result = "#{error['Code']}: #{error['Message']}"
                # Add RequestId
                result << " (RequestID: #{hash["ErrorResponse"]["RequestId"]})"
              end
            else
              result << "#{body}" unless body._blank?
            end
            result
          end

        end
      end
    end
  end
end

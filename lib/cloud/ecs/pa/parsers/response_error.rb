#--
# Copyright (c) 2015 RightScale, Inc.
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
      module ECS

        # AWS response error parser, case 1
        #
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
          #  # For the call below:
          #  ec2.DescribeInstances('InstanceId' => 'hohoho')
          #  # Generates an XML error:
          #    <?xml version="1.0"?>
          #    <ItemLookupErrorResponse xmlns="http://ecs.amazonaws.com/doc/2013-08-01/">
          #      <Error>
          #        <Code>
          #          AWS.InvalidAccount
          #        </Code>
          #        <Message>
          #          Your AccessKey Id is not registered for Product Advertising API. Please use the AccessKey Id obtained after registering at https://affiliate-program.amazon.com/gp/flex/advertising/api/sign-in.html
          #        </Message>
          #      </Error>
          #      <RequestId>
          #        57510d4f-72ad-4c15-985c-1dc330e5f3d4
          #      </RequestId>
          #    </ItemLookupErrorResponse>
          #  # And the method parse all above into:
          #  400: Your AccessKey Id is not registered for Product Advertising API. Please use the AccessKey Id obtained after registering at https://affiliate-program.amazon.com/gp/flex/advertising/api/sign-in.html (RequestID: 57510d4f-72ad-4c15-985c-1dc330e5f3d4)
          #
          def self.parse(response, options={})
            result = "#{response.code}: "
            body   = response.body.to_s
            if response['content-type'].to_s[/xml/] || body[/\A<\?xml /]
              hash    = Utils::get_xml_parser_class(options[:xml_parser]).parse(body)
              top_key = hash.keys.first
              error   = hash[top_key] && hash[top_key]["Error"]
              if error
                result << ('%s: %s' % [error['Code'], error['Message']])
                result << (' (RequestID: %s)' % hash[top_key]['RequestId'])
              end
            else
              result << body unless body._blank?
            end
            result
          end
        end

      end
    end
  end
end
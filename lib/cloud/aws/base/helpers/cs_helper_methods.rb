module RightScale
  module CloudApi
    module AWS
      module CSHelperMethods
        # Helper methods that can be used in CloudService apps.

        module HelperMethods
          # Recursively get all data while responce has truncated marker
          #
          # @example
          #   CSHelperMethods.fetch_all(@rds, "DescribeDBInstances",
          #     item:   "DescribeDBInstancesResponse/DescribeDBInstancesResult/DBInstances/DBInstance",
          #     marker: "DescribeDBInstancesResponse/DescribeDBInstancesResult/Marker",
          #     params: {"MaxRecords" => 10}
          #   )
          #
          def fetch_all(client, action, opts = {})
            data_path, _, data_attr = opts.fetch(:item).rpartition("/")
            params = opts.fetch(:params, {})
            marker = opts.fetch(:marker)
            data, truncated_marker = [], nil

            begin
              params["Marker"] = truncated_marker if truncated_marker
              response = client.api(action, params)
              truncated_marker = get(response, marker)
              data.concat(select(response, data_path, data_attr))
            end while truncated_marker

            data
          end

          # Get an inner item from a hash
          #
          # @api      public
          # @example  CSHelperMethods.get(hash, "k1/k2/k3")
          # @param    [Hash] original: the hash to convert
          # @param    [Hash] map: a hash indicating how to convert keys
          # @raise    nothing
          # @return   [Hash]
          #
          def get(hash, keys)
            key, *keys = keys.split("/")
            (keys.size == 0 || !hash[key]) ? hash[key] : get(hash[key], keys.join("/"))
          end

          # Select the hash path and returns an item array
          #
          # @api      public
          # @example  CSHelperMethods.select(data, "Key1/Key2", "item")
          # @param    [Hash] data: Target hash
          # @param    [String] path: Keys
          # @param    [String] att: Member attribute name
          # @raise    nothing
          # @return   [Hash]
          #
          def select(data, path, att = "member")
            keys = path.split('/')
            aws_data_pick = ensure_drill_down(data, keys)
            ensure_array(aws_data_pick, att)
          end

          # Ensures access to inner keys of a hash
          #
          # @api      public
          # @example  CSHelperMethods.ensure_drill_down(hash, ["key1", "key2", "key3"])
          # @param    [Hash] response: Target hash
          # @param    [Array<String>, Array<Symbol>] cloud_id: AWS cloud id
          # @raise    nothing
          # @return   [Hash, nil]
          #
          def ensure_drill_down(response, keys)
            keys.each do |k|
              if response && response.include?(k)
                response = response[k]
              else
                response = nil
                break
              end
            end
            response
          end

          # Ensures an array is returned
          #
          # @api      public
          # @example  CSHelperMethods.ensure_array(hash, "item")
          # @param    [Hash] member_container: Target hash
          # @param    [String] att: Member attribute name
          # @raise    nothing
          # @return   [Array]
          #
          def ensure_array(member_container, att = "member")
            if member_container.nil?
              []
            elsif !member_container.include?(att)
              member_container.class == Hash ? [member_container] : Array(member_container)
            else
              member = member_container[att]
              member.class == Hash ? [member] : Array(member)
            end
          end
        end

        extend HelperMethods

        def self.included(base)
          base.send(:extend, HelperMethods)
        end
      end
    end
  end
end

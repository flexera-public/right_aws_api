require 'cloud/aws/ec2/manager'
require 'rspec'

describe RightScale::CloudApi::AWS do
  context "describe calls" do

    SCENARIOS = {
      :describe_instances => {
        :action => :DescribeInstances,
        :params => {},
        :setkey => 'reservationSet'
      },
      :describe_addresses => {
        :action => :DescribeAddresses,
        :params => {},
        :setkey => 'addressesSet'
      },
      :describe_availability_zones => {
        :action => :DescribeAvailabilityZones,
        :params => {},
        :setkey => 'availabilityZoneInfo'
      },
      :describe_internet_gateways => {
        :action => :DescribeInternetGateways,
        :params => {},
        :setkey => 'internetGatewaySet'
      },
      :describe_key_pairs => {
        :action => :DescribeKeyPairs,
        :params => {},
        :setkey => 'keySet'
      },
      :describe_network_acls => {
        :action => :DescribeNetworkAcls,
        :params => {},
        :setkey => 'networkAclSet'
      },
      :describe_placement_groups => {
        :action => :DescribePlacementGroups,
        :params => {},
        :setkey => 'placementGroupSet'
      },
      :describe_route_tables => {
        :action => :DescribeRouteTables,
        :params => {},
        :setkey => 'routeTableSet'
      },
      :describe_security_groups => {
        :action => :DescribeSecurityGroups,
        :params => {},
        :setkey => 'securityGroupInfo'
      },
      :describe_snapshots => {
        :action => :DescribeSnapshots,
        :params => {},
        :setkey => 'snapshotSet'
      },
      :describe_subnets => {
        :action => :DescribeSubnets,
        :params => {},
        :setkey => 'subnetSet'
      },
      :describe_volumes => {
        :action => :DescribeVolumes,
        :params => {},
        :setkey => 'volumeSet'
      },
      :describe_vpcs => {
        :action => :DescribeVpcs,
        :params => {},
        :setkey => 'vpcSet'
      },
    }

    it "work as expected when real creds are provided through ENV['AWS_ACCESS_KEY_ID'] and ENV['AWS_SECRET_ACCESS_KEY']" do
      ec2 = RightScale::CloudApi::AWS::EC2::Manager::new(
        ENV['AWS_ACCESS_KEY_ID'],
        ENV['AWS_SECRET_ACCESS_KEY'],
        'https://us-east-1.ec2.amazonaws.com/',
        :api_version => '2011-07-15',
        :logger      => nil )

      SCENARIOS.each_pair do | scenario_name, scenario_data |
        begin
          action   = scenario_data[:action]
          response = ec2.__send__(action, scenario_data[:params])
          response["#{action}Response"].should_not be(ni)
        end
      end
    end
  end
end

describe TreeBuilderServersByRole do
  context 'TreeBuilderServersByRole' do
    before do
      MiqRegion.seed
      zone = FactoryGirl.create(:zone)
      @miq_server = FactoryGirl.create(:miq_server, :zone => zone)
      allow(MiqServer).to receive(:my_zone).and_return(zone)
      @server_role = FactoryGirl.create(
        :server_role,
        :name              => "smartproxy",
        :description       => "SmartProxy",
        :max_concurrent    => 1,
        :external_failover => false,
        :role_scope        => "zone"
      )

      @assigned_server_role1 = FactoryGirl.create(
        :assigned_server_role,
        :miq_server_id  => @miq_server.id,
        :server_role_id => @server_role.id,
        :active         => false,
        :priority       => 1
      )

      @assigned_server_role2 = FactoryGirl.create(
        :assigned_server_role,
        :miq_server_id  => @miq_server.id,
        :server_role_id => @server_role.id,
        :active         => true,
        :priority       => 2
      )
      @sb = {:active_tree => :diagnostics_tree}
      parent = zone
      @sb[:selected_server_id] = parent.id
      @sb[:selected_typ] = "miq_region"
      @server_tree = TreeBuilderServersByRole.new(:servers_by_role_tree, :servers_by_role, @sb, true, parent)
    end

    it "is not lazy" do
      tree_options = @server_tree.send(:tree_init_options, :servers_by_role)
      expect(tree_options[:lazy]).to eq(false)
    end

    it 'has no root' do
      tree_options = @server_tree.send(:tree_init_options, :servers_by_role)
      root = @server_tree.send(:root_options)
      expect(tree_options[:add_root]).to eq(false)
      expect(root).to eq([])
    end

    it 'returns server nodes as root kids' do
      server_nodes = @server_tree.send(:x_get_tree_roots, false, {})
      expect(server_nodes).to eq([@server_role])
    end

    it 'returns Servers by Roles' do
      nodes = [{:key      => "role-#{MiqRegion.compress_id(@server_role.id)}",
                :title    => "Role: SmartProxy (stopped)",
                :icon     => ActionController::Base.helpers.image_path('100/role-smartproxy.png'),
                :expand   => true,
                :tooltip  => "Role: SmartProxy (stopped)",
                :children => [{:key      => "asr-#{MiqRegion.compress_id(@assigned_server_role1.id)}",
                               :addClass => "cfme-red-node",
                               :title    => "Server: smartproxy [#{@assigned_server_role1.id}] (primary, available, PID=)",
                               :icon     => ActionController::Base.helpers.image_path('100/suspended.png'),
                               :expand   => true,
                              },
                              {:key      => "asr-#{MiqRegion.compress_id(@assigned_server_role2.id)}",
                               :addClass => "dynatree-title",
                               :title    => "Server: smartproxy [#{@assigned_server_role2.id}] (secondary, active, PID=)",
                               :icon     => ActionController::Base.helpers.image_path('100/on.png'),
                               :expand   => true,
                              },
                ],
               }]
      expect(@server_tree.locals_for_render[:json_tree]).to eq(nodes.to_json)
    end
  end
end

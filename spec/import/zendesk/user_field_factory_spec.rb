require 'rails_helper'
require 'import/zendesk/base_factory_examples'
require 'import/zendesk/local_id_mapper_hook_examples'

RSpec.describe Import::Zendesk::UserFieldFactory do
  it_behaves_like 'Import::Zendesk::BaseFactory'
  it_behaves_like 'Import::Zendesk::LocalIDMapperHook'
end

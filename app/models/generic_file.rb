class GenericFile < ActiveFedora::Base
  include Hydra::Works::FileSetBehavior
  include Hydra::Works::Characterization
  property :state, predicate: ActiveFedora::RDF::Fcrepo::Model.state, multiple: false do |index|
    index.as :symbol, :facetable
  end
end

class Collection < ActiveFedora::Base
  include Hydra::Works::CollectionBehavior
  property :state, predicate: ActiveFedora::RDF::Fcrepo::Model.state, multiple: false do |index|
    index.as :symbol, :facetable
  end
end
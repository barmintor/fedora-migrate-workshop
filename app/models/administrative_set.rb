class AdministrativeSet < ActiveFedora::Container
  property :state, predicate: ActiveFedora::RDF::Fcrepo::Model.state, multiple: false do |index|
    index.as :symbol, :facetable
  end
end
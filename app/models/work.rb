class Work < ActiveFedora::Base
  include Hydra::Works::WorkBehavior
  property :state, predicate: ActiveFedora::RDF::Fcrepo::Model.state, multiple: false do |index|
    index.as :symbol, :facetable
  end
  property :identifier, predicate: ::RDF::Vocab::DC.identifier do |index|
    index.as :symbol, :facetable
  end
  property :title, predicate: ::RDF::Vocab::DC.title do |index|
    index.as :stored_searchable, :facetable
  end
  property :creator, predicate: ::RDF::Vocab::DC.creator do |index|
    index.as :symbol, :facetable
  end
  property :created, predicate: ::RDF::Vocab::DC.created do |index|
    index.as :stored_sortable, type: :date
  end
  property :format, predicate: ::RDF::Vocab::DC.format do |index|
    index.as :stored_searchable, :facetable
  end
  property :object_type, predicate: ::RDF::Vocab::DC.type do |index|
    index.as :stored_searchable, :facetable
  end
  property :link, predicate: ::RDF::RDFS.seeAlso do |index|
    index.as :symbol, :facetable
  end
end
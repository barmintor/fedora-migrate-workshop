module FedoraMigrate::Hooks

  # @source is a Rubydora object
  # @target is a Hydra 9 modeled object

  # Called from FedoraMigrate::ObjectMover
  def before_object_migration
    # additional actions as needed
  end

  # Called from FedoraMigrate::ObjectMover
  def after_object_migration
    # additional actions as needed
    if source.state
      case source.state
      when 'D'
        target.state = ActiveFedora::RDF::Fcrepo::Model.Deleted
      when 'I'
        target.state = ActiveFedora::RDF::Fcrepo::Model.Inactive
      else
        target.state = ActiveFedora::RDF::Fcrepo::Model.Active
      end
    end
  end

  # Called from FedoraMigrate::RDFDatastreamMover
  def before_rdf_datastream_migration
    # additional actions as needed
    puts "migrating rdf from #{source.pid}/#{source.dsid}"
  end

  # Called from FedoraMigrate::RDFDatastreamMover
  def after_rdf_datastream_migration
    # additional actions as needed
    puts "migrated rdf from #{source.pid}/#{source.dsid}"
  end

  # Called from FedoraMigrate::DatastreamMover
  def before_datastream_migration
    # additional actions as needed
  end

  # Called from FedoraMigrate::DatastreamMover
  def after_datastream_migration
    # additional actions as needed
  end

end

ActiveFedora::File.class_eval do
  def digest
    response = metadata.ldp_source.graph.query(predicate: RDF::Vocab::PREMIS.hasMessageDigest)
    # fallback on old predicate for checksum
    response = metadata.ldp_source.graph.query(predicate: RDF::Vocab::Fcrepo4.digest) if response.empty?
    response.map(&:object)
  end
end
FedoraMigrate::RelsExtDatastreamMover.class_eval do
  def migrate_object(fc3_uri)
    if (fc3_uri.to_s =~ /^info:fedora\/.+:.+/)
      RDF::URI.new(ActiveFedora::Base.id_to_uri(id_component(fc3_uri)))
    else
      RDF::URI.new(fc3_uri)
    end
  end
  def missing_object?(statement)
    return false unless (statement.object.to_s =~ /^info:fedora\/.+:.+/)
    return false if ActiveFedora::Base.exists?(id_component(statement.object))
    report << "could not migrate relationship #{statement.predicate} because #{statement.object} doesn't exist in Fedora 4"
    true
  end
end
desc "Delete all the content in Fedora 4"
task clean: :environment do
  ActiveFedora::Cleaner.clean!
end
desc "Migrate all my objects"
task migrate: :environment do
  # load the model classes
  Work.name
  GenericFile.name
  Collection.name
  AdministrativeSet.name
  assets = ["usna:3","usna:4","usna:5","usna:6","usna:7","usna:8","usna:9"]
  works = ["archives:1408042", "archives:1419123", "archives:1667751"]
  collections = ["collection:1", "collection:2"]
  migration = Proc.new do |pid|
    source = FedoraMigrate.source.connection.find(pid)
    target = nil
    options = { convert: "descMetadata" }
    mover = FedoraMigrate::ObjectMover.new(source, target, options)
    mover.migrate
    target = mover.target
    mover = FedoraMigrate::RelsExtDatastreamMover.new(source, target).migrate
  end
  assets.each { |pid| migration.call(pid) }
  works.each { |pid| migration.call(pid) }
  collections.each { |pid| migration.call(pid) }
end
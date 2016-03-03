module FedoraMigrate
  module Works
    class StructureMover < FedoraMigrate::Mover
      def migrate
        before_structure_migration
        migrate_struct_metadata
        after_structure_migration
        save
        super
      end
      def migrate_struct_metadata
        ds = source.datastreams['structMetadata']
        if ds
          ns = {mets: "http://www.loc.gov/METS/"}
          structMetadata = Nokogiri::XML(ds.content)
          members = {}
          structMetadata.xpath("/mets:structMap/mets:div", ns).each do |node|
            members[node["ORDER"]] = node["CONTENTIDS"]
          end
          members.keys.sort {|a,b| a.to_i <=> b.to_i}.each do |key|
            member_id = id_component(members[key])
            member = ActiveFedora::Base.find(member_id)
            target.ordered_members << member
          end
        end
      end
      def migrate_object(fc3_uri)
        RDF::URI.new(ActiveFedora::Base.id_to_uri(id_component(fc3_uri)))
      end
    end
  end
end